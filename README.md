Superlogger - Machine-readable logging for Rails [![Build Status](https://travis-ci.org/moexmen/superlogger.svg?branch=master)](https://travis-ci.org/moexmen/superlogger)
=======

Rails' default request logging is easy to read for humans but difficult for log aggregators such as Kibana, Graylog and Splunk. Superlogger transforms the logs into key-value pairs for easy parsing and adds useful details like Timestamp and Session ID for tracing purposes.

Default rails logging:
```sh
Started GET "/home/index" for ::1 at 2016-04-11 16:23:27 +0800
  ActiveRecord::SchemaMigration Load (0.1ms)  SELECT "schema_migrations".* FROM "schema_migrations"
Processing by HomeController#index as HTML
  Something Load (0.2ms)  SELECT  "somethings".* FROM "somethings" WHERE "somethings"."paper" = ? AND "somethings"."stone" = ?  ORDER BY "somethings"."id" ASC LIMIT 1  [["paper", "123"], ["stone", "456"]]
  Rendered home/_partial.html.erb (0.2ms)
  Rendered home/index.html.erb within layouts/application (5.2ms)
Completed 200 OK in 283ms (Views: 271.6ms | ActiveRecord: 0.6ms)

Started GET "/assets/application.self-e80e8f2318043e8af94dddc2adad5a4f09739a8ebb323b3ab31cd71d45fd9113.css?body=1" for ::1 at 2016-04-11 16:23:27 +0800

Started GET "/assets/application.self-8f06a73c35179188914ab50e057157639fce1401c1cdca640ac9cec33746fc5b.js?body=1" for ::1 at 2016-04-11 16:23:27 +0800
```

Machine-readable logging with Superlogger:
```sh
2016-04-11 16:18:22.279 | b48534ea049a | I | middleware:28 | method=GET | path=/home/index | ip=::1
2016-04-11 16:18:22.293 | b48534ea049a | D | action_controller_log_subscriber:9 | controller=HomeController | action=index | params={}
2016-04-11 16:18:22.305 | b48534ea049a | D | active_record_log_subscriber:24 | sql=SELECT  "somethings".* FROM "somethings" WHERE "somethings"."paper" = ? AND "somethings"."stone" = ?  ORDER BY "somethings"."id" ASC LIMIT 1 | params=["'123'", "'456'"] | duration=0.48
2016-04-11 16:18:22.316 | b48534ea049a | D | action_view_log_subscriber:6 | view=_partial.html.erb | duration=0.3
2016-04-11 16:18:22.316 | b48534ea049a | D | action_view_log_subscriber:6 | view=index.html.erb | duration=5.6
2016-04-11 16:18:22.541 | b48534ea049a | I | action_controller_log_subscriber:29 | status=200 | total_duration=247.16 | view_duration=235.25 | db_duration=0.78
```

## Features ##
- Timestamp (milliseconds)
- Session ID for logs across requests
- Key-value pairs for log data
- Muting of assets logging
- File and line numbers
- Recording of IP address

## Installation ##

Add superlogger to your application's Gemfile

```ruby
gem "superlogger"
```

And then execute:

```sh
$ bundle
```

## Usage ##

```ruby
require 'superlogger'

class SomeClass
    include Superlogger

    def some_method
        Logger.debug name:'john', age: '21'
        Logger.info name:'john', age: '21'
        Logger.warn name:'john', age: '21'
        Logger.error name:'john', age: '21'
        Logger.fatal name:'john', age: '21'
    end
end
```

## Output Format ##
```sh
2015-03-26 23:37:38.086 | 970298669a40   | I            | log_subscriber:24           | status:200 | total:858.35 | view:597.46 | db:34.96
< timestamp >           | < session id > | < severity > | < file >:< line num >       | < data you pass in ... >
```

### Severity Levels ###
- **D** - Debug
- **I** - Info
- **W** - Warn
- **E** - Error
- **F** - Fatal
