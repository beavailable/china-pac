# china-pac
This is a fast PAC specifically designed for Chinese users.

It'll automatically sync all Chinese domains from [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list) and rebuild the package (if there's any updates) every one hour.

The PAC will return:
- "DIRECT" if the host is an ipv4/ipv6 address
- "DIRECT" if the host is a Chinese domain
- a proxy (default `SOCKS 127.0.0.1:1080`)

**Note** that the chromium browser doesn't load the PAC if its file size is larger than 1M, while [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) has removed that limit.

## Installation

### Debian & Ubuntu
Install via the OBS repo (see [obs-repo](https://github.com/beavailable/obs-repo) for setup).

### Other Operating Systems
```bash
./generate.sh
```

## Configuration

You can change the default proxy in `proxy` file, or add extra domains in `extra.list` file.

For `Debian & Ubuntu` users, all the configuration files are in `/etc/china-pac/`.  
Be sure to run `sudo dpkg-reconfigure china-pac` after modifying any configuration files.
