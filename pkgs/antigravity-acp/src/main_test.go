package main

import (
	"bytes"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

func TestStripLegacyArgs(t *testing.T) {
	got := stripLegacyArgs([]string{"--uid=", "--foo", "bar", "--uid", "1000", "--baz"})
	want := []string{"--foo", "bar", "--baz"}
	if len(got) != len(want) {
		t.Fatalf("got %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("at %d: got %q, want %q", i, got[i], want[i])
		}
	}
}

func TestBuildChildEnvStripsSSHOnlyWithBrowser(t *testing.T) {
	in := []string{"HOME=/tmp", "SSH_CONNECTION=1.2.3.4", "SSH_TTY=/dev/pts/0"}
	if got := buildChildEnv(in); len(got) != 3 {
		t.Fatalf("without BROWSER expected unchanged env, got %v", got)
	}
	withBrowser := append(in, "BROWSER=/usr/bin/helper")
	got := buildChildEnv(withBrowser)
	for _, kv := range got {
		if strings.HasPrefix(kv, "SSH_") {
			t.Fatalf("expected SSH_* stripped when BROWSER is set, got %v", got)
		}
	}
}

func TestTokenSyncAndLogoutMarker(t *testing.T) {
	tmp := t.TempDir()
	userHome := filepath.Join(tmp, "home")
	geminiHome := filepath.Join(tmp, "gemini")
	srcDir := filepath.Join(userHome, ".gemini", "antigravity-cli")
	if err := os.MkdirAll(srcDir, 0o700); err != nil {
		t.Fatal(err)
	}
	srcTok := filepath.Join(srcDir, "antigravity-oauth-token")
	if err := os.WriteFile(srcTok, []byte(`{"auth_method":"gcp"}`), 0o600); err != nil {
		t.Fatal(err)
	}

	var out bytes.Buffer
	b := newBridge(userHome, geminiHome, &out)
	b.syncCliTokenIfAvailable()

	st, err := os.Stat(b.activeTokenPath)
	if err != nil {
		t.Fatalf("expected seeded token: %v", err)
	}
	if st.Mode().Perm() != 0o600 {
		t.Fatalf("expected mode 0600, got %o", st.Mode().Perm())
	}

	// Simulate T3 logout: remove active token and write .t3-logged-out with newer mtime.
	_ = os.Remove(b.activeTokenPath)
	future := time.Now().Add(2 * time.Second)
	if err := os.WriteFile(b.loggedOutMarker, nil, 0o600); err != nil {
		t.Fatal(err)
	}
	_ = os.Chtimes(b.loggedOutMarker, future, future)

	b.syncCliTokenIfAvailable()
	if _, err := os.Stat(b.activeTokenPath); !os.IsNotExist(err) {
		t.Fatalf("expected logged-out marker to prevent token re-seeding")
	}

	// Updating CLI token newer than marker re-enables seeding.
	later := future.Add(2 * time.Second)
	_ = os.Chtimes(srcTok, later, later)
	b.syncCliTokenIfAvailable()
	if _, err := os.Stat(b.activeTokenPath); err != nil {
		t.Fatalf("expected newer CLI token to re-seed: %v", err)
	}
}

func TestProtocolTranslationsAndLargeLine(t *testing.T) {
	tmp := t.TempDir()
	userHome := filepath.Join(tmp, "home")
	geminiHome := filepath.Join(tmp, "gemini")
	srcDir := filepath.Join(userHome, ".gemini", "antigravity-cli")
	_ = os.MkdirAll(srcDir, 0o700)
	_ = os.WriteFile(filepath.Join(srcDir, "antigravity-oauth-token"), []byte(`{"ok":true}`), 0o600)

	var stdout, childStdin bytes.Buffer
	b := newBridge(userHome, geminiHome, &stdout)
	b.syncCliTokenIfAvailable()

	// 1. Browser OAuth authenticate short-circuits locally.
	if err := b.handleClientLine([]byte(`{"jsonrpc":"2.0","id":1,"method":"authenticate","params":{"methodId":"oauth-business"}}`), &childStdin); err != nil {
		t.Fatal(err)
	}
	if childStdin.Len() != 0 {
		t.Fatalf("expected browser authenticate not forwarded when token exists, got %s", childStdin.String())
	}
	if !strings.Contains(stdout.String(), `"id":1`) {
		t.Fatalf("expected immediate authenticate reply, got %s", stdout.String())
	}
	stdout.Reset()

	// 2. Non-browser authenticate (agent-platform) forwards to child.
	if err := b.handleClientLine([]byte(`{"jsonrpc":"2.0","id":2,"method":"authenticate","params":{"methodId":"agent-platform"}}`), &childStdin); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(childStdin.String(), `"agent-platform"`) {
		t.Fatalf("expected agent-platform authenticate forwarded, got %s", childStdin.String())
	}
	childStdin.Reset()

	// 3. session/new response expands accept-edits into auto_edit + yolo.
	sessionNewResp := `{"jsonrpc":"2.0","id":3,"result":{"sessionId":"s1","modes":{"currentModeId":"default","availableModes":[{"id":"default","name":"Default"},{"id":"accept-edits","name":"Accept edits"}]},"configOptions":[{"id":"mode","category":"mode","type":"select","currentValue":"default","options":[{"value":"default","name":"Default"},{"value":"accept-edits","name":"Accept edits"}]}]}}`
	if err := b.handleAgentLine([]byte(sessionNewResp)); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(stdout.String(), `"yolo"`) || !strings.Contains(stdout.String(), `"auto_edit"`) {
		t.Fatalf("expected yolo and auto_edit in rewritten session/new, got %s", stdout.String())
	}
	stdout.Reset()

	// 4. Setting yolo translates to accept-edits for child, and response maps back to yolo.
	if err := b.handleClientLine([]byte(`{"jsonrpc":"2.0","id":4,"method":"session/set_config_option","params":{"sessionId":"s1","configId":"mode","value":"yolo"}}`), &childStdin); err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(childStdin.String(), `"value":"accept-edits"`) {
		t.Fatalf("expected yolo mapped to accept-edits on stdin, got %s", childStdin.String())
	}
	if err := b.handleAgentLine([]byte(`{"jsonrpc":"2.0","id":4,"result":{"configOptions":[{"id":"mode","category":"mode","type":"select","currentValue":"accept-edits","options":[{"value":"accept-edits","name":"Accept edits"}]}]}}`)); err != nil {
		t.Fatal(err)
	}
	var parsed map[string]any
	if err := json.Unmarshal(bytes.TrimSpace(stdout.Bytes()), &parsed); err != nil {
		t.Fatal(err)
	}
	cfgOpts := parsed["result"].(map[string]any)["configOptions"].([]any)
	curVal := cfgOpts[0].(map[string]any)["currentValue"]
	if curVal != "yolo" {
		t.Fatalf("expected currentValue mapped back to yolo, got %v", curVal)
	}
	stdout.Reset()

	// 5. Multi-megabyte line (>1 MiB) passes readLines without scanner truncation.
	largePayload := `{"jsonrpc":"2.0","method":"other","params":{"blob":"` + strings.Repeat("x", 1024*1024) + `"}}` + "\n"
	var gotLen int
	if err := readLines(strings.NewReader(largePayload), func(line []byte) error {
		gotLen = len(line)
		return nil
	}); err != nil {
		t.Fatalf("readLines failed on 1 MiB line: %v", err)
	}
	if gotLen != len(largePayload)-1 {
		t.Fatalf("got line length %d, want %d", gotLen, len(largePayload)-1)
	}
}
