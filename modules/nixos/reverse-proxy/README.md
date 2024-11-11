# Reverse Proxy Server Configuration

This NixOS module configures a reverse proxy server with Nginx and PHP-FPM. It provides options to enable and configure the server settings, including certificate issuance using ACME.

## Options

### `enable`

- **Type:** `boolean`
- **Default:** `false`
- **Description:** Enable the reverse proxy server configuration.

### `rootDomain`

- **Type:** `string`
- **Default:** `pelagrino.com`
- **Description:** The root domain for the server.

### `rootLocation`

- **Type:** `path`
- **Default:** `/var/www`
- **Description:** The root location for the server.

### `subDomains`

- **Type:** `attribute set of submodules`
- **Default:**

  ```nix
  {
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
  }
  ```

- **Description:** The subdomains for the server.

## Configuration

When the `enable` option is set to `true`, the following configurations are applied:

### Certificate Issuance

- **Accept ACME terms:** `acceptTerms = true`
- **Default email for ACME:** `defaults.email = "it+acme@${cfg.rootDomain}"`
- **Certificate configuration for the root domain:**
  - **DNS provider:** `dnsProvider = "linode"`
  - **Extra domain names:** `extraDomainNames = map (key: "${key}.${cfg.rootDomain}") (builtins.attrNames cfg.subDomains)`

### Services

#### PHP-FPM

- **Enable PHP-FPM pool for the server:**
  - **User:** `user = name`
  - **Settings:**
    - `listen.owner = config.services.nginx.user`
    - `pm = "dynamic"`
    - `pm.max_children = 32`
    - `pm.max_requests = 500`
    - `pm.start_servers = 2`
    - `pm.min_spare_servers = 2`
    - `pm.max_spare_servers = 5`
    - `php_admin_value[error_log] = "stderr"`
    - `php_admin_flag[log_errors] = true`
    - `catch_workers_output = true`
  - **PHP environment path:** `phpEnv."PATH" = lib.makeBinPath [pkgs.php81]`
  - **PHP options:**

    ```nix
    extension=${pkgs.php81Extensions.simplexml}/lib/php/extensions/simplexml.so
    extension=${pkgs.php81Extensions.redis}/lib/php/extensions/redis.so
    extension=${pkgs.php81Extensions.soap}/lib/php/extensions/soap.so
    extension=${pkgs.php81Extensions.pdo}/lib/php/extensions/pdo.so
    extension=${pkgs.php81Extensions.xml}/lib/php/extensions/xml.so
    extension=${pkgs.php81Extensions.zip}/lib/php/extensions/zip.so
    ```

#### Nginx

- **Enable Nginx:** `enable = true`
- **Recommended settings:**
  - `recommendedOptimisation = true`
  - `recommendedGzipSettings = true`
  - `recommendedProxySettings = true`
- **Virtual hosts:**
  - **Root domain:**
    - `forceSSL = true`
    - `enableACME = true`
    - `serverAliases = ["www.${cfg.rootDomain}"]`
    - `root = cfg.rootLocation`
    - **Extra configuration:**

      ```nginx
      charset         utf-8;
      add_header X-Frame-Options "SAMEORIGIN";
      add_header X-XSS-Protection "1; mode=block";
      add_header X-Content-Type-Options "nosniff";
      ```

    - **Locations:**
      - `"/".tryFiles = "$url @proxy"`
      - `"@proxy".proxyPass = "http://127.0.0.1:3000"`
      - `"~ \\.php$".extraConfig =`

        ```nginx
        fastcgi_index index.php;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:${config.services.phpfpm.pools.${name}.socket};
        include ${pkgs.nginx}/conf/fastcgi.conf;
        ```

  - **Subdomains:**
    - `meilisearch.${cfg.rootDomain}`:
      - `forceSSL = true`
      - `useACMEHost = cfg.rootDomain`
      - `locations."/".proxyPass = "http://127.0.0.1:7700"`
    - `admin.${cfg.rootDomain}`:
      - `forceSSL = true`
      - `useACMEHost = cfg.rootDomain`
      - `locations."/".proxyPass = "http://127.0.0.1:9000"`
    - `api.${cfg.rootDomain}`:
      - `forceSSL = true`
      - `useACMEHost = cfg.rootDomain`
      - `locations."/".proxyPass = "http://127.0.0.1:9000"`
    - `cms.${cfg.rootDomain}`:
      - `forceSSL = true`
      - `useACMEHost = cfg.rootDomain`
      - `locations."/".proxyPass = "http://strapi"`

## Usage

To use this module, include it in your NixOS configuration and set the desired options. For example:

```nix
{
  imports = [
    outputs.nixosModules.reverse-proxy
  ];

  server.reverse-proxy.enable = true;
  server.reverse-proxy.rootDomain = "example.com";
  server.reverse-proxy.rootLocation = "/srv/www";
  server.reverse-proxy.subDomains = {
    blog = {
      location = "/";
      proxyPass = "http://127.0.0.1:4000";
    };
    shop = {
      location = "/";
      proxyPass = "http://127.0.0.1:5000";
    };
  };
}
```
