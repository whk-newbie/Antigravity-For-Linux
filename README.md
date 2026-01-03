# Google Antigravity Installer (Arch/Garuda/Manjaro)

This script automates the installation of **Google Antigravity** on Arch Linux based distributions (Arch, Garuda, Manjaro). It handles dependency installation, package verification, and system configuration fixes.

## Features

- **Automated Installation**: Fetches the latest version from the repository, verifies the SHA256 checksum, and installs it.
- **Dependency Management**: Automatically installs required dependencies including `libnotify`, `dunst`, `nss`, `gtk3`, `libcups`, and `libxss`.
- **Dunst Configuration**: Sets up and starts `dunst` to fix notification-related freezes.
- **Sandbox Fix**: Automatically fixes `chrome-sandbox` permissions.
- **Desktop Integration**: Installs desktop entries and icons for full system integration.
- **Configurable Install Paths**: Customize installation directories using environment variables.

## Usage

1.  **Make the script executable:**
    ```bash
    chmod +x arch_antigravity_yashuu.sh
    ```

2.  **Run the installer:**
    ```bash
    ./arch_antigravity_yashuu.sh
    ```

3.  **Follow the prompts:**
    - The script will update your system and install dependencies.
    - At the end, you will be prompted to restart your system to ensure all services load correctly.

## Custom Installation Paths

You can customize the installation paths using environment variables. The script will display the paths it will use before installation.

### Available Environment Variables

- `ANTIGRAVITY_APP_DIR` - Application installation directory (default: `/opt/antigravity`)
- `ANTIGRAVITY_BIN_DIR` - Binary symlink directory (default: `/usr/local/bin`)
- `ANTIGRAVITY_DESKTOP_DIR` - Desktop files directory (default: `/usr/share/applications`)
- `ANTIGRAVITY_ICON_DIR` - Icon files directory (default: `/usr/share/pixmaps`)

### Examples

**Install to custom user directory:**
```bash
ANTIGRAVITY_APP_DIR="/home/user/apps/antigravity" \
ANTIGRAVITY_BIN_DIR="/home/user/.local/bin" \
./arch_antigravity_yashuu.sh
```

**Install to custom system directory:**
```bash
ANTIGRAVITY_APP_DIR="/opt/custom/antigravity" \
./arch_antigravity_yashuu.sh
```

**Using exported environment variables:**
```bash
export ANTIGRAVITY_APP_DIR="/opt/custom/antigravity"
export ANTIGRAVITY_BIN_DIR="/usr/local/bin"
./arch_antigravity_yashuu.sh
```

## Uninstallation

To completely remove Antigravity and clean up associated files:

```bash
./arch_antigravity_yashuu.sh --uninstall
```

This will remove:
- The application directory (default: `/opt/antigravity`, or custom path if configured)
- The binary link (default: `/usr/local/bin/antigravity`, or custom path if configured)
- Desktop entries and icons
- The `dunst` autostart entry

**Note:** If you used custom installation paths, make sure to use the same environment variables when uninstalling, or manually specify the paths.

## Disclaimer

This script is specifically designed for **Arch Linux** and its derivatives (Garuda, Manjaro). It uses `pacman` for package management. Do not run this on Debian/Ubuntu based systems.
