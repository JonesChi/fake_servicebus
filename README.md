# Fake Service Bus [![Gem Version](https://badge.fury.io/rb/fake_servicebus.svg)](https://badge.fury.io/rb/fake_servicebus)

Fake Service Bus is inspired by [Fake SQS](https://github.com/iain/fake_sqs) and it's also forked from Fake SQS, thanks Fake SQS.

Fake Service Bus is a lightweight server that mocks the Azure Service Bus API.

It is extremely useful for testing Service Bus applications in a sandbox environment without actually
making calls to Azure, which not only requires a network connection, but also costs
money.

Currently, only Queue APIs are supported
* List queues
* Create queue
* Get queue
* Delete queue
* Send message to queue
* Receive message from queue with timeout
* Unlock message
* Renew message
* Delete message

PRs are welcome.

## Installation

```
gem install fake_servicebus
```

## Running

```
fake_servicebus --database /path/to/database.yml
```

## Development

```
bundle install
rake
```
