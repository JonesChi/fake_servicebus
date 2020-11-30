require 'securerandom'
require 'digest/sha1'

module FakeServiceBus
  class Message

    attr_reader :queue_name, :body, :sequence_number, :lock_token, :location, :delay_seconds, :delivery_count,
    :enqueued_timestamp
    attr_accessor :locked_until

    def initialize(options = {})
      @queue_name = options.fetch("queue_name")
      @body = options.fetch("body")
      @sequence_number = options.fetch("sequence_number") { SecureRandom.random_number(9e5).to_i }
      @lock_token = options.fetch("lock_token") { SecureRandom.uuid }
      @location = "https://fake_servicebus/#{@queue_name}/messages/#{@sequence_number}/#{@lock_token}"
      @delivery_count = 0
      @enqueued_timestamp = Time.now.to_i * 1000
      #@delay_seconds = options.fetch("DelaySeconds", 0).to_i
    end

    def expire!
      self.locked_until = nil
    end

    def receive!
      @delivery_count += 1
    end

    def expired?( limit = Time.now )
      self.locked_until.nil? || self.locked_until < limit
    end

    def expire_at(seconds)
      self.locked_until = Time.now + seconds
    end

    def published?
      if self.delay_seconds && self.delay_seconds > 0
        elapsed_seconds = Time.now.to_i - (self.enqueued_timestamp.to_i / 1000)
        elapsed_seconds >= self.delay_seconds
      else
        true
      end
    end

    def attributes
      {
        "QueueName"=> queue_name,
        "SequenceNumber"=> sequence_number,
        "LockToken"=> lock_token,
        "Location"=> location,
        "DeliveryCount"=> delivery_count,
        "EnqueuedTimestamp"=> enqueued_timestamp
      }
    end

  end
end
