# encoding: utf-8
module FormHelper
  def select_by_list(form, name, list, options = {}, default_key = nil)
    l = (list.nil? ? [] : list.collect {|a,b|[b,a]})
    l.unshift ['',''] if options[:include_blank]
    options.delete :include_blank unless options[:include_blank].nil?
    select_name = name
    begin
      select_name = "#{form.object_name.to_s}[#{name}]"
    rescue
    end
    select_tag(select_name, options_for_select(l, default_key), options)
  end

  ## tinyMCE
  def init_tiny_mce(options = {})
    settings = []
    options.each do |k, v|
      v = %Q("#{v}") if v.class == String
      settings << "#{k}:#{v}"
    end
    [
      javascript_include_tag("/_common/js/tiny_mce/tiny_mce.js"),
      javascript_include_tag("/_common/js/tiny_mce/init.js"),
      javascript_tag("initTinyMCE({#{settings.join(',')}});")
    ].join("\n")
  end

  def submission_label(name)
    {
      :add       => t("rumi.submit.add"),
      :create    => t("rumi.submit.create"),
      :register  => t("rumi.submit.create"),
      :edit      => t("rumi.submit.edit"),
      :update    => t("rumi.submit.update"),
      :change    => t("rumi.submit.change"),
      :delete    => t("rumi.submit.delete")
    }[name]
  end

  def submit(*args)
    make_tag = Proc.new do |_name, _label|
      _label ||= submission_label(_name) || _name.to_s.humanize
      submit_tag(_label, :name => "commit_#{_name}", :class => _name)
    end

    h = '<div class="submitters">'
    if args[0].class == String || args[0].class == Symbol
      h += make_tag.call(args[0], args[1])
    elsif args[0].class == Hash
      args[0].each {|k, v| h += make_tag.call(k, v) }
    elsif args[0].class == Array
      args[0].each {|v, k| h += make_tag.call(k, v) }
    end
    h += '</div>'
  end

  def submit_for(form, options = {})
    js_submitter = options[:js_submitter] || nil
    caption = options[:caption] || 'Submit'
    no_out_div = options[:no_out_div]
    [:js_submitter, :caption, :no_out_div].each {|x| options.delete x unless options[x].nil?}
    if js_submitter.nil?
      ret = form.submit(caption, options)
    else
      options[:id] = options[:id] || 'item_submit'
      options[:name] = options[:name] || 'commit'
      options[:onclick] = js_submitter
      ret = button_to(caption,'javascript:void(0)', options)
    end
    return no_out_div ? ret.html_safe : ('<div class="submitters">' + ret + '</div>').html_safe
  end

  def submit_for_create(form, options = {})
    options[:caption] = t("rumi.submit.create") if options[:caption].nil?
    submit_for(form, options)
  end

  def submit_for_update(form, options = {})
    options[:caption] = t("rumi.submit.update") if options[:caption].nil?
    submit_for(form, options)
  end

  def tool_tiny_mce(base_url = "/", options = {})
    render :partial => 'system/tool/tiny_mce/init', :locals => {:base_url => base_url, :options => options}
  end

  def radio(form, name, list, options = {})
    k,v,br,html = '','','',''
    html_a = []
    force_tag = options[:force_tag]
    options.delete :force_tag
    opt_return_array = options[:return_array]
    options.delete :return_array

    radio_1line = proc {|v,k|
      _v = v
      _text = ''
      unless options[:text_field].nil?
        md = _v.match(/^t:(.+?):(.+)$/)
        _v = md[2] if !md.nil?
        _text = form.text_field(md[1], :style => 'width:10em;') if !md.nil?
      end
      selected = params.blank? ? false : params[form.object_name].blank? ? false : "#{params[form.object_name][name]}"=="#{k}"
      selected = options[:selected].blank? ? false : "#{options[:selected]}"=="#{k}"
      radio_w = force_tag.blank? ? form.radio_button(name, k, options) :
        radio_button_tag("#{form.object_name}[#{name}]", k, selected, options)
      html_a.push "#{radio_w}" +
        "<label for=\"#{form.object_name}_#{name}_#{k.to_s}\">#{_v}</label>#{_text}#{br}\n"
    }

    br = options[:br].nil? ? '' : '<br />'
    if list.class == Array
      list.each do |v, k|
        radio_1line.call(v,k)
      end
    else
      list.each do |k, v|
        radio_1line.call(v,k)
      end
    end
    return !opt_return_array.blank? ? html_a : "#{options[:prefix]}#{Gw.join(html_a, options[:delim])}#{options[:suffix]}".html_safe
  end

  def check_boxes(form, name, list, _options = {})
    options = HashWithIndifferentAccess.new(_options)
    mode = nz(options[:form_type])
    options.delete :form_type
    delim = nz(options[:delim], ':')
    selected = nz(options[:selected_str], '').split(delim)
    options.delete :selected_str
    options.delete :check_with_to_s
    a_cbs = []
    form_name = mode.blank? ? form.object_name : form
    list.each_with_index do |item,idx|
      id = "#{form_name}[#{name}][#{idx}]"
      check_ind = !selected.index(item[1]).nil? || !selected.index(item[1].to_s).nil?
      a_cbs.push check_box_tag(id, "#{item[1]}", check_ind, options) +
        label_tag(id, "#{item[0]}", options)
    end
    ret = a_cbs.join '&nbsp;'
    ret = a_cbs.join '<br />' if options[:mode] == "smart"
    return ret
  end

  def date_picker6(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['',t("rumi.strftime.year"),t("rumi.strftime.month"),t("rumi.strftime.day"),'−',t("rumi.strftime.hour"),t("rumi.strftime.min"), '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>minute_interval,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=>'/_common/themes/gw/files/icon/ic_act_calendar.gif',
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour
      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end
      unless _selected_min_flg
        _selected_min = 0
        value = Time.local(value.year, value.month, value.day, value.hour, _selected_min, value.sec)
      end
      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]

    ret += !%w(date datetime).index(mode).nil? ?
      calendar_date_select_tag(tag_name, value, options_calendar_date_select) :
      hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret += <<-EOL
<script type="text/javascript">
//<![CDATA[
var update_#{tag_id} = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  if (mode == 'datetime' || mode == 'date')
    ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + '-' + $('#{Gw.idize("#{tag_name}_2i")}').value + '-' + $('#{Gw.idize("#{tag_name}_3i")}').value;
EOL
    if tag_id == 'item_st_at'
      ret += <<-EOL
  if (mode == 'datetime' || mode == 'time') {
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
    var hne = $('#{Gw.idize("#{tag_name}_4i")}').value;
    hne-=0;
    hne = hne + 1;
    hne+"";
    var hned = hne + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
  }
  var sta;
  var stb;
  sta = $('item_st_at_4i').value;
  stb = $('item_st_at_5i').value;
  $('item_ed_at_4i').value = sta;
  $('item_ed_at_5i').value = stb;
  sta-=0;
  stb-=0;
  if (sta < 23) {
    $('item_ed_at_4i').selectedIndex = sta + 1;
  }
  sty = $('item_st_at_1i').value;
  stm = $('item_st_at_2i').value;
  std = $('item_st_at_3i').value;
  sty-=0;
  stm-=0;
  std-=0;
  sty = sty - 2005;
  stm = stm - 1;
  std = std - 1;
  $('item_ed_at_1i').selectedIndex = sty;
  $('item_ed_at_2i').selectedIndex = stm;
  $('item_ed_at_3i').selectedIndex = std;

EOL
    elsif tag_id == 'item_repeat_st_time_at'

      ret += <<-EOL
  if (mode == 'datetime' || mode == 'time') {
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
    var hne = $('#{Gw.idize("#{tag_name}_4i")}').value;
    hne-=0;
    hne = hne + 1;
    hne+"";
    var hned = hne + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
  }
  var sta;
  var stb;
  sta = $('item_repeat_st_time_at_4i').value;
  stb = $('item_repeat_st_time_at_5i').value;
  $('item_repeat_ed_time_at_5i').value = stb;
  sta-=0;
  stb-=0;
  if (sta < 23) {
    $('item_repeat_ed_time_at_4i').selectedIndex = sta + 1;
  }
EOL
    elsif tag_id == 'item_repeat_st_date_at'

      ret += <<-EOL

  sty = $('item_repeat_st_date_at_1i').value;
  stm = $('item_repeat_st_date_at_2i').value;
  std = $('item_repeat_st_date_at_3i').value;
  sty-=0;
  stm-=0;
  std-=0;
  sty = sty - 2005;
  stm = stm - 1;
  std = std - 1;
  $('item_repeat_ed_date_at_1i').selectedIndex = sty;
  $('item_repeat_ed_date_at_2i').selectedIndex = stm;
  $('item_repeat_ed_date_at_3i').selectedIndex = std;

EOL
    else
    ret += <<-EOL
  if (mode == 'datetime' || mode == 'time')
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
EOL
    end

    if tag_id == 'item_st_at'

    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
  case 'date': ret = ymd; reted = ymd; break;
  case 'time': ret = hn; reted = hned; break;
  }
  $('item_ed_at').value = reted;

EOL

    elsif tag_id == 'item_repeat_st_time_at'

    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
  case 'date': ret = ymd; reted = ymd; break;
  case 'time': ret = hn; reted = hned; break;
  }
  $('item_repeat_ed_time_at').value = reted;
EOL

    elsif tag_id == 'item_repeat_st_date_at'

    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
  case 'date': ret = ymd; reted = ymd; break;
  case 'time': ret = hn; reted = hned; break;
  }
  $('item_repeat_ed_date_at').value = reted;
EOL
    else
    ret += <<-EOL
  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; break;
  case 'date': ret = ymd; break;
  case 'time': ret = hn; break;
  }
EOL
    end

    ret += <<-EOL
  $('#{tag_id}').value = ret;

}
var update_#{tag_id}_from_calendar = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  value = $('#{tag_id}').value;
  switch(mode) {
  case 'datetime':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2}) +(\\d{1,2}):(\\d{1,2})\\s*$/);
    for (var i=1; i<=5; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
EOL
    if tag_id == 'item_st_at'

    ret += <<-EOL
    if (mode == 'datetime' || mode == 'time') {
      ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + '-' + $('#{Gw.idize("#{tag_name}_2i")}').value + '-' + $('#{Gw.idize("#{tag_name}_3i")}').value;
      hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
      var hne = $('#{Gw.idize("#{tag_name}_4i")}').value;
      hne-=0;
      hne = hne + 1;
      hne+"";
      var hned = hne + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;
    }
    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }

    $('item_ed_at').value = reted;
    $('item_ed_at_1i').value= $('item_st_at_1i').value;
    $('item_ed_at_2i').value= $('item_st_at_2i').value;
    $('item_ed_at_3i').value= $('item_st_at_3i').value;
    var sta;
    var stb;
    sta = $('item_st_at_4i').value;
    stb = $('item_st_at_5i').value;
    $('item_ed_at_4i').value = sta;
    $('item_ed_at_5i').value = stb;
    sta-=0;
    stb-=0;
    if (sta < 23) {
      $('item_ed_at_4i').selectedIndex = sta + 1;
    }
    if (stb == 0) {
      $('item_ed_at_5i').selectedIndex = 0;
    } else if (stb == 30) {
      $('item_ed_at_5i').selectedIndex = 1;
    }

EOL
    else
    ret += <<-EOL
    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }
    $('item_ed_at').value = reted;
EOL

    end

    ret += <<-EOL
    break;
  case 'date':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2})\\s*$/);
    for (var i=1; i<=3; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
    break;
  case 'time':
    var match = value.match(/^\\s*(\\d{1,2}):(\\d{1,2})\\s*$/);
    $('#{tag_id}_4i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_4i'), match[1].sub(/^0/, ''));
    $('#{tag_id}_5i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_5i'), match[1].sub(/^0/, ''));
    break;
  }
  if (mode == 'datetime' || mode == 'date')
  if (mode == 'datetime' || mode == 'time') {
  }
}
//]]>
</script>
EOL
    ret
  end

  def date_picker_prop_switch(f, name, _options={})
    if I18n.default_locale.to_s == 'ja'
      date_picker_prop(f, name, _options)
    else
      date_picker_prop_en(f, name, _options)
    end
  end

  def date_picker_prop(f, name, _options={})
    options = HashWithIndifferentAccess.new(_options)
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first

    if err_flg.nil? && !options[:errors].blank? && name == 'ed_at'
      check_str = I18n.t("rumi.schedule.error_message.prop_other_reservation_conflict_datetime")
      options[:errors]['st_at'].each do |message|
        err_flg = true if !message.index(check_str).blank?
      end
    elsif err_flg.nil? && !options[:errors].blank? && name == 'repeat_ed_date_at'
      check_str = I18n.t("rumi.schedule.error_message.prop_other_reservation_conflict_date")
      options[:errors]['repeat_st_date_at'].each do |message|
        err_flg = true if !message.index(check_str).blank?
      end
    end

    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['',t("rumi.strftime.year"),t("rumi.strftime.month"),t("rumi.strftime.day"),'−',t("rumi.strftime.hour"),t("rumi.strftime.min"), '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''
    ret = '<div>' if options[:m_type] == "smart"

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>30,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=>'/images/icon/calendar_bla.png',
      :clear_button => false
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    if options[:m_type] == "smart"
      ret += '</div>'
      ret += '<div>'
    else
      ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    end
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end

      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += '</div>' if options[:m_type] == "smart"
    ret += captions_caption[2]
    if options[:m_type] == "smart"
      ret +=  hidden_field_tag(tag_name, Gw.time_str(value))
    else
      ret += !%w(date datetime).index(mode).nil? ?
        "<span id=\"#{tag_id}_calendar\">" + calendar_date_select_tag(tag_name, value, options_calendar_date_select) + "</span>" :
        hidden_field_tag(tag_name, Gw.time_str(value))
    end
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret
  end
  
  def date_picker_prop_en(f, name, _options={})
    options = HashWithIndifferentAccess.new(_options)
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    month_a = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    err_flg = options[:errors].nil? ? nil : options[:errors][name].first

    if err_flg.nil? && !options[:errors].blank? && name == 'ed_at'
      check_str = I18n.t("rumi.schedule.error_message.prop_other_reservation_conflict_datetime")
      options[:errors]['st_at'].each do |message|
        err_flg = true if !message.index(check_str).blank?
      end
    elsif err_flg.nil? && !options[:errors].blank? && name == 'repeat_ed_date_at'
      check_str = I18n.t("rumi.schedule.error_message.prop_other_reservation_conflict_date")
      options[:errors]['repeat_st_date_at'].each do |message|
        err_flg = true if !message.index(check_str).blank?
      end
    end

    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['',' ',' ',' ','−',':',' ','']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''
    ret = '<div>' if options[:m_type] == "smart"

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>30,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=>'/images/icon/calendar_bla.png',
      :clear_button => false
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, 1..31, value.day
      ret += datetime_part.call 2, month_a, month_a[value.month.to_i - 1]
      ret += datetime_part.call 3, years_a, value.year
    end
    if options[:m_type] == "smart"
      ret += '</div>'
      ret += '<div>'
    else
      ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    end
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end

      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += '</div>' if options[:m_type] == "smart"
    ret += captions_caption[2]
    if options[:m_type] == "smart"
      ret +=  hidden_field_tag(tag_name, Gw.time_str(value))
    else
      ret += !%w(date datetime).index(mode).nil? ?
        "<span id=\"#{tag_id}_calendar\">" + calendar_date_select_tag(tag_name, value, options_calendar_date_select) + "</span>" :
        hidden_field_tag(tag_name, Gw.time_str(value))
    end
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if !err_flg.nil?
    ret
  end
  
  def date_picker7_switch(f, name, _options={})
    if I18n.default_locale.to_s == 'ja'
      date_picker7(f, name, _options)
    else
      date_picker7_en(f, name, _options)
    end
  end

  def date_picker7(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    err_flg = options[:errors].nil? ? false : options[:errors].has_key?(:st_at)
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['',t("rumi.strftime.year"),t("rumi.strftime.month"),t("rumi.strftime.day"),'−',t("rumi.strftime.hour"),t("rumi.strftime.min"), '']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>minute_interval,
      :clear_button => false,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=> '/images/icon/calendar_bla.png',
      :year_range => years_a
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, years_a, value.year
      ret += datetime_part.call 2, 1..12, value.month
      ret += datetime_part.call 3, 1..31, value.day
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end
      unless _selected_min_flg
        _selected_min = 0
        value = Time.local(value.year, value.month, value.day, value.hour, _selected_min, value.sec)
      end
      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]

    ret += !%w(date datetime).index(mode).nil? ?
      calendar_date_select_tag(tag_name, value, options_calendar_date_select) :
      hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if err_flg
    ret += <<-EOL
<script type="text/javascript">
//<![CDATA[
var update_#{tag_id} = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  if (mode == 'datetime' || mode == 'date')
    ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + '-' + $('#{Gw.idize("#{tag_name}_2i")}').value + '-' + $('#{Gw.idize("#{tag_name}_3i")}').value;
  if (mode == 'datetime' || mode == 'time')
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;

  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; break;
  case 'date': ret = ymd; break;
  case 'time': ret = hn; break;
  }

  $('#{tag_id}').value = ret;
}
var update_#{tag_id}_from_calendar = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  value = $('#{tag_id}').value;
  // pp('onchanged. ' + value);
  // $('#{tag_id}').value = this.value;
  switch(mode) {
  case 'datetime':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2}) +(\\d{1,2}):(\\d{1,2})\\s*$/);
    for (var i=1; i<=5; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));

    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }
    $('item_ed_at').value = reted;

    break;
  case 'date':
    var match = value.match(/^\\s*(\\d{4})-(\\d{1,2})-(\\d{1,2})\\s*$/);
    for (var i=1; i<=3; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
    break;
  case 'time':
    // this route is naver called.
    var match = value.match(/^\\s*(\\d{1,2}):(\\d{1,2})\\s*$/);
    $('#{tag_id}_4i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_4i'), match[1].sub(/^0/, ''));
    $('#{tag_id}_5i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_5i'), match[1].sub(/^0/, ''));
    break;
  }
  if (mode == 'datetime' || mode == 'date')
  if (mode == 'datetime' || mode == 'time') {
  }
}
//]]>
</script>
EOL
    ret
  end
  
  def date_picker7_en(f, name, _options={})
    options_org = HashWithIndifferentAccess.new(_options)
    options = options_org
    value = nz(options[:value], Time.now)
    value = Gw.to_time(value) if value.is_a?(String)
    mode = nz(options[:mode], :datetime).to_s
    object_name = f.is_a?(ActionView::Helpers::FormBuilder) ? f.object_name : f.to_s
    tag_name = "#{object_name}[#{name}]" rescue name
    tag_id = Gw.idize(tag_name)
    this_year = Date.today.year
    years_a = nz(options[:years_range], ((this_year - 5)..(this_year + 5))).to_a
    month_a = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    err_flg = options[:errors].nil? ? false : options[:errors].has_key?(:st_at)
    options.delete :errors
    minute_interval = nz(options[:minute_interval], 15).to_i rescue 15
    minute_interval = 15 if minute_interval <= 0

    captions_default = ['',' ',' ',' ','−',':',' ','']
    captions = options[:captions].nil? ? captions_default :
      Array.new(6){|i| options[:captions][i].nil? ? captions_default[i] : options[:captions][i]}
    captions_ind = captions[1,3] + captions[5,2]
    captions_caption = [captions[0], captions[4], captions[7]]

    ret = ''

    options_calendar_date_select = {
      :hidden => 1, :id=>tag_id, :time=> !%w(time datetime).index(mode).nil?, :minute_interval=>minute_interval,
      :clear_button => false,
      :onchange => "update_#{tag_id}_from_calendar();",
      :image=> '/images/icon/calendar_bla.png',
      :year_range => years_a
    }
    datetime_part = lambda{|idx, _select_options_a, selected|
      select_options_a = _select_options_a.is_a?(Array) ? _select_options_a : _select_options_a.to_a
      _name = "#{object_name}[#{name}(#{idx}i)]"
      select_tag(_name, mock_for_select(select_options_a, :value_as_label=>1, :to_s=>1, :selected=>selected),
          :id=>Gw.idize(_name), :onchange=> "update_#{tag_id}();") +
        captions_ind[idx - 1]
    }
    init_tag_name = "init[#{name}][mode]"
    ret += <<-EOL
#{hidden_field_tag(init_tag_name, "#{mode}")}
#{captions_caption[0]}
EOL
    if !%w(date datetime).index(mode).nil?
      ret += datetime_part.call 1, 1..31, value.day
      ret += datetime_part.call 2, month_a, month_a[value.month.to_i - 1]
      ret += datetime_part.call 3, years_a, value.year
    end
    ret += captions_caption[1] if !%w(datetime).index(mode).nil?
    if !%w(time datetime).index(mode).nil?
      ret += datetime_part.call 4, 0..23, value.hour

      _selected_min_flg = false
      _selected_min = value.min
      minute_array = []
      _min_cnt = 0
      while _min_cnt < 60
        _selected_min_flg = true if _min_cnt == _selected_min
        minute_array << _min_cnt
        _min_cnt += minute_interval
      end
      unless _selected_min_flg
        _selected_min = 0
        value = Time.local(value.year, value.month, value.day, value.hour, _selected_min, value.sec)
      end
      ret += datetime_part.call 5, minute_array, _selected_min

    end
    ret += captions_caption[2]

    ret += !%w(date datetime).index(mode).nil? ?
      calendar_date_select_tag(tag_name, value, options_calendar_date_select) :
      hidden_field_tag(tag_name, Gw.time_str(value))
    ret = %Q(<span class="field_with_errors">#{ret}</span>) if err_flg
    ret += <<-EOL
<script type="text/javascript">
//<![CDATA[
var update_#{tag_id} = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  if (mode == 'datetime' || mode == 'date')
    ymd = $('#{Gw.idize("#{tag_name}_1i")}').value + ' ' + $('#{Gw.idize("#{tag_name}_2i")}').value + ' ' + $('#{Gw.idize("#{tag_name}_3i")}').value;
  if (mode == 'datetime' || mode == 'time')
    hn = $('#{Gw.idize("#{tag_name}_4i")}').value + ':' + $('#{Gw.idize("#{tag_name}_5i")}').value;

  switch(mode) {
  case 'datetime': ret = ymd + ' ' + hn; break;
  case 'date': ret = ymd; break;
  case 'time': ret = hn; break;
  }

  $('#{tag_id}').value = ret;
}
var update_#{tag_id}_from_calendar = function() {
  mode = $('#{Gw.idize(init_tag_name)}').value;
  value = $('#{tag_id}').value;
  // pp('onchanged. ' + value);
  // $('#{tag_id}').value = this.value;
  switch(mode) {
  case 'datetime':
    var match = value.match(/^\\s*(\\d{1,2}) ([A-Za-z]{3}) (\\d{4}) (\\d{1,2}):(\\d{1,2})\\s*$/);
    for (var i=1; i<=5; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));

    switch(mode) {
    case 'datetime': ret = ymd + ' ' + hn; reted = ymd + ' ' + hned; break;
    case 'date': ret = ymd; reted = ymd; break;
    case 'time': ret = hn; reted = hned; break;
    }
    $('item_ed_at').value = reted;

    break;
  case 'date':
    var match = value.match(/^\\s*(\\d{1,2}) ([A-Za-z]{3}) (\\d{4})\\s*$/);
    for (var i=1; i<=3; i++)
      $('#{tag_id}_'+i+'i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_'+i+'i'), match[i].sub(/^0/, ''));
    break;
  case 'time':
    // this route is naver called.
    var match = value.match(/^\\s*(\\d{1,2}):(\\d{1,2})\\s*$/);
    $('#{tag_id}_4i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_4i'), match[1].sub(/^0/, ''));
    $('#{tag_id}_5i').selectedIndex = select_options_get_index_by_value($('#{tag_id}_5i'), match[1].sub(/^0/, ''));
    break;
  }
  if (mode == 'datetime' || mode == 'date')
  if (mode == 'datetime' || mode == 'time') {
  }
}
//]]>
</script>
EOL
    ret
  end

  def form_text_area(form, name, options = {})
    opt = options.dup
    opt[:style] = 'width: 30em; ime-mode: active;' if opt[:style].blank?
    opt[:cols] = 60 if opt[:cols].blank?
    opt[:rows] = 5 if opt[:rows].blank?
    form.text_area name, opt
  end

  def smart_repeat_radio_s(f, repeat_class_id, params)
    weekday_selected_s = Gw.checkbox_to_string(params[:item].blank? ? '' : params[:item][:repeat_weekday_ids])
    repeat_radio_a = radio(f, 'repeat_class_id', Gw.yaml_to_array_for_select('gw_schedules_repeats'), :selected=> nz(repeat_class_id, 0).to_i, :force_tag=>1, :return_array=>1, :onclick=>'switchRepeatClass();')
    repeat_radio_a_w = []
    repeat_weekday_ids = check_boxes(f, 'repeat_weekday_ids', Gw.yaml_to_array_for_select('gw_schedules_repeat_weekday_ids'),
      selected_str: weekday_selected_s, mode: "smart")
    repeat_weekday_ids = %Q(<table id="repeat_weekday_ids_table" style="border: none; display: inline;"><tr><td>#{t("rumi.schedule.message.repeat_select")}<br/>#{repeat_weekday_ids}</td></tr></table>)
    repeat_radio_a_w.push %Q(<tr><th>#{t("rumi.schedule.message.rule")}#{required}</th></tr><tr><td>)
    repeat_radio_a.each_with_index{|x, i| repeat_radio_a_w.push %Q(#{x}#{i != 2 ? '' : repeat_weekday_ids} )}
    repeat_radio_a_w.push %Q(</td></tr>)
    repeat_radio_s = repeat_radio_a_w.join

    return repeat_radio_s
  end

  def schedule_init(f, params)
    @repeat_class_id = 0
    @repeat_allday_radio_id = @allday_radio_id = 0
    @inquire_to = ""

    @form_kind_id = 0
    if params[:item].present?
      @repeat_class_id = params[:item][:repeat_class_id].to_i
      @allday_radio_id = params[:item][:allday_radio_id].join().to_i
      @repeat_allday_radio_id = params[:item][:repeat_allday_radio_id].join().to_i
      @form_kind_id = params[:item][:form_kind_id].to_i
    end
    @repeat_mode = get_repeat_mode params # 通常：1、繰り返し：2
    @creator_uid = Core.user.id
    @creator_uname = Core.user.name
    @creator_ucode = Core.user.code
    @creator_gid = Core.user_group.id
    @created_at = 'now()'

    case params[:action]
    when 'edit'
      @allday_radio_id = @repeat_allday_radio_id = nz(@item.allday, 0).to_i
      @created_at   = @item.created_at
      @creator_uid  = @item.creator_uid
      @creator_uname = @item.creator_uname
      @creator_ucode = @item.creator_ucode
      @creator_gid  = @item.creator_gid
      @inquire_to  = @item.inquire_to
      if @item.schedule_props.present?
        @form_kind_id = 1
      end

      if @repeat_mode == 1
        d_load_st = @item.st_at
        d_load_ed = @item.ed_at
      else
        raise t("rumi.message.incorrect_call") + "(repeat_mode=#{@repeat_mode})" if @item.repeat.nil?
        params[:item] ={}
        @repeat_class_id = @item.repeat.class_id
        @item.repeat.attributes.reject{|k,v| /_at$/ =~ k || 'id' == k}.each{|k,v|
          params[:item]["repeat_#{k}".to_sym] = v
        }
        d_load_st = Gw.datetime_merge(@item.repeat.st_date_at, @item.repeat.st_time_at)
        d_load_ed = Gw.datetime_merge(@item.repeat.ed_date_at, @item.repeat.ed_time_at)
      end
    when 'new'
      dd = Gw.date8_to_date(params[:s_date], :default=>'')

      now = Time.now
      hour = now.hour # 時間
      min = 0

      _wrk_st = dd.present? ? Gw.date_to_time(dd) : Time.local(now.year, now.month, now.day, hour, min, 0)
      d_load_st = _wrk_st
      d_load_ed = _wrk_st + 60*60
    when 'create', 'update'
      @creator_uid = params[:item][:creator_uid]
      @creator_uname = params[:item][:creator_uname]
      @creator_ucode = params[:item][:creator_ucode]
      @creator_gid = params[:item][:creator_gid]
      @created_at = params[:item][:created_at]
      @form_kind_id = params[:item][:form_kind_id].to_i
      @allday_radio_id = @repeat_allday_radio_id = params[:item][:allday_radio_id].to_i
      if @repeat_mode == 1
        d_load_st = Time.parse(params[:item][:st_at])
        d_load_ed = Time.parse(params[:item][:ed_at])
      else
        d_load_st = Time.parse("#{params[:item][:repeat_st_date_at]} #{params[:item][:repeat_st_time_at]}")
        d_load_ed = Time.parse("#{params[:item][:repeat_ed_date_at]} #{params[:item][:repeat_ed_time_at]}")
      end
    else
      raise t("rumi.message.incorrect_call") + "(action=#{params[:action]})"
    end
    @d_load_st, @d_load_ed = d_load_st, d_load_ed # => for _form_prop initialization

    form_kind_radio = radio(f, 'form_kind_id', Gw.yaml_to_array_for_select('gw_schedules_form_kind_ids'),
        :selected=> nz(@form_kind_id, 0).to_i, :force_tag=>1, :return_array=>1, :onclick=>'form_kind_id_switch();')
    @form_kind_radio_str = Gw.join(form_kind_radio, "")
  end
end
