# -*- encoding: utf-8 -*-
module GwHelper
  def date_format(format, d)
    Gw.date_format(format, d)
  end

  def mock_for_select(str, _options={})
    options = HashWithIndifferentAccess.new(_options)
    idx = 0
    delim = nz(options[:delim], ':')
    in_a = str.is_a?(Array) ? str : str.split(delim)
    ret = in_a.collect{|x|
      idx+=1
      if !options[:value_as_label].blank?
        [x,x]
      elsif !options[:with_idx].blank?
        [idx,x]
      elsif options[:for_radio].nil?
        ['',x]
      else
        [x, idx]
      end
    }
    return options[:to_s].blank? ? ret : Gw.options_for_select(ret, options[:selected])
  end

  def quote_attrs(_params)
    return (hidden_field_tag :sender_action, (params[:sender_action] ? params[:sender_action] : params[:action])) +
      (hidden_field_tag :sender_id, params[:id])
  end

  def get_repeat_mode(_params)
    (!_params[:repeat].nil? ? 2 : _params[:init].nil? ? 1 : nz(_params[:init][:repeat_mode], 1)).to_i
  end

  def gw_js_include_full
    return gw_js_include_yui + gw_js_include_popup_calendar
  end

  def gw_js_include_yui
    return <<EOL
<script type="text/javascript" src="/_common/js/yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/element/element-min.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/button/button-min.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/container/container-min.js"></script>
<script type="text/javascript" src="/_common/js/yui/build/calendar/calendar-min.js"></script>
EOL
  end

  def gw_js_include_popup_calendar
    return <<EOL
<script type="text/javascript" src="/_common/js/popup_calendar/popup_calendar.js"></script>
EOL
  end

  def schedule_settings
    get_settings 'schedules'
  end

  def schedule_prop_settings
    get_settings 'schedule_props'
  end

  def get_settings(key, options={})
    Gw::Model::Schedule.get_settings key, options
  end

  def get_link_piece_published(item)
    text = ""
    if item.published == 'opened'
      text = Gw::EditLinkPiece.published_show(item.published)
    else
      text = required(Gw::EditLinkPiece.published_show(item.published))
    end
    return text.html_safe
  end

  def get_link_piece_state(item)
    text = ""
    if item.state == 'enabled'
      text = Gw::EditLinkPiece.state_show(item.state)
    else
      text = required(Gw::EditLinkPiece.state_show(item.state))
    end
    return text.html_safe
  end

  def get_link_piece_name(item)
    text = ""
    if item.state == 'enabled' && item.published == 'opened'
      text = item.name
    else
      text = required(item.name)
    end
    return text.html_safe
  end
end
