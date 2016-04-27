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
      line.split(' | ')
    end
  end

  test 'version' do
    assert_not_nil Superlogger::VERSION
  end

  test 'log format' do
    request('home/index')

    fields = output.first
    assert fields[0].length == 23
    assert fields[1].length == 12
    assert fields[2].length == 12
    assert fields[3].length == 1
    assert_match(/\w:\d+/, fields[4])
  end

  test 'timestamp' do
    request('home/index')
    assert DateTime.parse(output[0][0]).to_date == Date.today
  end

  test 'with session_id' do
    env = request('home/index')
    assert_match env['rack.session'].id[0..11], output[0][1]
  end

  test 'without session_id' do
    Rails.logger.debug var: 'test'
    assert_match(/NS-[[:alnum:]]+/, output[0][1])
  end

  test 'with request_id' do
    request('home/index')
    assert_no_match(/NR-[[:alnum:]]+/, output[0][2])
  end

  test 'without request_id' do
    Rails.logger.debug var: 'test'
    assert_match(/NR-[[:alnum:]]+/, output[0][2])
  end

  test 'log levels' do
    Rails.logger.debug var: 'test'
    Rails.logger.info var: 'test'
    Rails.logger.warn var: 'test'
    Rails.logger.error var: 'test'
    Rails.logger.fatal var: 'test'

    assert output[0][3] == 'D'
    assert output[1][3] == 'I'
    assert output[2][3] == 'W'
    assert output[3][3] == 'E'
    assert output[4][3] == 'F'
  end

  test 'caller location' do
    Rails.logger.debug var: 'test'
    assert output[0][4] == "superlogger_test:#{__LINE__ - 1}"
  end

  test 'silence_rails_rack_logger' do
    request('home/index')
    assert_no_match 'Started GET', output[0][5]
  end

  test 'middleware' do
    request('home/index', 'REMOTE_ADDR' => '::1')

    fields = output[0]
    assert_match 'method=GET', fields[5]
    assert_match 'path=/home/index', fields[6]
    assert_match 'ip=::1', fields[7]
  end

  test 'action_controller_log_subscriber.start_processing' do
    request('home/index?a=1')

    fields = output[1]
    assert_match 'controller=HomeController', fields[5]
    assert_match 'action=index', fields[6]
    assert_match 'params={"a"=>"1"}', fields[7]
  end

  test 'action_controller_log_subscriber.process_action' do
    request('home/index')

    fields = output.last
    assert_match 'status=200', fields[5]
    assert_match(/total_duration=\d.\d/, fields[6])
    assert_operator fields[6].split('=').last.to_f, :>, 0
    assert_match(/view_duration=\d.\d/, fields[7])
    assert_operator fields[7].split('=').last.to_f, :>, 0
    assert_match(/db_duration=\d.\d/, fields[8])
    assert_operator fields[8].split('=').last.to_f, :>, 0
  end

  test 'action_view_log_subscriber.render_template.render_partial.render_collection' do
    request('home/index')

    fields = output[3]
    assert_match 'view=_partial.html.erb', fields[5]
    assert_match 'duration=', fields[6]

    fields = output[4]
    assert_match 'view=index.html.erb', fields[5]
    assert_match 'duration=', fields[6]
  end

  test 'active_record_log_subscriber.sql' do
    request('home/index')

    fields = output[2]
    assert_match 'sql=SELECT', fields[5]
    assert_match 'params=[', fields[6]
    assert_match(/duration=\d.\d/, fields[7])
    assert_operator fields[7].split('=').last.to_f, :>, 0
  end

  test 'escape new lines' do
    Rails.logger.debug var: 'first\nsecond'

    assert_match 'first\\nsecond', output[0].last
  end
end
