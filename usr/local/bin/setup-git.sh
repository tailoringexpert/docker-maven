#!/bin/bash
set -e

# Prüfen, ob der Schlüssel bereitgestellt wurde
if [ -z "$GIT_GPG_SIGNKEY" ]; then
  echo "Fehler: GIT_GPG_SIGNKEY ist leer! Wurde die Variable an den Container übergeben?"
  exit 1
fi

# GPG-Schlüssel importieren
echo "$GIT_GPG_SIGNKEY" | gpg --batch --import || true

# Key-ID extrahieren
GIT_GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d'/' -f2)

if [ -z "$GIT_GPG_KEY_ID" ]; then
  echo "Fehler: GPG Key-ID konnte nicht ermittelt werden."
  exit 1
fi

# Git-Konfiguration global setzen
git config --global user.signingkey "$GIT_GPG_KEY_ID"
git config --global commit.gpgsign true
git config --global --add safe.directory "$GITHUB_WORKSPACE"
git config --global user.name "$GIT_COMMITTER_NAME"
git config --global user.email "$GIT_COMMITTER_EMAIL"

echo "Git und GPG erfolgreich für Container-Laufzeit konfiguriert (Key-ID: $GIT_GPG_KEY_ID)."
