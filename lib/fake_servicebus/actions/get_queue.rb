module FakeServiceBus
  module Actions
    class GetQueue

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
        @responder = options.fetch(:responder)
        @request   = options.fetch(:request)
      end

      def call(queue_name, params)
        queue = @queues.get(queue_name, params)
        xml = Builder::XmlMarkup.new()
        @responder.queue xml, queue
      end

    end
  end
end
