require 'builder'
require 'securerandom'
require 'time'

module FakeServiceBus
  class Responder

    def call(queue_name, &block)
      xml = Builder::XmlMarkup.new()
      xml.tag! "entry" do
        xml.id "https://fake_servicebus/#{queue_name}"
        xml.title queue_name, :type=>"text"
        xml.published Time.now.utc.iso8601
        xml.updated Time.now.utc.iso8601
        xml.author "FakeServiceBus"
        xml.link :rel=>"self", :href=>"https://fake_servicebus/#{queue_name}"
        if block
          xml.tag! "content" do
            yield xml
          end
        end
      end
    end

  end
end
