#!/bin/bash
set -e

# Verzeichnis für GPG vorbereiten
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
echo "pinentry-mode loopback" > ~/.gnupg/gpg.conf
echo "allow-loopback-pinentry" > ~/.gnupg/gpg-agent.conf
chmod 600 ~/.gnupg/*

# Prüfen, ob der Maven-Schlüssel übergeben wurde
if [ -z "$MAVEN_GPG_SIGNKEY" ]; then
  echo "Fehler: MAVEN_GPG_SIGNKEY ist leer! Prüfe die container.env-Konfiguration."
  exit 1
fi

# GPG-Schlüssel direkt aus der Umgebungsvariable importieren und ID extrahieren
# (Double-Quotes um $MAVEN_GPG_SIGNKEY sind zwingend erforderlich für die Zeilenumbrüche)
MAVEN_GPG_KEY_ID=$(echo "$MAVEN_GPG_SIGNKEY" | gpg --status-fd 1 --batch --import | awk '/\[GNUPG:\] IMPORT_OK/ {print $4}')

echo "Exakte Maven GPG-ID: $MAVEN_GPG_KEY_ID"

if [ -z "$MAVEN_GPG_KEY_ID" ]; then
  echo "Fehler: Der Maven-Schlüssel konnte nicht importiert werden!"
  exit 1
fi

# Optional: ID für nachfolgende Maven-Schritte im Skript/Prozess bereitstellen
export MAVEN_GPG_KEY_ID
