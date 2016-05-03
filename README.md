[![Build Status](https://travis-ci.org/moexmen/superlogger.svg?branch=master)](https://travis-ci.org/moexmen/superlogger)
[![Gem Version](https://badge.fury.io/rb/superlogger.svg)](https://badge.fury.io/rb/superlogger)
[![Dependency Status](https://gemnasium.com/badges/github.com/moexmen/superlogger.svg)](https://gemnasium.com/github.com/moexmen/superlogger)

Superlogger - Machine-readable logging for Rails
=======

Rails' default request logging is easy to read for humans but difficult for log aggregators such as Kibana, Graylog and Splunk. Superlogger transforms the logs into key-value pairs for easy parsing and adds useful details like Timestamp, Session ID and Request ID for tracing purposes.

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

Machine-readable logging with Superlogger:
```sh
# first request
2016-04-29 17:29:45.841 | 12dc0e484869 | 68d63a8cf920 | I | superlogger_middleware:30 | method=GET | path=/home/index | ip=::1
2016-04-29 17:29:45.847 | 12dc0e484869 | 68d63a8cf920 | D | action_controller_log_subscriber:9 | controller=HomeController | action=index | params={}
2016-04-29 17:29:45.852 | 12dc0e484869 | 68d63a8cf920 | D | active_record_log_subscriber:24 | sql=SELECT  "somethings".* FROM "somethings" WHERE "somethings"."paper" = ? AND "somethings"."stone" = ?  ORDER BY "somethings"."id" ASC LIMIT 1 | params=["123", "456"] | duration=0.13
2016-04-29 17:29:45.861 | 12dc0e484869 | 68d63a8cf920 | D | action_view_log_subscriber:6 | view=_partial.html.erb | duration=0.2
2016-04-29 17:29:45.861 | 12dc0e484869 | 68d63a8cf920 | D | action_view_log_subscriber:6 | view=index.html.erb | duration=3.2
2016-04-29 17:29:45.983 | 12dc0e484869 | 68d63a8cf920 | I | action_controller_log_subscriber:29 | status=200 | total_duration=135.92 | view_duration=130.38 | db_duration=0.33

# second request
2016-04-29 17:39:54.879 | 12dc0e484869 | e463d380fb63 | I | superlogger_middleware:30 | method=GET | path=/home/show | ip=::1
2016-04-29 17:39:54.879 | 12dc0e484869 | e463d380fb63 | D | action_controller_log_subscriber:9 | controller=HomeController | action=show | params={}
2016-04-29 17:39:54.882 | 12dc0e484869 | e463d380fb63 | D | action_view_log_subscriber:6 | view=show.html.erb | duration=0.2
2016-04-29 17:39:54.884 | 12dc0e484869 | e463d380fb63 | I | action_controller_log_subscriber:29 | status=200 | total_duration=4.64 | view_duration=4.55 | db_duration=0.0
```

## Features ##
- Timestamp (milliseconds)
- Session ID for logs belonging to the same user session (notice above that both the requests have the same session id)
- Request ID for logs belonging to the same page request (notice above that each request have a different request id)
- Hashes will be logged as key-value pairs automatically
- Requests for assets will not be logged
- File and line numbers 
- IP address of request

## Installation ##

Add superlogger to your application's Gemfile
```ruby
gem "superlogger"
```

Execute:
```sh
$ bundle
```

And add the following in `config/application.rb`
```ruby
config.logger = Superlogger::Logger.new(STDOUT)
```

## Usage ##

Log as per normal using `Rails.logger`.

```ruby
class SomeClass
    def some_method
        Rails.logger.debug foo:'true', bar: 'false'
        Rails.logger.info foo:'true', bar: 'false'
        Rails.logger.warn foo:'true', bar: 'false'
        Rails.logger.error foo:'true', bar: 'false'
        Rails.logger.fatal foo:'true', bar: 'false'
    end
end
```

## Log Format ##
```sh
2015-03-26 23:37:38.086 | 12dc0e484869   | e463d380fb63   | I            | action_controller_log_subscriber:29 | status=200 | total_duration=4.64 | view_duration=4.55 | db_duration=0.0
< timestamp >           | < session id > | < request id > | < severity > | < file >:< line num >               | < data you pass in ... >
< 23 chars >            | < 12 chars >   | <12 chars >    | < 1 char >   | < ? chars >                         | < ? chars >
```

### Severity Levels ###
- **D** - Debug
- **I** - Info
- **W** - Warn
- **E** - Error
- **F** - Fatal
