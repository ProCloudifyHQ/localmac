import Foundation

public struct NginxConfigGenerator {
    public static func config(for site: SiteConfig) -> String {
        """
        server {
            listen 80;
            server_name \(site.domain);
            return 301 https://$host$request_uri;
        }

        server {
            listen 443 ssl;
            http2 on;
            server_name \(site.domain);

            ssl_certificate     \(site.sslCertPath);
            ssl_certificate_key \(site.sslKeyPath);
            ssl_protocols       TLSv1.2 TLSv1.3;
            ssl_ciphers         HIGH:!aNULL:!MD5;

            root  \(site.rootPath);
            index index.php index.html;

            client_max_body_size 2048M;

            location / {
                try_files $uri $uri/ /index.php?$query_string;
            }

            location ~ \\.php$ {
                fastcgi_pass  unix:\(site.phpFpmSock);
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include       fastcgi_params;
                fastcgi_read_timeout 300;
            }

            location ~ /\\.ht {
                deny all;
            }

            access_log /opt/homebrew/var/log/nginx/\(site.domain)-access.log;
            error_log  /opt/homebrew/var/log/nginx/\(site.domain)-error.log;
        }
        """
    }
}

public struct SiteConfig {
    public let domain: String
    public let rootPath: String
    public let phpVersion: PHPVersion
    public let sslCertPath: String
    public let sslKeyPath: String

    public var phpFpmSock: String { phpVersion.fpmSockPath }

    public init(domain: String, rootPath: String, phpVersion: PHPVersion, sslCertPath: String, sslKeyPath: String) {
        self.domain      = domain
        self.rootPath    = rootPath
        self.phpVersion  = phpVersion
        self.sslCertPath = sslCertPath
        self.sslKeyPath  = sslKeyPath
    }
}
