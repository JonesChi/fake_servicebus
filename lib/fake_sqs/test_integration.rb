require "net/http"

module FakeSQS
  class TestIntegration

    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def host
      option :sqs_endpoint
    end

    def port
      option :sqs_port
    end

    def start
      start! unless up?
      reset
    end

    def start!
      args = [ binfile, "-p", port.to_s, "--database", database, { :out => out, :err => out } ]
      @pid = Process.spawn(*args)
      wait_until_up
    end

    def stop
      if @pid
        Process.kill("INT", @pid)
        Process.waitpid(@pid)
        @pid = nil
      else
        $stderr.puts "FakeSQS is not running"
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

    def up?
      @pid && connection.get("/").code.to_s == "200"
    rescue Errno::ECONNREFUSED
      false
    end

    private

    def option(key)
      options.fetch(key) { AWS.config.public_send(key) }
    end

    def database
      options.fetch(:database)
    end

    def wait_until_up(deadline = Time.now + 2)
      fail "FakeSQS didn't start in time" if Time.now > deadline
      unless up?
        sleep 0.01
        wait_until_up(deadline)
      end
    end

    def binfile
      File.expand_path("../../../bin/fake_sqs", __FILE__)
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
      ENV["DEBUG"].to_s == "true"
    end

  end
end