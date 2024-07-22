# Key configuration items

- Main file: ./configure
  - Trimmed version of https://github.com/Exim/exim/blob/master/src/src/configure.default
- Transport pipeline: ACL allow -> mail router -> mail transport
- HELO name: `primary_hostname` (main configuration settings)
- Target relay host: `ROUTER_RELAY_HOST` (main configuration settings)
