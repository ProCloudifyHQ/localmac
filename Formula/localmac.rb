cask "localmac" do
  version "1.0.0"
  sha256 "PLACEHOLDER_WILL_BE_UPDATED_BY_CI"

  url "https://github.com/ProCloudifyHQ/localmac/releases/download/v#{version}/Localmac-v#{version}.dmg"
  name "Localmac"
  desc "Free local web development environment for macOS"
  homepage "https://github.com/ProCloudifyHQ/localmac"

  depends_on macos: ">= :ventura"

  app "Localmac.app"

  zap trash: [
    "~/.localmac",
    "~/Library/Application Support/Localmac",
    "~/Library/Preferences/com.localmac.app.plist",
    "~/Library/Logs/Localmac",
  ]
end
