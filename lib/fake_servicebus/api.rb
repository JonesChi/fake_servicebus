require 'fake_servicebus/actions/create_queue'
require 'fake_servicebus/actions/delete_queue'
require 'fake_servicebus/actions/list_queues'
require 'fake_servicebus/actions/get_queue'
require 'fake_servicebus/actions/send_message'
require 'fake_servicebus/actions/receive_message'
require 'fake_servicebus/actions/unlock_message'
require 'fake_servicebus/actions/renew_lock_message'
require 'fake_servicebus/actions/delete_message'

module FakeServiceBus

  InvalidAction = Class.new(ArgumentError)

  class API

    attr_reader :queues, :options

    def initialize(options = {})
      @queues    = options.fetch(:queues)
      @options   = options
      @halt      = false
      @timer     = Thread.new do
        until @halt
          queues.timeout_messages!
          sleep(0.1)
        end
      end
    end

    def call(action, request, *args)
      if FakeServiceBus::Actions.const_defined?(action)
        action = FakeServiceBus::Actions.const_get(action).new(options.merge({:request => request}))
        if action.respond_to?(:satisfied?)
          result = nil
          until @halt
            result = attempt_once(action, *args)
            break if action.satisfied?
            sleep(0.1)
          end
          result
        else
          attempt_once(action, *args)
        end
      else
        fail InvalidAction, "Unknown (or not yet implemented) action: #{action}"
      end
    end

    def attempt_once(action, *args)
      queues.transaction do
        action.call(*args)
      end
    end

    # Fake actions

    def reset
      queues.reset
    end

    def expire
      queues.expire
    end

    def stop
      @halt = true
    end

  end
end
