import Foundation

public actor WordPressInstaller {
    public static let shared = WordPressInstaller()

    public func install(at path: String, domain: String, dbName: String) async throws {
        // 1. Download latest WordPress
        let result = await Shell.run("""
            curl -fsSL https://wordpress.org/latest.tar.gz | tar -xz -C '\(path)' --strip-components=1
        """)
        if !result.succeeded { throw LocalmacError.wordpressInstallFailed(result.error) }

        // 2. Create database
        try await DatabaseManager.shared.createDatabase(dbName)

        // 3. Write wp-config.php
        let wpConfig = generateWPConfig(dbName: dbName, domain: domain)
        try wpConfig.write(toFile: "\(path)/wp-config.php", atomically: true, encoding: .utf8)
    }

    private func generateWPConfig(dbName: String, domain: String) -> String {
        return """
        <?php
        define('DB_NAME',     '\(dbName)');
        define('DB_USER',     'root');
        define('DB_PASSWORD', '');
        define('DB_HOST',     '127.0.0.1');
        define('DB_CHARSET',  'utf8mb4');
        define('DB_COLLATE',  '');

        define('AUTH_KEY',         '\(UUID().uuidString)');
        define('SECURE_AUTH_KEY',  '\(UUID().uuidString)');
        define('LOGGED_IN_KEY',    '\(UUID().uuidString)');
        define('NONCE_KEY',        '\(UUID().uuidString)');
        define('AUTH_SALT',        '\(UUID().uuidString)');
        define('SECURE_AUTH_SALT', '\(UUID().uuidString)');
        define('LOGGED_IN_SALT',   '\(UUID().uuidString)');
        define('NONCE_SALT',       '\(UUID().uuidString)');

        $table_prefix = 'wp_';

        define('WP_DEBUG',     false);
        define('WP_HOME',      'https://\(domain)');
        define('WP_SITEURL',   'https://\(domain)');

        if ( ! defined( 'ABSPATH' ) ) {
            define( 'ABSPATH', __DIR__ . '/' );
        }
        require_once ABSPATH . 'wp-settings.php';
        """
    }
}
