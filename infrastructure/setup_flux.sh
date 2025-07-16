#!/bin/bash

set -e

echo "📦 Installing Flux CLI..."
export GIT_USER="<fill-in>"
export GIT_TOKEN="<fill-in>"  # Gebruik je echte token hier (niet in plain text opslaan!)
export APP_REPO="<fill-in>"

# Controleer eerst of sudo zonder wachtwoord kan
if sudo -n true 2>/dev/null; then
  curl -s https://fluxcd.io/install.sh | sudo bash
else
  echo "❌ Error: Sudo access zonder wachtwoord is vereist om Flux CLI te installeren in /usr/local/bin."
  echo "ℹ️  Tip: Voeg je gebruiker toe aan /etc/sudoers met NOPASSWD, of installeer Flux handmatig."
  exit 1
fi

echo "🚀 Bootstrapping FluxCD..."
flux bootstrap gitlab \
  --hostname=gitlab.com \
  --owner=<fill-in> \
  --repository=architectuur \
  --branch=main \
  --path=clusters/app-cluster \
  --personal \
  --deploy-token-auth