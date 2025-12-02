# Google Antigravity Installer (Arch/Garuda/Manjaro)

This script automates the installation of **Google Antigravity** on Arch Linux based distributions (Arch, Garuda, Manjaro). It handles dependency installation, package verification, and system configuration fixes.

## Features

- **Automated Installation**: Fetches the latest version from the repository, verifies the SHA256 checksum, and installs it.
- **Dependency Management**: Automatically installs required dependencies including `libnotify`, `dunst`, `nss`, `gtk3`, `libcups`, and `libxss`.
- **Dunst Configuration**: Sets up and starts `dunst` to fix notification-related freezes.
- **Sandbox Fix**: Automatically fixes `chrome-sandbox` permissions.
- **Desktop Integration**: Installs desktop entries and icons for full system integration.

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

## Uninstallation

To completely remove Antigravity and clean up associated files:

```bash
./arch_antigravity_yashuu.sh --uninstall
```

This will remove:
- The application directory (`/opt/antigravity`)
- The binary link (`/usr/local/bin/antigravity`)
- Desktop entries and icons
- The `dunst` autostart entry

## Disclaimer

This script is specifically designed for **Arch Linux** and its derivatives (Garuda, Manjaro). It uses `pacman` for package management. Do not run this on Debian/Ubuntu based systems.
