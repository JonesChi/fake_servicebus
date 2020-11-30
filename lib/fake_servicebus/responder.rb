require 'builder'
require 'securerandom'
require 'time'

module FakeServiceBus
  class Responder

    def queue(xml, queue)
      xml.tag! "entry" do
        xml.id "https://fake_servicebus/#{queue.name}"
        xml.title queue.name, :type=>"text"
        xml.published Time.now.utc.iso8601
        xml.updated Time.now.utc.iso8601
        xml.tag! "author" do
          xml.name "FakeServiceBus"
        end
        xml.link :rel=>"self", :href=>"https://fake_servicebus/#{queue.name}"
        xml.tag! "content" do
          xml.QueueDescription(
              :xmlns=>"http://schemas.microsoft.com/netservices/2010/10/servicebus/connect",
              :'xmlns:i'=>"http://www.w3.org/2001/XMLSchema-instance") do
            xml.LockDuration queue.attributes['LockDuration']
            xml.MaxSizeInMegabytes queue.attributes['MaxSizeInMegabytes']
            xml.RequiresDuplicateDetection queue.attributes['RequiresDuplicateDetection']
            xml.RequiresSession queue.attributes['RequiresSession']
            xml.DefaultMessageTimeToLive queue.attributes['DefaultMessageTimeToLive']
            xml.DeadLetteringOnMessageExpiration queue.attributes['DeadLetteringOnMessageExpiration']
            xml.DuplicateDetectionHistoryTimeWindow queue.attributes['DuplicateDetectionHistoryTimeWindow']
            xml.MaxDeliveryCount queue.attributes['MaxDeliveryCount']
            xml.EnableBatchedOperations queue.attributes['EnableBatchedOperations']
            xml.SizeInBytes queue.attributes['SizeInBytes']
            xml.MessageCount queue.attributes['MessageCount']
            xml.CreatedAt queue.attributes['CreatedAt']
            xml.UpdatedAt queue.attributes['UpdatedAt']
          end
        end
      end
    end

  end
end
