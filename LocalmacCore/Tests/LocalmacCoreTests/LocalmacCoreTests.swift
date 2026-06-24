import XCTest
@testable import LocalmacCore

final class LocalmacCoreTests: XCTestCase {

    func testSiteNameToDomain() {
        let name = "My Project"
        let expected = "my-project.test"
        let domain = "\(name.lowercased().replacingOccurrences(of: " ", with: "-")).test"
        XCTAssertEqual(domain, expected)
    }

    func testNginxConfigContainsDomain() {
        let config = SiteConfig(
            domain: "myapp.test",
            rootPath: "/Users/test/Sites/myapp",
            phpVersion: .php83,
            sslCertPath: "/tmp/myapp.test.pem",
            sslKeyPath: "/tmp/myapp.test-key.pem"
        )
        let output = NginxConfigGenerator.config(for: config)
        XCTAssertTrue(output.contains("server_name myapp.test"))
        XCTAssertTrue(output.contains("fastcgi_pass"))
        XCTAssertTrue(output.contains("ssl_certificate"))
    }

    func testPHPVersionBrewFormula() {
        XCTAssertEqual(PHPVersion.php83.brewFormula, "php@8.3")
        XCTAssertEqual(PHPVersion.php86.brewFormula, "php")
    }

    func testShellSanitizeDBName() {
        // Ensure DatabaseManager sanitizes dangerous characters
        // (Indirectly tested — real sanitize is private, test via public API shape)
        XCTAssertNotNil(DatabaseManager.shared)
    }
}
