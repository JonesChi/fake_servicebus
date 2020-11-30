module FakeServiceBus
  module Actions
    class ReceiveMessage

      MAX_WAIT_TIME_SECONDS = 20

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
        @start_ts  = Time.now.to_f
        @satisfied = false
      end

      def call(queue_name, params)
        queue = @queues.get(queue_name)
        message = queue.receive_message(params.merge(queues: @queues))
        @satisfied = !message.nil? || expired?(queue, params)
        if !message.nil?
          [201,
           {'location'=>message.location,
            'BrokerProperties'=>{'SequenceNumber'=>message.sequence_number,
                                 'LockToken'=>message.lock_token}.to_json},
           message.body]
        end
      end

      def satisfied?
        @satisfied
      end

      protected
      def elapsed
        Time.now.to_f - @start_ts
      end

      def expired?(queue, params)
        wait_time_seconds = Integer params.fetch("timeout") { 0 }
        wait_time_seconds <= 0 ||
        elapsed >= wait_time_seconds ||
        elapsed >= MAX_WAIT_TIME_SECONDS
      end
    end
  end
end
