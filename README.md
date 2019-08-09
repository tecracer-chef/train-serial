# train-serial - Train Plugin for connecting to serial interfaces

This plugin allows applications that rely on Train to communicate with devices connected over serial interfaces. This could be the console port of network gear or embedded systems.

## Installation

You will have to build this gem yourself to install it as it is not yet on Rubygems.Org. For this there is a rake task which makes this a one-liner:

```bash
rake install:local
```

## Transport parameters

| Option           | Explanation                  | Default        |
| ---------------- | ---------------------------- | -------------- |
| `device`         | Device to connect to         | `/dev/ttyUSB0` |
| `baud`           | Baud rate                    | 9600           |
| `data_bits`      | Data Bits for connection     | 8              |
| `parity`         | Parity (:none, :even, :odd)  | :none          |
| `stop_bits`      | Stop Bits for connection     | 1              |
| `buffer_size`    | Number of bytes per read     | 1024           |
| `buffer_wait`    | Wait between reads           | 250            |
| `buffer_retries` | Retries until stopping reads | 3              |
| `setup`          | Commands to issue first      |                |
| `teardown`       | Commands to issue on close   |                |

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
            teardown: "logout",
            logger:   Logger.new($stdout, level: :info)
         })
conn   = train.connection
result = conn.run_command("show version\n")
conn.close
```
