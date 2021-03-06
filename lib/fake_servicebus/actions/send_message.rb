module FakeServiceBus
  module Actions
    class SendMessage

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
        @request   = options.fetch(:request)
      end

      def call(queue_name, params)
        queue = @queues.get(queue_name)
        message = queue.send_message(params.merge(
            {'queue_name'=>queue_name,
             'body'=>@request.body.read})
        )
        201
      end

    end
  end
end
