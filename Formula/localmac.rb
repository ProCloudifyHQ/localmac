cask "localmac" do
  version "1.0.0"
  sha256 "210c46095451492fde9d6a1dbc3c0fbf5e98b6a43ec5cad33bbdbba5f3c78643"

  url "https://github.com/ProCloudifyHQ/localmac/releases/download/v#{version}/Localmac-v#{version}.dmg"
  name "Localmac"
  desc "Free local web development environment for macOS"
  homepage "https://github.com/ProCloudifyHQ/localmac"

  depends_on macos: :ventura

  app "Localmac.app"

  # Automatically remove quarantine so Gatekeeper doesn't block the unsigned app
  postflight do
    system_command "/usr/bin/xattr",
      args: ["-dr", "com.apple.quarantine", "#{appdir}/Localmac.app"],
      sudo: false
  end

  uninstall quit: "com.localmac.app"

  zap trash: [
    "~/.localmac",
    "~/Library/Application Support/Localmac",
    "~/Library/Preferences/com.localmac.app.plist",
    "~/Library/Logs/Localmac",
    "~/Library/Saved Application State/com.localmac.app.savedState",
  ],
  script: {
    executable: "/bin/bash",
    args: ["-c", <<~EOS
      find /opt/homebrew/etc/nginx/servers -name "*.test.conf" -delete 2>/dev/null || true
      sed -i '' '/address=\/.test\/127.0.0.1/d' /opt/homebrew/etc/dnsmasq.conf 2>/dev/null || true
      sudo rm -f /etc/resolver/test 2>/dev/null || true
      /opt/homebrew/bin/brew services restart dnsmasq 2>/dev/null || true
      /opt/homebrew/bin/brew services reload nginx 2>/dev/null || true
    EOS
    ],
  }

  caveats <<~EOS
    Localmac is open-source and not signed with an Apple Developer certificate.
    The postflight script has already removed the macOS quarantine flag for you.
    If you still see a security warning, run:
      xattr -dr com.apple.quarantine /Applications/Localmac.app
  EOS
end
