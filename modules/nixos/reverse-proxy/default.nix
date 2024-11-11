{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  name = "reverse-proxy";
  namespace = "server";

  cfg = config.${namespace}.${name};
in {
  options.${namespace}.${name} = with types; {
    enable = mkEnableOption (mdDoc name);

    rootDomain = mkOption {
      type = str;
      default = "pelagrino.com";
      description = "The root domain for the server";
    };

    rootLocation = mkOption {
      type = path;
      default = "/var/www";
      description = "The root location for the server";
    };

    subDomains = mkOption {
      description = "The subdomains for the server";
      type = attrsOf (submodule {
        options = {
          name = mkOption {
            type = str;
            description = "The name of the subdomain";
          };
          location = mkOption {
            type = str;
            description = "The location for the subdomain";
          };
          proxyPass = mkOption {
            type = str;
            description = "The location to proxy pass to";
          };
          forceSSL = mkOption {
            type = bool;
            default = true;
            description = "Force SSL for the subdomain";
          };
        };
      });
      default = {
        meilisearch = {
          location = "/";
          proxyPass = "http://127.0.0.1:7700";
        };
        admin = {
          location = "/";
          proxyPass = "http://127.0.0.1:9000";
        };
        api = {
          location = "/";
          proxyPass = "http://127.0.0.1:9000";
        };
        cms = {
          location = "/";
          proxyPass = "http://strapi";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Configure certificate issuance
    security.acme = {
      acceptTerms = true;
      defaults.email = "it+acme@${cfg.rootDomain}";
      certs.${cfg.rootDomain} = {
        dnsProvider = "linode";
        extraDomainNames = map (key: "${key}.${cfg.rootDomain}") (builtins.attrNames cfg.subDomains);
      };
    };

    services = {
      # Enable PHP-FPM
      phpfpm.pools.${name} = {
        user = name;

        settings = {
          "listen.owner" = config.services.nginx.user;

          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.max_requests" = 500;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 5;

          "php_admin_value[error_log]" = "stderr";
          "php_admin_flag[log_errors]" = true;

          "catch_workers_output" = true;
        };

        phpEnv."PATH" = lib.makeBinPath [pkgs.php81];

        phpOptions = ''
          extension=${pkgs.php81Extensions.simplexml}/lib/php/extensions/simplexml.so
          extension=${pkgs.php81Extensions.redis}/lib/php/extensions/redis.so
          extension=${pkgs.php81Extensions.soap}/lib/php/extensions/soap.so
          extension=${pkgs.php81Extensions.pdo}/lib/php/extensions/pdo.so
          extension=${pkgs.php81Extensions.xml}/lib/php/extensions/xml.so
          extension=${pkgs.php81Extensions.zip}/lib/php/extensions/zip.so
        '';
      };

      # Enable Nginx
      nginx = {
        enable = true;
        recommendedOptimisation = true;
        recommendedGzipSettings = true;
        recommendedProxySettings = true;

        virtualHosts =
          {
            ${cfg.rootDomain} = {
              forceSSL = true;
              enableACME = true;
              serverAliases = ["www.${cfg.rootDomain}"];
              root = cfg.rootLocation;

              extraConfig = ''
                charset utf-8;

                add_header X-Frame-Options "SAMEORIGIN";
                add_header X-XSS-Protection "1; mode=block";
                add_header X-Content-Type-Options "nosniff";
              '';

              locations = {
                "/".tryFiles = "$url @proxy";
                "@proxy".proxyPass = "http://127.0.0.1:3000";
                "~ \\.php$".extraConfig = ''
                  fastcgi_index index.php;
                  fastcgi_split_path_info ^(.+\.php)(/.+)$;
                  fastcgi_pass unix:${config.services.phpfpm.pools.${name}.socket};
                  include ${pkgs.nginx}/conf/fastcgi.conf;
                '';
              };
            };
          }
          // lib.attrsets.mapAttrs' (name: value: (nameValuePair "${name}.${cfg.rootDomain}" {
            forceSSL = value.forceSSL;
            useACMEHost = cfg.rootDomain;
            locations."${value.location}".proxyPass = value.proxyPass;
          }))
          cfg.subDomains;
      };
    };
  };
}
