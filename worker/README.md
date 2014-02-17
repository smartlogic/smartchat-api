# SmartChat Worker

Backend workers for SmartChat. Built using [daemon-kit](https://github.com/kennethkalmer/daemon-kit).

SQS messages contain everything the worker requires to complete it's task.

## Media

The main job of the SmartChat worker. It publishes a file to a single user.

```json
{
  "id": 3,
  "user_id": 2,
  "public_key": "...",
  "created_at": "2014-02-17T16:27:56-05:00",
  "file_path": "...",
  "drawing_path": "...",
  "expire_in": 15,
  "pending": false,
  "devices": [{
    "device_id": "...",
    "device_type": "android"
  }],
  "creator": {
    "id": 1,
    "username": "eric"
  }
```

## Invitation

Sends an invitation email to the invitee from the inviter.

```json
{
  "invitee_email": "eric@example.com",
  "inviter_email": "sam@example.com",
  "message": "Join!"
}
```

## Clean Up

Cleans up a user's old smarches. Will delete smarches before the timestamp.

```json
{
  "user_id": 1,
  "timestamp": "2014-02-17"
}
```

## Send Device Notification

Generic job to send a notification to the user's devices.

```json
{
  "user_id": 1,
  "devices": [{
    "device_type": "android",
    "device_id": "..."
  }],
  "message": {
    "data": "to send"
  }
}
```
