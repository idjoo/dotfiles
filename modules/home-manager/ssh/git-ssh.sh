#!/usr/bin/env sh

if [ -z "${SSH_AUTH_SOCK:-}" ]; then
  eval "$(keychain env --shell sh)"
fi

exec ssh "$@"
