require "train-serial/connection"

module TrainPlugins
  module Serial
    class Transport < Train.plugin(1)
      name "serial"

      option :device,         default: "/dev/ttyUSB0"
      option :baud,           default: 9600
      option :data_bits,      default: 8
      option :parity,         default: :none
      option :stop_bits,      default: 1

      option :buffer_size,    default: 1024
      option :buffer_wait,    default: 250
      option :buffer_retries, default: 3

      option :setup,          default: ""
      option :teardown,       default: ""
      option :error_pattern,  default: "ERROR: .*$"
      option :raw_output,     default: false
      option :prompt_pattern, default: "[-a-zA-Z0-9]+(?:\((?:config|config-[a-z]+|vlan)\))?[#>]\s*$"

      # Non documented options for development
      option :debug_serial,   default: false

      def connection(_instance_opts = nil)
        @connection ||= TrainPlugins::Serial::Connection.new(@options)
      end
    end
  end
end
