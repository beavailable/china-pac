# china-pac
This is a fast PAC specifically designed for Chinese users.

It'll automatically sync all Chinese domains from [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list) and rebuild the package (if there's any updates) every one hour.

The PAC will return:
- "DIRECT" if the host is an ipv4/ipv6 address
- "DIRECT" if the host is a Chinese domain
- a proxy (default `SOCKS 127.0.0.1:1080`) which can be configured in `/etc/china-pac/proxy`

You can also add extra domains in `/etc/china-pac/extra.list`.  
But remember to run `sudo dpkg-reconfigure china-pac` after modifying any configuration files.

The PAC file is located at `/var/lib/china-pac/proxy.pac`.

**Note** that the chromium browser doesn't load the PAC if its file size is larger than 1M, while [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) has removed that limit.

## Installation

### Debian & Ubuntu
Install via the OBS repo (see [obs-repo](https://github.com/beavailable/obs-repo) for setup).

### Other Operating Systems
```bash
./generate.sh
```
