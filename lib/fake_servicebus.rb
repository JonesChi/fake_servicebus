require 'fake_servicebus/api'
require 'fake_servicebus/catch_errors'
require 'fake_servicebus/collection_view'
require 'fake_servicebus/error_response'
require 'fake_servicebus/message'
require 'fake_servicebus/queue'
require 'fake_servicebus/queue_factory'
require 'fake_servicebus/queues'
require 'fake_servicebus/responder'
require 'fake_servicebus/server'
require 'fake_servicebus/version'
require 'fake_servicebus/databases/file'
require 'fake_servicebus/databases/memory'

module FakeServiceBus

  def self.to_rack(options)

    require 'fake_servicebus/web_interface'
    app = FakeServiceBus::WebInterface

    if (log = options[:log])
      file = File.new(log, "a+")
      file.sync = true
      app.use Rack::CommonLogger, file
      app.set :log_file, file
      app.enable :logging
    end

    if options[:verbose]
      require 'fake_servicebus/show_output'
      app.use FakeServiceBus::ShowOutput
      app.enable :logging
    end

    if options[:daemonize]
      require 'fake_servicebus/daemonize'
      Daemonize.new(options).call
    end

    app.set :port, options[:port] if options[:port]
    app.set :bind, options[:host] if options[:host]
    app.set :server, options[:server] if options[:server]
    server = FakeServiceBus.server(port: options[:port], host: options[:host])
    app.set :api, FakeServiceBus.api(server: server, database: options[:database])
    app
  end

  def self.server(options = {})
    Server.new(options)
  end

  def self.api(options = {})
    db = database_for(options.fetch(:database) { ":memory:" })
    API.new(
      server: options.fetch(:server),
      queues: queues(db),
      responder: responder
    )
  end

  def self.queues(database)
    Queues.new(queue_factory: queue_factory, database: database)
  end

  def self.responder
    Responder.new
  end

  def self.queue_factory
    QueueFactory.new(message_factory: message_factory, queue: queue)
  end

  def self.message_factory
    Message
  end

  def self.queue
    Queue
  end

  def self.database_for(name)
    if name == ":memory:"
      MemoryDatabase.new
    else
      FileDatabase.new(name)
    end
  end

end
