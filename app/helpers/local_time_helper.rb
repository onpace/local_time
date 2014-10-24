module LocalTimeHelper
  DEFAULT_FORMAT = '%B %e, %Y %l:%M%P'

  def local_time(time, options = {})
    time   = utc_time(time)
    format = time_format(options.delete(:format))

    options[:data] ||= {}
    options[:data].merge! local: :time, format: format

    time_tag time, time.strftime(format), options
  end

  def local_date(time, options = {})
    options.reverse_merge! format: '%B %e, %Y'
    local_time time, options
  end

  def local_time_ago(time, options = {})
    time = utc_time(time)

    options[:data] ||= {}
    options[:data].merge! local: 'time-ago'

    time_tag time, time.strftime(DEFAULT_FORMAT), options
  end

  def utc_time(time_or_date)
    if time_or_date.respond_to?(:in_time_zone)
      time_or_date.in_time_zone.utc
    else
      time_or_date.to_time.utc
    end
  end

  def local_time_count_down(time, options = {})
    time = utc_time(time)
    past_string = options.delete(:past)
    options[:data] ||= {}
    options[:data].merge! local: 'time-count-down'

    time_tag time, "#{options[:data][:prefix]}#{distance_from_now(time, past_string)}", options
  end

  def distance_from_now(time, past_string = nil)
      difference = time.to_i - Time.now.to_i
      text = ""
      s_in_m, m_in_h, h_in_d = [1.minute.seconds, 1.hour /  1.minute, 1.day / 1.hour]

      return past_string if past_string && difference < 0
      sign = difference < 0 ? "-" : ""
      difference = difference.abs
      seconds    =  difference % s_in_m
      difference = (difference - seconds) / s_in_m
      minutes    =  difference % m_in_h
      difference = (difference - minutes) / m_in_h
      hours      =  difference % h_in_d
      difference = (difference - hours)   / h_in_d
      days       =  difference

      text = "#{seconds}s" if minutes ==0 && hours == 0 && days == 0 
      text = "#{minutes}m" + text if minutes !=0 && days == 0
      text = "#{hours}h" + text if hours !=0 && days.abs < 2
      text = "#{days}d" + text if days != 0
      sign + text
    end

  private
    def time_format(format)
      if format.is_a?(Symbol)
        if (i18n_format = I18n.t("time.formats.#{format}", default: [:"date.formats.#{format}", ''])).present?
          i18n_format
        elsif (date_format = Time::DATE_FORMATS[format] || Date::DATE_FORMATS[format])
          date_format.is_a?(Proc) ? DEFAULT_FORMAT : date_format
        else
          DEFAULT_FORMAT
        end
      else
        format.presence || DEFAULT_FORMAT
      end
    end
end
