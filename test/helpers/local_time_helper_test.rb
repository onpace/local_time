require_relative '../../app/helpers/local_time_helper'
require 'active_support/all'
require 'action_view'
require 'minitest/autorun'

I18n.enforce_available_locales = false

class LocalTimeHelperTest < MiniTest::Unit::TestCase
  include ActionView::Helpers::DateHelper, ActionView::Helpers::TagHelper, ActionView::Helpers::OutputSafetyHelper
  include LocalTimeHelper

  def setup
    @original_zone = Time.zone
    Time.zone = ActiveSupport::TimeZone["Central Time (US & Canada)"]
    I18n.backend.store_translations(:en, {
      time: { formats: { simple_time: "%b %e" } },
      date: { formats: { simple_date: "%b %e" } } })
    Time::DATE_FORMATS[:time_formats_simple_time] = '%b %e'
    Date::DATE_FORMATS[:date_formats_simple_date] = '%b %e'

    @date = "2013-11-21"
    @time = Time.zone.parse(@date)
    @time_utc = "2013-11-21 06:00:00 UTC"
    @time_js = "2013-11-21T06:00:00Z"
  end

  def teardown
    Time.zone = @original_zone
  end

  def test_utc_time_with_a_date
    date = Date.parse(@date)
    assert_equal @time_utc, utc_time(date).to_s
  end

  def test_utc_time_with_a_local_time
    assert_equal @time_utc, utc_time(@time).to_s
  end

  def test_utc_time_with_a_utc_time
    assert_equal @time_utc, utc_time(@time.utc).to_s
  end

  def test_local_time
    expected = %Q(<time data-format="%B %e, %Y %l:%M%P" data-local="time" datetime="#{@time_js}">November 21, 2013  6:00am</time>)
    assert_equal expected, local_time(@time)
  end

  def test_local_time_with_format
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}">Nov 21</time>)
    assert_equal expected, local_time(@time, format: '%b %e')
  end

  def test_local_time_with_i18n_format
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}">Nov 21</time>)
    assert_equal expected, local_time(@time, format: :simple_time)
  end

  def test_local_time_with_date_formats_format
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}">Nov 21</time>)
    assert_equal expected, local_time(@time, format: :time_formats_simple_time)
  end

  def test_local_time_with_missing_i18n_and_date_formats_format
    expected = %Q(<time data-format="%B %e, %Y %l:%M%P" data-local="time" datetime="#{@time_js}">November 21, 2013  6:00am</time>)
    assert_equal expected, local_time(@time, format: :missing_format)
  end

  def test_local_time_with_date_formats_proc_format
    Time::DATE_FORMATS[:proc] = proc { |time| "nope" }
    expected = %Q(<time data-format="%B %e, %Y %l:%M%P" data-local="time" datetime="#{@time_js}">November 21, 2013  6:00am</time>)
    assert_equal expected, local_time(@time, format: :proc)
  end

  def test_local_time_with_options
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}" style="display:none">Nov 21</time>)
    assert_equal expected, local_time(@time, format: '%b %e', style: 'display:none')
  end

  def test_local_date
    expected = %Q(<time data-format="%B %e, %Y" data-local="time" datetime="#{@time_js}">November 21, 2013</time>)
    assert_equal expected, local_date(@time)
    assert_equal expected, local_date(@time.to_date)
  end

  def test_local_date_with_format
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}">Nov 21</time>)
    assert_equal expected, local_date(@time.to_date, format: '%b %e')
  end

  def test_local_date_with_i18n_format
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}">Nov 21</time>)
    assert_equal expected, local_date(@time.to_date, format: :simple_date)
  end

  def test_local_date_with_date_formats_format
    expected = %Q(<time data-format="%b %e" data-local="time" datetime="#{@time_js}">Nov 21</time>)
    assert_equal expected, local_date(@time.to_date, format: :date_formats_simple_date)
  end

  def test_local_date_with_missing_i18n_and_date_formats_format
    expected = %Q(<time data-format="%B %e, %Y %l:%M%P" data-local="time" datetime="#{@time_js}">November 21, 2013  6:00am</time>)
    assert_equal expected, local_date(@time.to_date, format: :missing_date_format)
  end

  def test_local_time_ago
    expected = %Q(<time data-local="time-ago" datetime="#{@time_js}">November 21, 2013  6:00am</time>)
    assert_equal expected, local_time_ago(@time)
  end

  def test_local_time_count_down
    expected = %Q(<time data-local="time-count-down" datetime="#{@time_js}">now</time>)
    assert_equal expected, local_time_count_down(@time, past: "now")
  end

  def test_local_time_count_down_with_prefix
    expected = %Q(<time data-local="time-count-down" data-prefix="<b>RX </b>" datetime="#{@time_js}"><b>RX </b>now</time>)
    assert_equal expected, local_time_count_down(@time, data: {prefix: "<b>RX </b>".html_safe}, past: "now")
  end

  def test_distance_from_now_seconds
    expected = distance_from_now(32.seconds.since)
    assert_equal expected, "32s"
  end

  def test_distance_from_now_seconds
    expected = distance_from_now(32.seconds.ago)
    assert_equal expected, "-32s"
  end

  def test_distance_from_now_minutes_with_past_string
    expected = distance_from_now(32.minutes.ago, "digested")
    assert_equal expected, "digested"
  end
  
  def test_distance_from_now_hours_minutes
    expected = distance_from_now(92.minutes.since)
    assert_equal expected, "1h32m"
  end

  def test_distance_from_now_hours_minutes
    expected = distance_from_now(92.minutes.ago)
    assert_equal expected, "-1h32m"
  end

  def test_distance_from_now_minutes
    expected = distance_from_now(120.minutes.since)
    assert_equal expected, "2h"
  end

  def test_distance_from_now_days_hours
    expected = distance_from_now(28.hours.since)
    assert_equal expected, "1d4h"
  end

  def test_distance_from_now_days
    expected = distance_from_now(80.hours.since)
    assert_equal expected, "3d"
  end

  def test_local_time_ago_with_options
    expected = %Q(<time class="date-time" data-local="time-ago" datetime="#{@time_js}">November 21, 2013  6:00am</time>)
    assert_equal expected, local_time_ago(@time, class: "date-time")
  end
end
