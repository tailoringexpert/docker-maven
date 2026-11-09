#!/bin/bash
set -e

if [ -z "$GNUPGHOME" ]; then
    echo "GNUPGHOME ist nicht gesetzt. Verwende Fallback-Verzeichnis..."
    export GNUPGHOME="/tmp/gpg-home"
fi

# Verzeichnis für GPG vorbereiten
mkdir -p "$GNUPGHOME"
chmod 700 "$GNUPGHOME"

echo "pinentry-mode loopback" > $GNUPGHOME/gpg.conf
echo "allow-loopback-pinentry" >$GNUPGHOME/gpg-agent.conf
chmod 600 "$GNUPGHOME"/*

# Check whether the Base64 variable exists
if [ -z "$MAVEN_GPG_SIGNKEY_BASE64" ]; then
  echo "Error: env var MAVEN_GPG_SIGNKEY_BASE64 is empty"
  exit 1
fi

# Prüfen, ob der Maven-Schlüssel übergeben wurde
export MAVEN_GPG_SIGNKEY=$(echo "$MAVEN_GPG_SIGNKEY_BASE64" | base64 --decode)
if [ -z "$MAVEN_GPG_SIGNKEY" ]; then
  echo "Error: MAVEN_GPG_SIGNKEY is empty!"
  exit 1
fi

# Import the GPG key directly from the environment variable and extract the ID 
# (Double quotes around $MAVEN_GPG_SIGNKEY are essential for line breaks)
MAVEN_GPG_KEYNAME=$(echo "$MAVEN_GPG_SIGNKEY" | gpg --homedir "$GNUPGHOME" --status-fd 1 --batch --import | awk '/\[GNUPG:\] IMPORT_OK/ {print $4}')
if [ -z "$MAVEN_GPG_KEYNAME" ]; then
  echo "Error: gpg keyname not imported!"
  exit 1
fi

export MAVEN_GPG_KEYNAME
echo "Maven and GPG successfully configured for the runtime container (MAVEN_GPG_KEYNAME: $MAVEN_GPG_KEYNAME)."
