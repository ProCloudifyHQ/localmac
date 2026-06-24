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
| **Updates** | In-app update checker + changelog display |
| **Auto-start** | Launches at login, no password prompts |

---

## Requirements

| Requirement | Details |
|---|---|
| **macOS** | 13.0 Ventura or later |
| **Architecture** | Apple Silicon (M1/M2/M3/M4) or Intel |
| **Homebrew** | Installed automatically if missing |

---

## Installation

### Option 1 — Homebrew (Recommended)

| Step | Command |
|---|---|
| 1. Add tap | `brew tap ProCloudifyHQ/localmac` |
| 2. Install | `brew install --cask localmac` |

```bash
brew tap ProCloudifyHQ/localmac
brew install --cask localmac
```

---

### Option 2 — Direct Download

| Step | Action |
|---|---|
| 1. Download | Get the latest `.dmg` from [GitHub Releases](https://github.com/ProCloudifyHQ/localmac/releases) |
| 2. Open | Double-click the `.dmg` file |
| 3. Install | Drag **Localmac.app** → Applications folder |
| 4. Open | Launch from Applications |

> **macOS security warning?** Since Localmac is free & open-source (not signed with a paid Apple certificate), macOS may show an "unidentified developer" warning on first launch.
>
> **Fix:** Go to **System Settings → Privacy & Security → Open Anyway**

---

## Updating

| Method | Command |
|---|---|
| **In-app** | Click menu-bar icon → **Check for Updates** — shows changelog and download button |
| **Homebrew** | `brew upgrade --cask localmac` |

---

## Uninstall

Two modes available — choose based on what you want to keep.

### Standard Uninstall — keeps your site files and databases

| Method | Command |
|---|---|
| **Homebrew** | `brew uninstall --cask --zap localmac` |
| **Manual / curl** | `curl -fsSL https://raw.githubusercontent.com/ProCloudifyHQ/localmac/main/Installer/uninstall.sh \| bash` |
| **Local script** | `bash Installer/uninstall.sh` |

```bash
# If installed via Homebrew
brew uninstall --cask --zap localmac
```

```bash
# If installed manually (or works for both)
curl -fsSL https://raw.githubusercontent.com/ProCloudifyHQ/localmac/main/Installer/uninstall.sh | bash
```

**What gets removed:**

| Item | Removed? |
|---|---|
| Localmac.app | ✅ |
| `~/.localmac` (config + SSL certs) | ✅ |
| Preferences & logs | ✅ |
| Nginx site configs (`*.test.conf`) | ✅ |
| dnsmasq `.test` rule | ✅ |
| `/etc/resolver/test` | ✅ |
| Homebrew tap | ✅ |
| Launch at login entry | ✅ |
| `~/Sites` files | ❌ Kept |
| MySQL / MariaDB databases | ❌ Kept |
| PostgreSQL databases | ❌ Kept |
| PHP, Nginx, MySQL services | ❌ Kept |

---

### Complete Uninstall — removes everything including sites and databases

> ⚠️ **Warning:** This permanently deletes all your site files and databases. This cannot be undone.

Run the uninstall script and select **mode 2** when prompted:

```bash
curl -fsSL https://raw.githubusercontent.com/ProCloudifyHQ/localmac/main/Installer/uninstall.sh | bash
```

Type `DELETE` when prompted to confirm.

**What gets removed (in addition to Standard):**

| Item | Removed? |
|---|---|
| Everything in Standard Uninstall | ✅ |
| All files in `~/Sites` | ✅ |
| All MySQL / MariaDB user databases | ✅ |
| All PostgreSQL user databases | ✅ |
| System databases (`mysql`, `postgres`, etc.) | ❌ Never touched |
| Homebrew, PHP, Nginx, MySQL services | ❌ Never touched |

---

## One-Click WordPress Setup

| Step | Action |
|---|---|
| 1 | Click **+** in the Sites tab |
| 2 | Enter a site name (e.g. `myshop`) |
| 3 | Select **WordPress** as the type |
| 4 | Choose your PHP version |
| 5 | Click **Create Site** |

Localmac automatically downloads WordPress, creates the database, writes `wp-config.php`, sets up SSL and the `.test` domain. Open the URL in your browser and set your site title and admin account — done.

---

## Building from Source

| Requirement | Install |
|---|---|
| Xcode 16+ | [Mac App Store](https://apps.apple.com/app/xcode/id497799835) |
| xcodegen | `brew install xcodegen` |

```bash
git clone https://github.com/ProCloudifyHQ/localmac.git
cd localmac
brew install xcodegen
xcodegen generate
open Localmac.xcodeproj
```

---

## Project Structure

```
Localmac/
├── Localmac/           # SwiftUI menu-bar app
├── LocalmacCore/       # Swift Package — service engine
├── .github/workflows/  # CI + release pipeline
├── Installer/          # build-dmg.sh · uninstall.sh · ExportOptions
├── Formula/            # Homebrew cask formula
└── CHANGELOG.md        # Full version history
```

---

## Contributing

| Step | Command |
|---|---|
| 1. Fork | Click **Fork** on GitHub |
| 2. Branch | `git checkout -b feature/my-feature` |
| 3. Commit | `git commit -m 'feat: add my feature'` |
| 4. Push | `git push origin feature/my-feature` |
| 5. PR | Open a Pull Request on GitHub |

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for full version history.

---

## License

MIT — see [LICENSE](LICENSE)

---

<p align="center">Built with ❤️ by <a href="https://github.com/ProCloudifyHQ">ProCloudifyHQ</a></p>
