require 'monitor'
require 'securerandom'
require 'fake_servicebus/collection_view'
require 'json'

module FakeServiceBus

  MessageNotInflight = Class.new(RuntimeError)
  ReadCountOutOfRange = Class.new(RuntimeError)
  ReceiptHandleIsInvalid = Class.new(RuntimeError)

  class Queue

    VISIBILITY_TIMEOUT = 30

    attr_reader :name, :message_factory, :arn, :queue_attributes

    def initialize(options = {})
      @message_factory = options.fetch(:message_factory)

      @name = options.fetch("queue_name")
      @arn = options.fetch("Arn") { "arn:aws:sqs:us-east-1:#{SecureRandom.hex}:#{@name}" }
      @queue_attributes = options.fetch("Attributes") { {} }
      @lock = Monitor.new
      reset
    end

    def to_yaml
      {
        "QueueName" => name,
        "Arn" => arn,
        "Attributes" => queue_attributes,
      }
    end

    def add_queue_attributes(attrs)
      queue_attributes.merge!(attrs)
    end

    def attributes
      queue_attributes.merge(
        "QueueArn" => arn,
        "ApproximateNumberOfMessages" => published_size,
        "ApproximateNumberOfMessagesNotVisible" => @messages_in_flight.size,
      )
    end

    def send_message(options = {})
      with_lock do
        message = options.fetch(:message){ message_factory.new(options) }
        if message
          @messages[message.lock_token] = message
        end
        message
      end
    end

    def receive_message(options = {})
      visibility_timeout = Integer options.fetch("VisibilityTimeout") { default_visibility_timeout }

      return nil if @messages.empty?

      result = nil
      with_lock do
        published_messages = @messages.values.select { |m| m.published? }

        message = published_messages.delete_at(rand(published_size))
        @messages.delete(message.lock_token)
        unless check_message_for_dlq(message, options)
          message.expire_at(visibility_timeout)
          message.receive!
          @messages_in_flight[message.lock_token] = message
          result = message
        end
      end

      result
    end

    def default_visibility_timeout
      if value = attributes['VisibilityTimeout']
        value.to_i
      else
        VISIBILITY_TIMEOUT
      end
    end

    def timeout_messages!
      with_lock do
        expired = @messages_in_flight.inject({}) do |memo,(lock_token,message)|
          if message.expired?
            memo[lock_token] = message
          end
          memo
        end
        expired.each do |lock_token,message|
          message.expire!
          @messages[lock_token] = message
          @messages_in_flight.delete(lock_token)
        end
      end
    end

    def unlock_message(lock_token)
      with_lock do
        message = @messages_in_flight[lock_token]
        raise MessageNotInflight unless message

        message.expire!
        @messages[lock_token] = message
        @messages_in_flight.delete(lock_token)
      end
    end

    def check_message_for_dlq(message, options={})
      if redrive_policy = queue_attributes["RedrivePolicy"] && JSON.parse(queue_attributes["RedrivePolicy"])
        dlq = options[:queues].list.find{|queue| queue.arn == redrive_policy["deadLetterTargetArn"]}
        if dlq && message.approximate_receive_count >= redrive_policy["maxReceiveCount"].to_i
          dlq.send_message(message: message)
          message.expire!
          true
        end
      end
    end

    def delete_message(lock_token)
      with_lock do
        @messages.delete(lock_token)
        @messages_in_flight.delete(lock_token)
      end
    end

    def reset
      with_lock do
        @messages = {}
        @messages_view = FakeServiceBus::CollectionView.new(@messages)
        reset_messages_in_flight
      end
    end

    def expire
      with_lock do
        @messages.merge!(@messages_in_flight)
        @messages_in_flight.clear()
        reset_messages_in_flight
      end
    end

    def reset_messages_in_flight
      with_lock do
        @messages_in_flight = {}
        @messages_in_flight_view = FakeServiceBus::CollectionView.new(@messages_in_flight)
      end
    end

    def messages
      @messages_view
    end

    def messages_in_flight
      @messages_in_flight_view
    end

    def size
      @messages.size
    end

    def published_size
      @messages.values.select { |m| m.published? }.size
    end

    def with_lock
      @lock.synchronize do
        yield
      end
    end

  end
end
