require "net/http"

module FakeServiceBus
  class TestIntegration

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def host
      option :servicebus_endpoint
    end

    def port
      option :servicebus_port
    end

    def start
      start! unless up?
      reset
    end

    def start!
      args = [ binfile, "-p", port.to_s, verbose, logging, "--database", database, { :out => out, :err => out } ].flatten.compact
      @pid = Process.spawn(*args)
      wait_until_up(Time.now + start_timeout)
    end

    def stop
      if @pid
        Process.kill("INT", @pid)
        Process.waitpid(@pid)
        @pid = nil
      else
        $stderr.puts "FakeServiceBus is not running"
      end
    end

    def reset
      connection.delete("/")
    end

    def expire
      connection.put("/", "")
    end

    def url
      "http://#{host}:#{port}"
    end

    def uri
      URI(url)
    end

    def up?
      @pid && connection.get("/ping").code.to_s == "200"
    rescue Errno::ECONNREFUSED
      false
    end

    private

    def option(key)
      options.fetch(key)
    end

    def database
      options.fetch(:database)
    end

    def start_timeout
      options[:start_timeout] || 2
    end

    def verbose
      if options[:verbose]
        "--verbose"
      else
        "--no-verbose"
      end
    end

    def logging
      if (file = ENV["ServiceBus_LOG"] || options[:log])
        [ "--log", file ]
      else
        []
      end
    end

    def wait_until_up(deadline)
      fail "FakeServiceBus didn't start in time" if Time.now > deadline
      unless up?
        sleep 0.1
        wait_until_up(deadline)
      end
    end

    def binfile
      File.expand_path("../../../bin/fake_servicebus", __FILE__)
    end

    def out
      if debug?
        :out
      else
        "/dev/null"
      end
    end

    def connection
      @connection ||= Net::HTTP.new(host, port)
    end

    def debug?
      ENV["DEBUG"].to_s == "true" || options[:debug]
    end

  end
end
