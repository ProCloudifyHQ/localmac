# Localmac

> A free, open-source local web development environment for macOS — a powerful alternative to ServBay and Laravel Herd.

![macOS](https://img.shields.io/badge/macOS-13%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![License](https://img.shields.io/github/license/ProCloudifyHQ/localmac)
![Release](https://img.shields.io/github/v/release/ProCloudifyHQ/localmac)

---

## What is Localmac?

Localmac is a native macOS menu-bar app that gives you a complete local web development stack — fully free, fully open-source, fully under your control. No subscriptions, no limits.

---

## Features

| Feature | Details |
|---|---|
| **PHP** | 7.4, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6 — switch per site |
| **Web Servers** | Nginx + Apache (full `.htaccess` support) |
| **Databases** | MySQL / MariaDB + PostgreSQL |
| **Cache** | Redis + Memcached |
| **Node.js** | Multi-version via fnm |
| **Tools** | phpMyAdmin · Adminer · Mailpit |
| **SSL** | Trusted HTTPS via mkcert |
| **Domains** | Automatic `*.test` local domains |
| **ionCube** | Built-in loader for WHMCS / Blesta |
| **Upload limit** | Up to 2GB |
| **WordPress** | One-click: auto DB + download + wp-config |
| **Laravel** | One-click: composer create-project + .env |
| **Dashboard** | Live CPU / RAM / Disk / Network stats |
| **Updates** | In-app update checker + Homebrew support |
| **Auto-start** | Launches at login, no password prompts |

---

## Installation

### Via Homebrew (recommended)

```bash
brew tap ProCloudifyHQ/localmac
brew install --cask localmac
```

### Direct Download

Download the latest `.dmg` from [GitHub Releases](https://github.com/ProCloudifyHQ/localmac/releases).

1. Open the `.dmg`
2. Drag **Localmac.app** to your Applications folder
3. Open it — if macOS shows a security warning, go to **System Settings → Privacy & Security → Open Anyway**

---

## Requirements

- macOS 13.0 Ventura or later
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- [Homebrew](https://brew.sh) — installed automatically if missing

---

## Updating

### In-app
Click the Localmac menu-bar icon → **Check for Updates**

### Via Homebrew
```bash
brew upgrade --cask localmac
```

---

## One-Click WordPress Setup

1. Click **+** in the Sites tab
2. Enter a site name (e.g. `myshop`)
3. Select **WordPress** as the type
4. Choose your PHP version
5. Click **Create Site**

Localmac will automatically:
- Create the database
- Download the latest WordPress
- Write `wp-config.php`
- Set up SSL and the `.test` domain
- Open the site in your browser

---

## Services Managed

| Service | Purpose |
|---|---|
| Nginx / Apache | Web server |
| MySQL / MariaDB | Relational database |
| PostgreSQL | Relational database |
| Redis | In-memory cache |
| Memcached | In-memory cache |
| Mailpit | Local email testing |
| dnsmasq | `*.test` DNS resolution |

---

## Building from Source

```bash
git clone https://github.com/ProCloudifyHQ/localmac.git
cd localmac

# Generate Xcode project
brew install xcodegen
xcodegen generate

# Open in Xcode
open Localmac.xcodeproj
```

> Swift 5.9+ and Xcode 16+ required.

---

## Project Structure

```
Localmac/
├── Localmac/          # SwiftUI menu-bar app
├── LocalmacCore/      # Swift Package — service engine
├── .github/workflows/ # CI + release pipeline
├── Formula/           # Homebrew cask
└── Installer/         # Build & signing config
```

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

1. Fork the repo
2. Create your branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

MIT — see [LICENSE](LICENSE)

---

<p align="center">Built with ❤️ by <a href="https://github.com/ProCloudifyHQ">ProCloudifyHQ</a></p>
