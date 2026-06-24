cask "localmac" do
  version "1.0.0"
  sha256 :no_check

  url "https://github.com/ProCloudifyHQ/localmac/releases/download/v#{version}/Localmac-v#{version}.dmg"
  name "Localmac"
  desc "Free local web development environment for macOS"
  homepage "https://github.com/ProCloudifyHQ/localmac"

  depends_on macos: :ventura

  app "Localmac.app"

  uninstall quit: "com.localmac.app"

  zap trash: [
    "~/.localmac",
    "~/Library/Application Support/Localmac",
    "~/Library/Preferences/com.localmac.app.plist",
    "~/Library/Logs/Localmac",
    "~/Library/Saved Application State/com.localmac.app.savedState",
  ],
  rmdir: [
    "~/.localmac/certs",
    "~/.localmac/sites",
  ],
  script: {
    executable: "/bin/bash",
    args: ["-c", <<~EOS
      # Remove nginx site configs
      find /opt/homebrew/etc/nginx/servers -name "*.test.conf" -delete 2>/dev/null || true
      # Remove dnsmasq .test rule
      sed -i '' '/address=\/.test\/127.0.0.1/d' /opt/homebrew/etc/dnsmasq.conf 2>/dev/null || true
      # Remove DNS resolver
      sudo rm -f /etc/resolver/test 2>/dev/null || true
      # Reload services
      /opt/homebrew/bin/brew services restart dnsmasq 2>/dev/null || true
      /opt/homebrew/bin/brew services reload nginx 2>/dev/null || true
    EOS
    ],
  }
end
