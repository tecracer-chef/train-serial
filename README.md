# train-serial - Train Plugin for connecting to serial interfaces

This plugin allows applications that rely on Train to communicate with devices connected over serial interfaces. This could be the console port of network gear or embedded systems.

## Installation

You will have to build this gem yourself to install it as it is not yet on Rubygems.Org. For this there is a rake task which makes this a one-liner:

```bash
rake install:local
```

## Transport parameters

| Option           | Explanation                  | Default          |
| ---------------- | ---------------------------- | ---------------- |
| `device`         | Device to connect to         | `/dev/ttyUSB0`   |
| `baud`           | Baud rate                    | `9600`           |
| `data_bits`      | Data Bits for connection     | `8`              |
| `parity`         | Parity (:none, :even, :odd)  | `:none`          |
| `stop_bits`      | Stop Bits for connection     | `1`              |
| `buffer_size`    | Number of bytes per read     | `1024`           |
| `buffer_wait`    | Wait between reads           | `250`            |
| `buffer_retries` | Retries until stopping reads | `3`              |
| `setup`          | Commands to issue on open    |                  |
| `teardown`       | Commands to issue on close   |                  |
| `raw_output`     | Suppress stdout processing   | `false`          |
| `error_pattern`  | Regex to match error lines   | `ERROR.*`        |
| `prompt_pattern` | Regex to match device prompt | `[-a-zA-Z0-9]+(?:\((?:config\|config-[a-z]+\|vlan)\))?[#>]\s*$` |

## Example use

This will work for a Cisco device on /dev/ttyUSB0:
```ruby
require 'train'
train  = Train.create('serial', {
            device:   '/dev/ttyUSB0',
            setup:    %Q[
              enable
              #{ENV['ENABLE_PASSWORD']}
              terminal pager 0
            ],
            teardown: "disable",
            logger:   Logger.new($stdout, level: :info)
         })
conn   = train.connection
result = conn.run_command("show version\n")
conn.close
```

## Useful Setup/Teardown Patterns

| Device         | Setup                                                       | Teardown  |
| -------------- | ----------------------------------------------------------- | --------- |
| Cisco Catalyst | `enable\nterminal length 0\n`                               | `disable` |
| Cisco ASA      | `enable\n#{@options[:enable_password]}\nterminal pager 0\n` | `disable` |
