require 'test_helper'
require 'byebug'
require 'pp'

class SuperloggerTest < ActiveSupport::TestCase
  def setup
    @output = StringIO.new
    Rails.logger.extend(ActiveSupport::Logger.broadcast(Superlogger::Logger.new(@output)))

    Dummy::Application.configure do
      # Set to true so that routing error will not raise error in test
      config.action_dispatch.show_exceptions = true
    end
  end

  def request(uri, opts = {})
    env = Rack::MockRequest.env_for(uri).merge(opts)
    _, _, body = Dummy::Application.call(env)

    env
  ensure
    # Must close to prevent recursive locking error when calling app.call(env) multiple times
    body.try(:close)
  end

  def output
    @parsed_output ||= @output.string.split("\n").map do |line|
      JSON.parse(line)
    end
  end

  test 'version' do
    assert_not_nil Superlogger::VERSION
  end

  test 'log format when session is not loaded' do
    request('home/index')

    fields = output.first
    assert fields.key?("level")
    assert fields.key?("ts")
    assert fields.key?("caller")
    assert fields.key?("request_id")
  end

  test 'timestamp' do
    request('home/index')
    assert_equal Time.at(output[0]["ts"]).to_date, Date.today
  end

  test 'with session_id' do
    env = request('home/index')
    assert_match env['rack.session'].id.to_s[0..11], output[0]["session_id"]
  end

  test 'without session_id' do
    Rails.logger.debug var: 'test'
    assert_equal output[0].key?("session_id"), false
  end

  test 'with request_id' do
    request('home/index')
    assert_no_match(/^NR-[[:alnum:]]+$/, output[0]["request_id"])
  end

  test 'without request_id' do
    Rails.logger.debug var: 'test'
    assert_equal output[0].key?("request_id"), false
  end

  test 'caller location' do
    Rails.logger.debug var: 'test'
    assert_equal output[0]["caller"], "test/superlogger_test:#{__LINE__ - 1}"
  end

  test 'silence_rails_rack_logger' do
    request('home/index')
    assert_no_match 'Started GET', output[0]["msg"]
  end

  test 'middleware start' do
    request('home/index', 'REMOTE_ADDR' => '::1')

    fields = output[0]
    assert_match 'GET', fields["method"]
    assert_match '/home/index', fields["path"]
  end

  test 'middleware end' do
    request('home/index', 'REMOTE_ADDR' => '::1')

    fields = output.last
    assert_match 'GET', fields["method"]
    assert_match '/home/index', fields["path"]
    assert_operator fields["response_time"], :>, 0
  end

  test 'action_controller_log_subscriber.start_processing' do
    request('home/index?a=1')

    fields = output[1]
    assert_match 'HomeController', fields["controller"]
    assert_match 'index', fields["action"]
    assert_equal Hash.new.tap {|h| h["a"] ="1"}, fields["params"]
  end

  test 'action_controller_log_subscriber.process_action' do
    request('home/index')

    fields = output[7]
    assert_operator fields["view_duration"], :>, 0
    assert_operator fields["db_duration"], :>, 0
  end

  test 'action_view_log_subscriber.render_template.render_partial.render_collection' do
    request('home/index')

    fields = output[3]
    assert_match 'partial.html.erb', fields["view"]
    assert fields.key?("duration")

    fields = output[4]
    assert_match 'index.html.erb', fields["view"]
    assert fields.key?("duration")
  end

  test 'active_record_log_subscriber.sql' do
    request('home/index')

    fields = output[2]
    assert_match 'SELECT', fields["sql"]
    assert_equal ["123", "456", "1"], fields["params"]
    assert_operator fields["duration"], :>, 0
  end
end
