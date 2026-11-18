package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
)

// Injected via -ldflags "-X main.defaultAgyBin=..." at Nix build time.
var defaultAgyBin = "agy"

type pendingReq struct {
	method    string
	sessionID string
}

type bridge struct {
	sourceTokenPath string
	geminiHome      string
	acpDir          string
	activeTokenPath string
	loggedOutMarker string

	stdoutMu sync.Mutex
	stdout   io.Writer

	stateMu                sync.Mutex
	requestedModeBySession map[string]string
	pendingRequests        map[string]pendingReq
}

func newBridge(userHome, geminiHome string, stdout io.Writer) *bridge {
	sourceTokenPath := filepath.Join(userHome, ".gemini", "antigravity-cli", "antigravity-oauth-token")
	var acpDir, loggedOutMarker string
	activeTokenPath := sourceTokenPath
	if geminiHome != "" {
		geminiHome = filepath.Clean(geminiHome)
		acpDir = filepath.Join(geminiHome, "antigravity-acp")
		activeTokenPath = filepath.Join(acpDir, "antigravity-oauth-token")
		loggedOutMarker = filepath.Join(acpDir, ".t3-logged-out")
	}
	return &bridge{
		sourceTokenPath:        sourceTokenPath,
		geminiHome:             geminiHome,
		acpDir:                 acpDir,
		activeTokenPath:        activeTokenPath,
		loggedOutMarker:        loggedOutMarker,
		stdout:                 stdout,
		requestedModeBySession: make(map[string]string),
		pendingRequests:        make(map[string]pendingReq),
	}
}

func stripLegacyArgs(args []string) []string {
	out := make([]string, 0, len(args))
	for i := 0; i < len(args); i++ {
		arg := args[i]
		if arg == "--uid" {
			i++
			continue
		}
		if strings.HasPrefix(arg, "--uid=") {
			continue
		}
		out = append(out, arg)
	}
	return out
}

func buildChildEnv(environ []string) []string {
	hasBrowser := false
	for _, kv := range environ {
		if after, ok := strings.CutPrefix(kv, "BROWSER="); ok && after != "" {
			hasBrowser = true
			break
		}
	}
	if !hasBrowser {
		return environ
	}
	out := make([]string, 0, len(environ))
	for _, kv := range environ {
		if strings.HasPrefix(kv, "SSH_CONNECTION=") ||
			strings.HasPrefix(kv, "SSH_CLIENT=") ||
			strings.HasPrefix(kv, "SSH_TTY=") {
			continue
		}
		out = append(out, kv)
	}
	return out
}

func (b *bridge) syncCliTokenIfAvailable() {
	if b.acpDir == "" {
		return
	}
	if err := os.MkdirAll(b.acpDir, 0o700); err != nil {
		return
	}
	sourceStat, err := os.Stat(b.sourceTokenPath)
	if err != nil {
		return
	}
	if b.loggedOutMarker != "" {
		if markerStat, err := os.Stat(b.loggedOutMarker); err == nil {
			if !sourceStat.ModTime().After(markerStat.ModTime()) {
				return
			}
			_ = os.Remove(b.loggedOutMarker)
		}
	}
	targetStat, targetErr := os.Stat(b.activeTokenPath)
	if targetErr != nil || sourceStat.ModTime().After(targetStat.ModTime()) {
		data, err := os.ReadFile(b.sourceTokenPath)
		if err != nil {
			return
		}
		tmpPath := filepath.Join(b.acpDir, fmt.Sprintf(".antigravity-oauth-token.%d.tmp", os.Getpid()))
		if err := os.WriteFile(tmpPath, data, 0o600); err != nil {
			_ = os.Remove(tmpPath)
			return
		}
		if err := os.Chmod(tmpPath, 0o600); err != nil {
			_ = os.Remove(tmpPath)
			return
		}
		if err := os.Rename(tmpPath, b.activeTokenPath); err != nil {
			_ = os.Remove(tmpPath)
		}
	}
}

func (b *bridge) writeStdoutLine(line []byte) error {
	b.stdoutMu.Lock()
	defer b.stdoutMu.Unlock()
	if _, err := b.stdout.Write(line); err != nil {
		return err
	}
	_, err := b.stdout.Write([]byte("\n"))
	return err
}

func decodeJSONMap(line []byte) (map[string]any, bool) {
	dec := json.NewDecoder(bytes.NewReader(line))
	dec.UseNumber()
	var obj map[string]any
	if err := dec.Decode(&obj); err != nil || obj == nil {
		return nil, false
	}
	return obj, true
}

func idKey(id any) (string, bool) {
	if id == nil {
		return "", false
	}
	raw, err := json.Marshal(id)
	if err != nil {
		return "", false
	}
	return string(raw), true
}

func isBrowserOAuthMethod(methodID string) bool {
	return methodID == "" || methodID == "oauth-personal" || methodID == "oauth-business"
}

func (b *bridge) resolveT3Mode(agyMode, sessionID string) string {
	if agyMode != "accept-edits" {
		return agyMode
	}
	b.stateMu.Lock()
	requested := b.requestedModeBySession[sessionID]
	b.stateMu.Unlock()
	if requested == "yolo" || requested == "auto_edit" {
		return requested
	}
	return "auto_edit"
}

func (b *bridge) rewriteModesObject(modes any, sessionID string) any {
	m, ok := modes.(map[string]any)
	if !ok {
		return modes
	}
	if avail, ok := m["availableModes"].([]any); ok {
		expanded := make([]any, 0, len(avail)+1)
		for _, entry := range avail {
			em, ok := entry.(map[string]any)
			if !ok || em["id"] != "accept-edits" {
				expanded = append(expanded, entry)
				continue
			}
			expanded = append(expanded,
				map[string]any{
					"id":          "auto_edit",
					"name":        "Auto Edit",
					"description": "Approve file edits in the workspace without asking.",
				},
				map[string]any{
					"id":          "yolo",
					"name":        "Full Access",
					"description": "Approve file edits and commands without asking.",
				},
			)
		}
		m["availableModes"] = expanded
	}
	if cur, ok := m["currentModeId"].(string); ok {
		m["currentModeId"] = b.resolveT3Mode(cur, sessionID)
	}
	return m
}

func rewriteModeChoices(options []any) []any {
	expanded := make([]any, 0, len(options)+1)
	for _, entry := range options {
		em, ok := entry.(map[string]any)
		if !ok {
			expanded = append(expanded, entry)
			continue
		}
		if nested, ok := em["options"].([]any); ok {
			em["options"] = rewriteModeChoices(nested)
			expanded = append(expanded, em)
			continue
		}
		if em["value"] != "accept-edits" {
			expanded = append(expanded, entry)
			continue
		}
		expanded = append(expanded,
			map[string]any{
				"value":       "auto_edit",
				"name":        "Auto Edit",
				"description": "Approve file edits in the workspace without asking.",
			},
			map[string]any{
				"value":       "yolo",
				"name":        "Full Access",
				"description": "Approve file edits and commands without asking.",
			},
		)
	}
	return expanded
}

func (b *bridge) rewriteConfigOptions(configOptions any, sessionID string) any {
	opts, ok := configOptions.([]any)
	if !ok {
		return configOptions
	}
	for _, rawOpt := range opts {
		opt, ok := rawOpt.(map[string]any)
		if !ok || opt["type"] == "boolean" {
			continue
		}
		if opt["id"] != "mode" && opt["category"] != "mode" {
			continue
		}
		if choices, ok := opt["options"].([]any); ok {
			opt["options"] = rewriteModeChoices(choices)
		}
		if cur, ok := opt["currentValue"].(string); ok {
			opt["currentValue"] = b.resolveT3Mode(cur, sessionID)
		}
	}
	return opts
}

func (b *bridge) handleClientLine(line []byte, childStdin io.Writer) error {
	trimmed := bytes.TrimSpace(line)
	if len(trimmed) == 0 {
		_, err := childStdin.Write(append(line, '\n'))
		return err
	}
	msg, ok := decodeJSONMap(trimmed)
	if !ok {
		_, err := childStdin.Write(append(line, '\n'))
		return err
	}

	method, _ := msg["method"].(string)
	key, hasID := idKey(msg["id"])
	params, _ := msg["params"].(map[string]any)

	// T3 Code sends authenticate eagerly before every session/new. For browser
	// OAuth modes in agy 1.5.x, authenticate unconditionally starts a fresh
	// interactive browser flow even when a valid OAuth token already exists.
	if method == "authenticate" && hasID {
		methodID, _ := params["methodId"].(string)
		if isBrowserOAuthMethod(methodID) {
			b.syncCliTokenIfAvailable()
			if _, err := os.Stat(b.activeTokenPath); err == nil {
				resp, err := json.Marshal(map[string]any{
					"jsonrpc": "2.0",
					"id":      msg["id"],
					"result":  map[string]any{},
				})
				if err != nil {
					return err
				}
				return b.writeStdoutLine(resp)
			}
			if b.loggedOutMarker != "" {
				_ = os.Remove(b.loggedOutMarker)
			}
		}
		_, err := childStdin.Write(append(line, '\n'))
		return err
	}

	if method == "logout" {
		if hasID {
			b.stateMu.Lock()
			b.pendingRequests[key] = pendingReq{method: "logout"}
			b.stateMu.Unlock()
		}
		_, err := childStdin.Write(append(line, '\n'))
		return err
	}

	var sid string
	if params != nil {
		sid, _ = params["sessionId"].(string)
	}

	mutated := false
	if method == "session/set_mode" && params != nil {
		if modeID, ok := params["modeId"].(string); ok {
			if sid != "" {
				b.stateMu.Lock()
				b.requestedModeBySession[sid] = modeID
				b.stateMu.Unlock()
			}
			if modeID == "auto_edit" || modeID == "yolo" {
				params["modeId"] = "accept-edits"
				mutated = true
			}
		}
	} else if method == "session/set_config_option" && params != nil {
		if cfgID, _ := params["configId"].(string); cfgID == "mode" {
			if val, ok := params["value"].(string); ok {
				if sid != "" {
					b.stateMu.Lock()
					b.requestedModeBySession[sid] = val
					b.stateMu.Unlock()
				}
				if val == "auto_edit" || val == "yolo" {
					params["value"] = "accept-edits"
					mutated = true
				}
			}
		}
	}

	if hasID && method != "" {
		b.stateMu.Lock()
		b.pendingRequests[key] = pendingReq{method: method, sessionID: sid}
		b.stateMu.Unlock()
	}

	if !mutated {
		_, err := childStdin.Write(append(line, '\n'))
		return err
	}
	encoded, err := json.Marshal(msg)
	if err != nil {
		return err
	}
	_, err = childStdin.Write(append(encoded, '\n'))
	return err
}

func (b *bridge) handleAgentLine(line []byte) error {
	trimmed := bytes.TrimSpace(line)
	if len(trimmed) == 0 {
		return b.writeStdoutLine(line)
	}
	msg, ok := decodeJSONMap(trimmed)
	if !ok {
		return b.writeStdoutLine(line)
	}

	mutated := false
	if key, hasID := idKey(msg["id"]); hasID {
		b.stateMu.Lock()
		reqInfo, tracked := b.pendingRequests[key]
		if tracked {
			delete(b.pendingRequests, key)
		}
		b.stateMu.Unlock()

		if reqInfo.method == "logout" && msg["error"] == nil && b.loggedOutMarker != "" {
			_ = os.WriteFile(b.loggedOutMarker, nil, 0o600)
		}

		if result, ok := msg["result"].(map[string]any); ok {
			if agentInfo, ok := result["agentInfo"].(map[string]any); ok {
				if agentInfo["name"] != "antigravity-acp" {
					agentInfo["name"] = "antigravity-acp"
					mutated = true
				}
			}
			sid, _ := result["sessionId"].(string)
			if sid == "" {
				sid = reqInfo.sessionID
			}
			if modes, exists := result["modes"]; exists && modes != nil {
				result["modes"] = b.rewriteModesObject(modes, sid)
				mutated = true
			}
			if cfgOpts, exists := result["configOptions"]; exists && cfgOpts != nil {
				result["configOptions"] = b.rewriteConfigOptions(cfgOpts, sid)
				mutated = true
			}
		}
	} else if method, _ := msg["method"].(string); method == "session/update" {
		if params, ok := msg["params"].(map[string]any); ok {
			sid, _ := params["sessionId"].(string)
			if update, ok := params["update"].(map[string]any); ok {
				switch update["sessionUpdate"] {
				case "config_option_update":
					if cfgOpts, exists := update["configOptions"]; exists && cfgOpts != nil {
						update["configOptions"] = b.rewriteConfigOptions(cfgOpts, sid)
						mutated = true
					}
				case "current_mode_update":
					if cur, ok := update["currentModeId"].(string); ok {
						update["currentModeId"] = b.resolveT3Mode(cur, sid)
						mutated = true
					}
				}
			}
		}
	}

	if !mutated {
		return b.writeStdoutLine(line)
	}
	encoded, err := json.Marshal(msg)
	if err != nil {
		return err
	}
	return b.writeStdoutLine(encoded)
}

func readLines(r io.Reader, onLine func([]byte) error) error {
	br := bufio.NewReaderSize(r, 64*1024)
	for {
		chunk, err := br.ReadBytes('\n')
		if len(chunk) > 0 {
			chunk = bytes.TrimSuffix(chunk, []byte("\n"))
			chunk = bytes.TrimSuffix(chunk, []byte("\r"))
			if cbErr := onLine(chunk); cbErr != nil {
				return cbErr
			}
		}
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return err
		}
	}
}

func runBridge(agyBin string, rawArgs []string, stdin io.Reader, stdout, stderr io.Writer) int {
	passthrough := stripLegacyArgs(rawArgs)
	userHome := os.Getenv("HOME")
	if userHome == "" {
		userHome, _ = os.UserHomeDir()
	}
	geminiHome := os.Getenv("GEMINI_HOME")

	b := newBridge(userHome, geminiHome, stdout)
	b.syncCliTokenIfAvailable()

	var agyArgs []string
	if b.geminiHome != "" {
		agyArgs = append([]string{
			"acp",
			"--gemini-dir", b.geminiHome,
			"--app-data-dir", "antigravity-acp",
		}, passthrough...)
	} else {
		agyArgs = append([]string{"acp"}, passthrough...)
	}

	cmd := exec.Command(agyBin, agyArgs...)
	cmd.Env = buildChildEnv(os.Environ())
	cmd.Stderr = stderr

	childStdin, err := cmd.StdinPipe()
	if err != nil {
		_, _ = fmt.Fprintf(stderr, "antigravity-acp: stdin pipe error: %v\n", err)
		return 1
	}
	childStdout, err := cmd.StdoutPipe()
	if err != nil {
		_, _ = fmt.Fprintf(stderr, "antigravity-acp: stdout pipe error: %v\n", err)
		return 1
	}

	if err := cmd.Start(); err != nil {
		_, _ = fmt.Fprintf(stderr, "antigravity-acp: failed to start %s: %v\n", agyBin, err)
		return 1
	}

	sigCh := make(chan os.Signal, 4)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)
	doneCh := make(chan struct{})
	go func() {
		for {
			select {
			case sig := <-sigCh:
				if cmd.Process != nil {
					_ = cmd.Process.Signal(sig)
				}
			case <-doneCh:
				return
			}
		}
	}()

	go func() {
		_ = readLines(stdin, func(line []byte) error {
			return b.handleClientLine(line, childStdin)
		})
		_ = childStdin.Close()
	}()

	_ = readLines(childStdout, b.handleAgentLine)

	err = cmd.Wait()
	signal.Stop(sigCh)
	close(doneCh)

	if err == nil {
		return 0
	}
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		if code := exitErr.ExitCode(); code >= 0 {
			return code
		}
		return 128
	}
	return 1
}

func main() {
	if filepath.Base(os.Args[0]) == "localharness_external" {
		argv := append([]string{defaultAgyBin}, os.Args[1:]...)
		if err := syscall.Exec(defaultAgyBin, argv, os.Environ()); err != nil {
			_, _ = fmt.Fprintf(os.Stderr, "localharness_external: exec %s: %v\n", defaultAgyBin, err)
			os.Exit(1)
		}
	}
	os.Exit(runBridge(defaultAgyBin, os.Args[1:], os.Stdin, os.Stdout, os.Stderr))
}
