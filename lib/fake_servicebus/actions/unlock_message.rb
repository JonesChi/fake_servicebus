module FakeServiceBus
  module Actions
    class UnlockMessage

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
        @responder = options.fetch(:responder)
      end

      def call(queue_name, lock_token, params)
        queue = @queues.get(queue_name)

        queue.unlock_message(lock_token)
        200
      end

    end
  end
end
