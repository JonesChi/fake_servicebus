module FakeServiceBus
  module Actions
    class DeleteMessage

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
      end

      def call(queue_name, lock_token, params)
        queue = @queues.get(queue_name)

        queue.delete_message(lock_token)
        200
      end

    end
  end
end
