module FakeServiceBus
  module Actions
    class ListQueues

      def initialize(options = {})
        @server    = options.fetch(:server)
        @queues    = options.fetch(:queues)
        @responder = options.fetch(:responder)
        @request   = options.fetch(:request)
      end

      def call(params)
        found = @queues.list(params)
        xml = Builder::XmlMarkup.new()
        xml.tag! "feed", :xmlns=>"http://www.w3.org/2005/Atom" do
          xml.title "Queues", :type=>"text"
          xml.id "https://fake_servicebus/$Resources/Queues"
          xml.updated Time.now.utc.iso8601
          xml.link :rel=>"self", :href=>"fake_servicebus/$Resources/Queues"
          found.each do |queue|
            @responder.queue xml, queue
          end
        end
      end

    end
  end
end
