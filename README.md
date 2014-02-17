# SmartChat API

This is the backend server for SmartChat, a sharing platform.

## Requirements

* postgresql
* redis
* ruby 2.0.0-p247

## Installation

    $ bundle
    $ rake db:create db:migrate db:test:prepare db:seed
    $ cd worker
    $ bundle
    $ cd ../
    $ source .env
    $ foreman start

## Foreman

Foreman will start all necessary processes to run smartchat locally.


## Environment Variables

Smartchat requires numerous environment variables to be set to run properly, and uses [dotenv](https://github.com/bkeepers/dotenv).

```bash
AWS_ACCESS_KEY_ID='...'
AWS_SECRET_ACCESS_KEY='...'
AWS_REGION='us-east-1'
AWS_SMTP_USERNAME='...'
AWS_SMTP_PASSWORD='...'
GCM_API_KEY='...'
TWILIO_ACCOUNT_SID='...'
TWILIO_VERIFICATION_PHONE_NUMBER='...'
SIDEKIQ_WEB_PASSWORD='password'
```

Most of these are not required in development though. Development only environment variables.

```bash
GCM_API_KEY='...' # Required for android push notifications
TWILIO_ACCOUNT_SID='...' # Required for twilio interactions
TWILIO_VERIFICATION_PHONE_NUMBER='...' # Required for verifying SMS
SMARTCHAT_API_HOST='...'
SMARTCHAT_API_PORT='5000'
SIDEKIQ_WEB_PASSWORD='password'
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

SmartChat has three types of EC2 instances.

* Web
  * unicorn
  * sidekiq
* Worker
  * SQS worker
* Scheduler
  * cron jobs
