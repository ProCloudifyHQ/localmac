# Changelog

All notable changes to Localmac will be documented here.  
Format: [Keep a Changelog](https://keepachangelog.com) — versions follow [Semantic Versioning](https://semver.org).

---

## [Unreleased]

---

## [1.0.0] — 2026-06-25

### Added
- Menu-bar app with Sites, Services, Dashboard, and Settings tabs
- Multi-version PHP support (7.4, 8.1 → 8.6) with per-site switching
- Nginx web server with automatic SSL vhost configuration
- Apache web server with full `.htaccess` support
- MySQL / MariaDB database management
- PostgreSQL database support
- Redis + Memcached caching services
- Node.js multi-version support via fnm
- phpMyAdmin and Adminer database UIs
- Mailpit local email testing
- Trusted HTTPS via mkcert for all local sites
- Automatic `*.test` domain resolution via dnsmasq
- ionCube Loader built-in for all PHP versions (WHMCS / Blesta support)
- 2GB upload limit configured out of the box
- WordPress one-click setup (auto DB + download + wp-config)
- Laravel one-click setup (composer create-project + .env)
- Live system dashboard — CPU, RAM, Disk, Network
- In-app update checker with changelog display
- Launch at login via SMAppService
- Auto-update via Homebrew (`brew upgrade --cask localmac`)
- GitHub Releases DMG for manual installation

[Unreleased]: https://github.com/ProCloudifyHQ/localmac/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/ProCloudifyHQ/localmac/releases/tag/v1.0.0
