#!/bin/bash
set -e
export GIT_CONFIG_GLOBAL="/tmp/.gitconfig"

git config --global --add safe.directory "$GIT_WORKSPACE"

if [ -z "$GNUPGHOME" ]; then
    echo "GNUPGHOME ist nicht gesetzt. Verwende Fallback-Verzeichnis..."
    export GNUPGHOME="/tmp/gpg-home"
fi

mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

echo "pinentry-mode loopback" > "$GNUPGHOME/gpg.conf"
echo "allow-loopback-pinentry" > "$GNUPGHOME/gpg-agent.conf"
chmod 600 "$GNUPGHOME"/*

# Check whether the Base64 variable exists
if [ -z "$GIT_GPG_SIGNKEY_BASE64" ]; then
  echo "Error: env var GIT_GPG_SIGNKEY_BASE64 is empty"
  exit 1
fi

# Reset GPG agents in the container beforehand
gpgconf --kill all || true

# Decode directly and import into GPG (suppress error messages)
echo "$GIT_GPG_SIGNKEY_BASE64" | base64 --decode --ignore-garbage | gpg --homedir "$GNUPGHOME" --batch --import 2>/dev/null

# Key-ID auslesen
GIT_GPG_KEY_ID=$(gpg --homedir "$GNUPGHOME" --list-secret-keys --with-colons 2>/dev/null | awk -F: '/^sec:/ {print $5; exit}')

if [ -z "$GIT_GPG_KEY_ID" ]; then
  echo "Error:: key-id could not be evaluated..."
  exit 1
fi

echo "Exakte Maven GPG-ID: $GIT_GPG_KEY_ID"

git config --local user.signingkey "$GIT_GPG_KEY_ID"
git config --local commit.gpgsign true
git config --local --add safe.directory "$GIT_WORKSPACE"
git config --local user.name "$GIT_COMMITTER_NAME"
git config --local user.email "$GIT_COMMITTER_EMAIL"

# Falls safe.directory zwingend global gebraucht wird, schreiben wir es in eine spezifische Datei

git config --file /tmp/.gitconfig --add safe.directory "$GIT_WORKSPACE"

echo "Git and GPG successfully configured for the runtime container (GIT_GPG_KEY_ID: $GIT_GPG_KEY_ID)."
