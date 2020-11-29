require 'time'

module FakeServiceBus
  module Actions
    class CreateQueue

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
        @responder = options.fetch(:responder)
        @request   = options.fetch(:request)
      end

      def call(queue_name, params)
        queue = @queues.create(queue_name, params)
        body = @responder.call queue_name do |xml|
          xml.QueueDescription(
              :xmlns=>"http://schemas.microsoft.com/netservices/2010/10/servicebus/connect") do
            #  :xmlns:i=>"http://www.w3.org/2001/XMLSchema-instance") do
            xml.LockDuration "PT1M"
            xml.MaxSizeInMegabytes 1024
            xml.RequiresDuplicateDetection false
            xml.RequiresSession false
            xml.DefaultMessageTimeToLive "P10675199DT2H48M5.4775807S"
            xml.DeadLetteringOnMessageExpiration false
            xml.DuplicateDetectionHistoryTimeWindow "PT10M"
            xml.MaxDeliveryCount 10
            xml.EnableBatchedOperations true
            xml.SizeInBytes 0
            xml.MessageCount 0
            xml.CreatedAt Time.now.utc.iso8601
            xml.UpdatedAt Time.now.utc.iso8601
          end
        end
        [201, body]
      end

    end
  end
end
