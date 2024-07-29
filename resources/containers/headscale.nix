{ ... }:
{
  services =
    let
      domain = "example.com";
    in
    {
      headscale = {
        enable = true;
        address = "0.0.0.0";
        port = 8085;

        settings = {
          server_url = "https://tailscale.${domain}";

          dns_config = {
            override_local_dns = true;
            base_domain = "${domain}";
            magic_dns = true;
            domains = [ "tailscale.${domain}" ];
            nameservers = [
              "9.9.9.9" # no cloudflare, nice
            ];
          };

          ip_prefixes = [
            "100.64.0.0/10"
            "fd7a:115c:a1e0::/48"
          ];
        };
      };
    };
}
