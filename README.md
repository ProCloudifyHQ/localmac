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

| | |
|---|---|
| **macOS** | 13.0 Ventura or later |
| **Mac** | Apple Silicon (M1/M2/M3/M4) or Intel |
| **Homebrew** | Installed automatically if missing |

---

## Install via Homebrew

```bash
brew tap ProCloudifyHQ/localmac
brew trust ProCloudifyHQ/localmac
brew install --cask localmac
```

> **macOS Gatekeeper warning after install?** Run this once:
> ```bash
> xattr -dr com.apple.quarantine /Applications/Localmac.app
> ```

---

## Install Manually (DMG)

1. Download the latest `.dmg` from [GitHub Releases](https://github.com/ProCloudifyHQ/localmac/releases)
2. Open the `.dmg` and drag **Localmac.app** to Applications
3. Launch from Applications

> **"Apple could not verify Localmac is free of malware"?**
>
> This appears because Localmac is free & open-source and not signed with a paid Apple Developer certificate ($99/yr). The app is safe — you can read every line of source code in this repo.
>
> **Fix — choose one:**
>
> **Option A — Terminal (easiest):**
> ```bash
> xattr -dr com.apple.quarantine /Applications/Localmac.app
> ```
>
> **Option B — System Settings:**
> Go to **System Settings → Privacy & Security** → scroll down → click **"Open Anyway"**
>
> **Option C — Right-click:**
> Right-click `Localmac.app` in Applications → **Open** → **Open** again in the dialog

---

## Update via Homebrew

```bash
brew upgrade --cask localmac
```

## Update via In-App

Click the menu-bar icon → **Check for Updates** — shows changelog and a download button.

---

## Uninstall via Homebrew

Keeps your site files and databases:

```bash
brew uninstall --cask --zap localmac
```

---

## Uninstall Manually

Keeps your site files and databases:

```bash
curl -fsSL https://raw.githubusercontent.com/ProCloudifyHQ/localmac/main/Installer/uninstall.sh | bash
```

Select **mode 1** when prompted.

---

## Uninstall Everything (Sites + Databases)

> ⚠️ **Warning:** Permanently deletes all site files and databases. Cannot be undone.

```bash
curl -fsSL https://raw.githubusercontent.com/ProCloudifyHQ/localmac/main/Installer/uninstall.sh | bash
```

Select **mode 2** and type `DELETE` to confirm.

**What mode 2 removes:**

| Item | Removed |
|---|---|
| Localmac.app | ✅ |
| Config, SSL certs (`~/.localmac`) | ✅ |
| Preferences & logs | ✅ |
| Nginx site configs | ✅ |
| dnsmasq `.test` rule | ✅ |
| Homebrew tap | ✅ |
| All files in `~/Sites` | ✅ |
| All MySQL / MariaDB databases | ✅ |
| All PostgreSQL databases | ✅ |
| PHP, Nginx, MySQL services | ❌ Kept |
| System databases | ❌ Kept |

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
