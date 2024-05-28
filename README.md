[![Build Status](https://travis-ci.org/moexmen/superlogger.svg?branch=master)](https://travis-ci.org/moexmen/superlogger)
[![Gem Version](https://badge.fury.io/rb/superlogger.svg)](https://badge.fury.io/rb/superlogger)
[![Dependency Status](https://gemnasium.com/badges/github.com/moexmen/superlogger.svg)](https://gemnasium.com/github.com/moexmen/superlogger)

Superlogger - Machine-readable logging for Rails
=======

Rails' default request logging is easy to read for humans but difficult for log aggregators such as Kibana, Graylog and Splunk. Superlogger transforms the logs into JSON for easy parsing and adds useful details like Timestamp, Session ID and Request ID for tracing purposes.

Default rails logging:
```sh
Started GET "/home/index" for ::1 at 2016-04-29 17:31:12 +0800
  ActiveRecord::SchemaMigration Load (0.1ms)  SELECT "schema_migrations".* FROM "schema_migrations"
Processing by HomeController#index as HTML
  Something Load (0.1ms)  SELECT  "somethings".* FROM "somethings" WHERE "somethings"."paper" = ? AND "somethings"."stone" = ?  ORDER BY "somethings"."id" ASC LIMIT 1  [["paper", "123"], ["stone", "456"]]
  Rendered home/_partial.html.erb (0.2ms)
  Rendered home/index.html.erb within layouts/application (3.4ms)
Completed 200 OK in 135ms (Views: 130.7ms | ActiveRecord: 0.3ms)

Started GET "/assets/application.self-e80e8f2318043e8af94dddc2adad5a4f09739a8ebb323b3ab31cd71d45fd9113.css?body=1" for ::1 at 2016-04-29 17:31:12 +0800

Started GET "/assets/application.self-8f06a73c35179188914ab50e057157639fce1401c1cdca640ac9cec33746fc5b.js?body=1" for ::1 at 2016-04-29 17:31:12 +0800

```

With Superlogger:
```sh
{"level":"debug","ts":1590972589.522784,"caller":"superlogger/active_record_log_subscriber:21","sql":"SELECT \"schema_migrations\".\"version\" FROM \"schema_migrations\" ORDER BY \"schema_migrations\".\"version\" ASC","params":[],"duration":0.13}
{"level":"info","ts":1590972589.526133,"caller":"superlogger/superlogger_middleware:21","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","method":"GET","path":"/home/index"}
{"level":"debug","ts":1590972589.546272,"caller":"superlogger/action_controller_log_subscriber:8","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","controller":"HomeController","action":"index","params":{}}
{"level":"debug","ts":1590972589.55092,"caller":"superlogger/active_record_log_subscriber:21","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","sql":"SELECT  \"somethings\".* FROM \"somethings\" WHERE \"somethings\".\"paper\" = ? AND \"somethings\".\"stone\" = ? ORDER BY \"somethings\".\"id\" ASC LIMIT ?","params":["123","456","1"],"duration":0.22}
{"level":"debug","ts":1590972589.574199,"caller":"superlogger/action_view_log_subscriber:6","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","view":"_partial.html.erb","duration":0.33}
{"level":"debug","ts":1590972589.574795,"caller":"superlogger/action_view_log_subscriber:6","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","view":"index.html.erb","duration":2.95}
{"level":"info","ts":1590972589.61165,"caller":"superlogger/action_controller_log_subscriber:20","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","view_duration":54.59,"db_duration":0.85}
{"level":"info","ts":1590972589.611928,"caller":"superlogger/superlogger_middleware:30","session_id":"90e90c75c72c","request_id":"34432478c89b4d8591e02e0169b40a56","method":"GET","path":"/home/index","response_time":85.65,"status":200}
```

## Installation ##

Add superlogger to your application's Gemfile
```ruby
gem "superlogger"
```

Execute:
```sh
$ bundle
```

And add the following in `config/environment/production.rb`
```ruby
config.logger = Superlogger::Logger.new(STDOUT)
```

By default, Superlogger is only enabled in production environment because JSON is easy for machines to parse but difficult for humans to read. To forcefully enable Superlogger in non-production environment, set in `config/application.rb`:
```ruby
Superlogger.enabled = true
```

## Usage ##

Log as per normal using `Rails.logger`.

```ruby
Rails.logger.info foo:'true', bar: 'false'
Rails.logger.info "Meatball"
```

## Log Format ##
- `ts` = Unix Epoch timestamp
- `session_id` = Truncated to 12 characters
- `request_id` = 32 characters
- `msg` = If values given is not a hash, it is treated as `{"msg":<value>"}`
- All duration related fields are in milliseconds

## Testing ##

To run the tests for Superlogger:

```sh
rake test
```
