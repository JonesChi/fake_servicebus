require 'sinatra/base'
require 'fake_servicebus/catch_errors'
require 'fake_servicebus/error_response'

module FakeServiceBus
  class WebInterface < Sinatra::Base

    def self.handle(path, verbs, &block)
      verbs.each do |verb|
        send(verb, path, &block)
      end
    end

    configure do
      use FakeServiceBus::CatchErrors, response: ErrorResponse
    end

    helpers do
      def action
        params.fetch("Action")
      end
    end

    get "/ping" do
      200
    end

    delete "/" do
      settings.api.reset
      200
    end

    put "/" do
      settings.api.expire
      200
    end

    handle "/$Resources/Queues", [:get] do
      settings.api.call(:ListQueues, request, params)
    end

    handle "/:queue_name", [:put] do |queue_name|
      settings.api.call(:CreateQueue, request, queue_name, params)
    end

    handle "/:queue_name", [:delete] do |queue_name|
      settings.api.call(:DeleteQueue, request, queue_name, params)
    end

    handle "/:queue_name", [:get] do |queue_name|
      settings.api.call(:GetQueue, request, queue_name, params)
    end

    handle "/:queue_name/messages", [:post] do |queue_name|
      settings.api.call(:SendMessage, request, queue_name, params)
    end

    handle "/:queue_name/messages/head", [:post, :delete] do |queue_name|
      settings.api.call(:ReceiveMessage, request, queue_name, params)
    end

    handle "/:queue_name/messages/:sequence_number/:lock_token", [:put] do |queue_name, sequence_number, lock_token|
      settings.api.call(:UnlockMessage, request, queue_name, lock_token, params)
    end

    handle "/:queue_name/messages/:sequence_number/:lock_token", [:post] do |queue_name, sequence_number, lock_token|
      settings.api.call(:RenewLockMessage, request, queue_name, lock_token, params)
    end

    handle "/:queue_name/messages/:sequence_number/:lock_token", [:delete] do |queue_name, sequence_number, lock_token|
      settings.api.call(:DeleteMessage, request, queue_name, lock_token, params)
    end
  end
end
