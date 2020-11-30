require 'time'
require 'nokogiri'

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
        attributes = {}
        root = Nokogiri::XML(@request.body.read)
        root.remove_namespaces!
        queue_element = root.xpath('.//content/QueueDescription')[0]
        if not queue_element.nil?
          if elem = queue_element.xpath('LockDuration')[0]
            attributes['LockDuration'] = elem.text
          end
          if elem = queue_element.xpath('MaxSizeInMegabytes')[0]
            attributes['MaxSizeInMegabytes'] = elem.text.to_i
          end
          if elem = queue_element.xpath('RequiresDuplicateDetection')[0]
            attributes['RequiresDuplicateDetection'] = elem.text == "true"
          end
          if elem = queue_element.xpath('RequiresSession')[0]
            attributes['RequiresSession'] = elem.text == "true"
          end
          if elem = queue_element.xpath('DefaultMessageTimeToLive')[0]
            attributes['DefaultMessageTimeToLive'] = elem.text
          end
          if elem = queue_element.xpath('DeadLetteringOnMessageExpiration')[0]
            attributes['DeadLetteringOnMessageExpiration'] = elem.text == "true"
          end
          if elem = queue_element.xpath('DuplicateDetectionHistoryTimeWindow')[0]
            attributes['DuplicateDetectionHistoryTimeWindow'] = elem.text
          end
          if elem = queue_element.xpath('MaxDeliveryCount')[0]
            attributes['MaxDeliveryCount'] = elem.text.to_i
          end
          if elem = queue_element.xpath('EnableBatchedOperations')[0]
            attributes['EnableBatchedOperations'] = elem.text == "true"
          end
          if elem = queue_element.xpath('MessageCount')[0]
            attributes['MessageCount'] = elem.text.to_i
          end
          if elem = queue_element.xpath('SizeInBytes')[0]
            attributes['SizeInBytes'] = elem.text.to_i
          end
        end

        queue = @queues.create(queue_name, {:attributes=>attributes})
        xml = Builder::XmlMarkup.new()
        body = @responder.queue xml, queue
        [201, body]
      end

    end
  end
end
