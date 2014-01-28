# SmartChat API

This is the backend server for SmartChat.

## Requirements

* postgresql
* redis
* ruby 2.0.0-p247

## Installation

    $ bundle
    $ rake db:create db:migrate db:test:prepare
    $ cd worker
    $ bundle
    $ cd ../
    $ source .env
    $ foreman start

## Foreman

Foreman will start all necessary processes to run smartchat locally.


## Environment Variables

Smartchat requires numerous environment variables to be set to run properly.

```bash
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
export AWS_REGION='us-east-1'
export AWS_SMTP_USERNAME='...'
export AWS_SMTP_PASSWORD='...'
export GCM_API_KEY='...'
export TWILIO_ACCOUNT_SID='...'
export SMARTCHAT_API_HOST='...'
export SMARTCHAT_API_PORT='5000'
export SIDEKIQ_WEB_PASSWORD='password'
```

## Workers

Smartchat has several types of workers.

### Sidekiq

Sidekiq is used to process web requests out of band. This is used when uploading large media files that need to be copied to S3. We do the copying in Sidekiq so the client can have a fast return.

### SQS Worker

The SQS Worker is used to process the other types of jobs. Tasks such as sending email and sending smartchats.

## AWS

Smartchat uses the AWS infrastrcture heavily.

### EC2

SmartChat has two types of EC2 instances - web and worker.

* Web
  * unicorn
  * sidekiq
* Worker
  * SQS worker
