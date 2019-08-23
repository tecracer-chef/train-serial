require "rubyserial"
require "train"

module TrainPlugins
  module Serial
    class Connection < Train::Plugins::Transport::BaseConnection

      def initialize(options)
        super(options)
      end

      def close
        return if @session.nil?

        unless @options[:teardown].empty?
          logger.debug format("[Serial] Sending teardown command to %s", @options[:device])
          execute_on_channel(@options[:teardown])
        end

        logger.info format("[Serial] Closed connection %s", @options[:device])
        session.close
      ensure
        @session = nil
      end

      def uri
        "serial://#{@options[:port]}/#{@options[:baud]}"
      end

      def run_command_via_connection(cmd, &data_handler)
        reset_session if session.closed?

        logger.debug format("[Serial] Sending command to %s", @options[:device])
        exit_status, stdout, stderr = execute_on_channel(cmd, &data_handler)

        CommandResult.new(stdout, stderr, exit_status)
      end

      def execute_on_channel(cmd, &data_handler)
        stdout = ""
        stderr = ""
        exit_status = 0

        if @options[:debug_serial]
          logger.debug "[Serial] => #{cmd}\n"
        end

        session.write(cmd + "\n")

        retries = 0
        loop do
          chunk = session.read(@options[:buffer_size])
          if chunk.empty?
            if @options[:debug_serial]
              logger.debug format("[Serial] Buffering on %s (attempt %d/%d, %d bytes received)", @options[:device], retries + 1, @options[:buffer_retries], stdout.size)
            end
            retries += 1
            sleep @options[:buffer_wait] / 1000.0
          else
            retries = 0
          end
          break if retries >= @options[:buffer_retries]

          stdout << chunk
        end

        # Remove \r in linebreaks
        stdout.delete!("\r")

        if @options[:debug_serial]
          logger.debug "[Serial] <= '#{stdout}'"
        end

        # Extract command output only (no leading/trailing prompts)
        unless @options[:raw_output]
          stdout = stdout.match(/#{Regexp.quote(cmd.strip)}\n(.*?)\n#{@options[:prompt_pattern]}/m)&.captures&.first
        end
        stdout = "" if stdout.nil?

        # Simulate exit code and stderr
        errors = stdout.match(/^(#{@options[:error_pattern]})/)
        if errors
          exit_status = 1
          stderr = errors.captures.first
          stdout.gsub!(/^#{@options[:error_pattern]}/, "")
        end

        [exit_status, stdout, stderr]
      end

      def session(retry_options = {})
        @session ||= create_session
      end

      def create_session
        logger.info format("[Serial] Opening connection %s (%s)", @options[:device], readable_config)
        @session = ::Serial.new(
          @options[:device],
          @options[:baud],
          @options[:data_bits],
          @options[:parity],
          @options[:stop_bits]
        )

        unless @options[:setup].empty?
          logger.debug format("[Serial] Sending setup command to %s", @options[:device])

          execute_on_channel(@options[:setup])
        end

        @session
      end

      def reset_session
        session.close unless session.nil?
        @session = nil
      end

      def readable_config
        parity = "N"
        parity = "E" if @options[:parity] == :even
        parity = "O" if @options[:parity] == :odd

        format("%d %d%s%d",
          @options[:baud],
          @options[:data_bits],
          parity,
          @options[:stop_bits])
      end
    end
  end
end
