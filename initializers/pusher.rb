require "json"
require "pusher"

Pusher.app_id = "MY_TEST_ID"
Pusher.key    = "MY_TEST_KEY"
Pusher.secret = "MY_TEST_SECRET"

#if ENV["PUSHER_FAKE"]
require "pusher-fake"
require "pusher-fake/support/base"
PusherFake.configuration.verbose = true
PusherFake.javascript
