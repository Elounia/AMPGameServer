#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0" >&2
  exit 1
fi

SRC="/home/tinyhost/Skrivebord/AppsDocker/AMPGameServer/conan-exiles-enhanced-template"
ADS="/home/amp/.ampdata/instances/ADS01"
TEMPLATE_BASE="$ADS/Plugins/ADSModule/DeploymentTemplates"
LOCAL_DIR="$TEMPLATE_BASE/Local-ConanEnhanced"
CUBE_DIR="$TEMPLATE_BASE/CubeCoders-AMPTemplates-main"
GENERIC_DIR="$ADS/Plugins/ADSModule/GenericTemplates"

files=(
  conan-exiles-enhanced.kvp
  conan-exiles-enhancedconfig.json
  conan-exiles-enhancedmetaconfig.json
  conan-exiles-enhancedports.json
  conan-exiles-enhancedupdates.json
)

install_to_dir() {
  local dst="$1"
  mkdir -p "$dst"
  for file in "${files[@]}"; do
    install -o amp -g amp -m 0644 "$SRC/$file" "$dst/$file"
  done
}

echo "Installing Conan Exiles Enhanced template into a separate local deployment template folder..."
install_to_dir "$LOCAL_DIR"

echo "Keeping a copy in GenericTemplates as well..."
install_to_dir "$GENERIC_DIR"

echo "Restarting ADS01 so it reloads deployment templates..."
runuser -u amp -- /usr/bin/ampinstmgr --RestartInstance ADS01

echo "Adding a post-restart copy beside the active CubeCoders template cache..."
install_to_dir "$CUBE_DIR"

echo "Installed files:"
find "$TEMPLATE_BASE" "$GENERIC_DIR" -maxdepth 2 -type f -name 'conan-exiles-enhanced*' -printf '  %p\n' | sort

echo
echo "Done. Refresh the AMP page, then open Create Instance and look for: Conan Exiles Enhanced"
