#!/usr/bin/env bash
set -euo pipefail

# =============================
# GOOGLE ANTIGRAVITY INSTALLER
# Arch / Garuda / Manjaro
# Fully automated (dunst included)
# =============================

APT_BASE="https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev"
PKG_INDEX_URL="${APT_BASE}/dists/antigravity-debian/main/binary-amd64/Packages"

# =============================
# CONFIGURABLE INSTALL PATHS
# =============================
# You can override these paths using environment variables:
#   ANTIGRAVITY_APP_DIR    - Application installation directory
#   ANTIGRAVITY_BIN_DIR    - Binary symlink directory
#   ANTIGRAVITY_DESKTOP_DIR - Desktop files directory
#   ANTIGRAVITY_ICON_DIR   - Icon files directory
#
# Example: ANTIGRAVITY_APP_DIR="/home/user/apps/antigravity" ./arch_antigravity_yashuu.sh
# =============================

APP_DIR="${ANTIGRAVITY_APP_DIR:-/opt/antigravity}"
BIN_DIR="${ANTIGRAVITY_BIN_DIR:-/usr/local/bin}"
DESKTOP_DIR="${ANTIGRAVITY_DESKTOP_DIR:-/usr/share/applications}"
ICON_DIR="${ANTIGRAVITY_ICON_DIR:-/usr/share/pixmaps}"

BIN_LINK="${BIN_DIR}/antigravity"
DESKTOP1="${DESKTOP_DIR}/antigravity.desktop"
DESKTOP2="${DESKTOP_DIR}/antigravity-url-handler.desktop"
ICON_PATH="${ICON_DIR}/antigravity.png"

# =============================
# VALIDATE PATHS
# =============================
echo "[*] Using installation paths:"
echo "    APP_DIR: $APP_DIR"
echo "    BIN_LINK: $BIN_LINK"
echo "    DESKTOP_DIR: $DESKTOP_DIR"
echo "    ICON_DIR: $ICON_DIR"
echo

# =============================
# UNINSTALL
# =============================
if [[ "${1-}" == "--uninstall" ]]; then
  echo "[*] Uninstalling Antigravity..."
  sudo rm -rf "$APP_DIR" "$BIN_LINK" "$DESKTOP1" "$DESKTOP2" "$ICON_PATH"
  rm -f ~/.config/autostart/dunst.desktop || true
  echo "[+] Removed."
  exit 0
fi

# =============================
# SYSTEM UPDATE (NEW)
# =============================
echo "[*] Updating system packages..."
sudo pacman -Syu --noconfirm
echo "[+] System updated successfully."

# =============================
# DEPENDENCIES (with dunst)
# =============================
echo "[*] Installing required dependencies (libnotify + dunst + chromium libs)..."
sudo pacman -Sy --needed --noconfirm \
  curl bsdtar libnotify dunst nss gtk3 libcups libxss || true

# =============================
# DUNST AUTOSTART FIX
# (solves the Antigravity freeze)
# =============================
echo "[*] Setting up notification daemon (dunst)..."

mkdir -p ~/.config/autostart

cat > ~/.config/autostart/dunst.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Dunst
Exec=dunst
StartupNotify=false
Terminal=false
EOF

# Start dunst instantly if not running
if ! pgrep -x dunst >/dev/null; then
  echo "[*] Starting dunst..."
  dunst &
  sleep 1
fi

echo "[+] Dunst enabled and running"

# =============================
# FETCH PACKAGE INDEX
# =============================
echo "[*] Fetching APT package index..."
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"

curl -fsSL "$PKG_INDEX_URL" -o Packages

# =============================
# PARSE LATEST VERSION
# =============================
echo "[*] Parsing latest Antigravity version..."

read -r DEBVER DEBFILENAME DEBSHA256 <<< "$(
  awk '
    BEGIN { pkg=""; ver=""; file=""; sha="" }
    /^Package: antigravity$/ { pkg="antigravity"; next }
    pkg=="antigravity" && /^Version:/ { ver=$2 }
    pkg=="antigravity" && /^Filename:/ { file=$2 }
    pkg=="antigravity" && /^SHA256:/ { sha=$2 }
    NF==0 && pkg=="antigravity" { print ver, file, sha; exit }
  ' Packages
)"

[[ -z "$DEBVER" ]] && { echo "[-] Failed to parse version."; exit 1; }

echo "[+] Latest version: $DEBVER"
echo "[+] File: $DEBFILENAME"

# =============================
# DOWNLOAD + VERIFY
# =============================
DEB_URL="${APT_BASE}/${DEBFILENAME}"
echo "[*] Downloading package..."
curl -fsSL "$DEB_URL" -o antigravity.deb

echo "[*] Verifying SHA256 checksum..."
echo "${DEBSHA256}  antigravity.deb" | sha256sum -c -

# =============================
# EXTRACT + INSTALL
# =============================
echo "[*] Extracting package..."
bsdtar -xf antigravity.deb
bsdtar -xf data.tar.xz

echo "[*] Installing to $APP_DIR..."
sudo rm -rf "$APP_DIR"
sudo mkdir -p "$APP_DIR"
sudo cp -r usr/share/antigravity/* "$APP_DIR/"

# =============================
# SANDBOX FIX
# =============================
if [[ -f "$APP_DIR/chrome-sandbox" ]]; then
  echo "[*] Fixing sandbox permissions..."
  sudo chown root:root "$APP_DIR/chrome-sandbox"
  sudo chmod 4755 "$APP_DIR/chrome-sandbox"
fi

# =============================
# BINARY LINK
# =============================
echo "[*] Creating launcher..."
sudo mkdir -p "$BIN_DIR"
sudo ln -sf "$APP_DIR/antigravity" "$BIN_LINK"

# =============================
# DESKTOP FILES
# =============================
echo "[*] Installing desktop entries..."
sudo mkdir -p "$DESKTOP_DIR"

if [[ -f usr/share/applications/antigravity.desktop ]]; then
  sed "s|^Exec=.*|Exec=${BIN_LINK} %U|g" \
    usr/share/applications/antigravity.desktop | sudo tee "$DESKTOP1" >/dev/null
fi

if [[ -f usr/share/applications/antigravity-url-handler.desktop ]]; then
  sed "s|^Exec=.*|Exec=${BIN_LINK} %U|g" \
    usr/share/applications/antigravity-url-handler.desktop | sudo tee "$DESKTOP2" >/dev/null
fi

# =============================
# ICON
# =============================
if [[ -f usr/share/pixmaps/antigravity.png ]]; then
  sudo mkdir -p "$ICON_DIR"
  sudo cp usr/share/pixmaps/antigravity.png "$ICON_PATH"
fi

# =============================
# DONE
# =============================
echo
echo "[+] Antigravity $DEBVER installed successfully!"
echo "[+] Notification daemon fixed (dunst auto-start enabled)"
echo "[*] Run app using: antigravity"
echo "[*] Uninstall using: ./antigravity-installer.sh --uninstall"

# =============================
# RESTART PROMPT (NEW)
# =============================
echo
echo "======================================================="
echo "  Installation completed!"
echo "  It is recommended to RESTART your system now "
echo "  to ensure all sandbox + notification services load."
echo "======================================================="
echo
read -p "Do you want to restart now? (y/N): " ans
if [[ "$ans" == "y" || "$ans" == "Y" ]]; then
  echo "[*] Restarting system..."
  sudo reboot
else
  echo "[*] Restart skipped. You can reboot later."
fi
