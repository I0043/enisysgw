# encoding: utf-8
module TableHelper
  def table_to_index2(items, _options = {})
    options = HashWithIndifferentAccess.new(_options)
    cr = "\n"
    return %Q(<div class="notice">#{t("rumi.message.empty.list")}</div>) if items.length == 0
    require 'yaml'
    trans_hash_raw = Gw.load_yaml_files_cache
    action = nz(options[:action], 'index')
    unless options['table_name'].nil?
      hash_name = options['table_name']
    else
      if items.is_a?(ActiveRecord::Base)
        hash_name = items.class.table_name
      elsif items.is_a?(WillPaginate::Collection)
        hash_name = items.last.class.table_name
      elsif items.is_a?(Array)
        hash_name = items.last.class.table_name if items.last.is_a?(ActiveRecord::Base)
      end
    end
    trans_hash = get_trans_hash(trans_hash_raw, hash_name, action)
    options['sort_link'] = nz(options['sort_link'], 1)
    sort_link_options = nz(options['sort_link_options'],{})
    opt_link_to = parse_opt_link_to(options)
    tr_options = {}
    tr_options[:detail] = options[:detail]
    cols = !options['columns'].nil? ? options['columns'] :
      ( !trans_hash['_cols'].nil? ? trans_hash['_cols'].split(':') :
        (items.last.class.column_names.sort == items.last.attribute_names.sort ? items.last.class.column_names : items.last.attribute_names))
    return %Q(<div class="notice">#{t("rumi.message.empty.list")}</div>) if cols.length == 0
    trans_hash = trans_hash.to_a

    if Gw.is_ar_array?(items)
      class_s = nz(options[:class], 'index')
      html = %Q(<table class="#{class_s}">#{cr}) if options[:disable_table_tag].nil?
      html += show_table_caption(options)

      buttons_colgroup = ''
      buttons_colgroup += %Q(  <colgroup class="action"></colgroup>) + cr if opt_link_to['show']    # for show
      buttons_colgroup += %Q(  <colgroup class="action"></colgroup>) + cr if opt_link_to['edit']    # for edit
      buttons_colgroup += %Q(  <colgroup class="action"></colgroup>) + cr if opt_link_to['destroy'] # for edit
      nz(options[:link_to],[]).length.times do buttons_colgroup += %Q(  <colgroup class="action"></colgroup>) + cr end
      html += buttons_colgroup if nf(options[:buttons_right]).blank?

      n_cols = 0
      cols.each do |col|
        begin
          trans = trans_hash.assoc(col.to_s)[1]
        rescue
          trans = col
        end
        trans = nz(trans)
        split_trans = trans.split(':')
        case split_trans[0]
        when 'd','D', 'r', 'n', 'dbraw', 'img'
          html += %Q(  <colgroup class="#{col}"></colgroup>) + cr
          n_cols += 1
        else
          case trans
          when ''
            html += %Q(  <colgroup class="#{col}"></colgroup>) + cr
            n_cols += 1
          when 'x'

          else
            html += %Q(  <colgroup class="#{col}"></colgroup>) + cr
            n_cols += 1
          end
        end
      end
      html += buttons_colgroup if !nf(options[:buttons_right]).blank?

      if options[:disable_header].nil?
        c_s = class_str('action', options)

        html += '  <tr>' + cr
        buttons_header = ''
        buttons_header += '<th class="check"></th>' if !options['check'].blank?
        'explore:show:edit:destroy'.split(':').each_with_index do |col, idx|
          buttons_header += "    <th#{c_s}></th>" + cr if opt_link_to[col]
        end

        nz(options[:link_to],[]).each do |x|
          buttons_header += x && x[:header_caption] ? "    <th#{c_s}>#{x[:header_caption]}</th>" + cr :  "    <th#{c_s}></th>" + cr
        end
        html += buttons_header if nf(options[:buttons_right]).blank?

        cols.each do |col|
          begin
            trans = trans_hash.assoc(col.to_s)[1]
          rescue
            trans = col
          end
          trans = nz(trans)
          split_trans = trans.split(':')

          sort_link_options[:force_td_class] = nz(options[:force_td_class], nil)
          sort_link_options[:force_th_class] = nz(options[:force_th_class], nil)
          sort_link_options[:col] = col

          case split_trans[0]
          when 'd','D', 'r', 'n', 'dbraw', 'img', /f\{(.+)\}/
            html += show_field_th(split_trans[1], options['sort_link'], col, sort_link_options)
          when 't', /f\{(.+)\}/
            html += show_field_th(split_trans[1], options['sort_link'], col, sort_link_options)
          else
            case trans
            when ''
              html += show_field_th(col.humanize, options['sort_link'], col, sort_link_options)
            when 'x'

            else
              html += show_field_th(trans, options['sort_link'], col, sort_link_options)
            end
          end
        end
        html += buttons_header if !nf(options[:buttons_right]).blank?
        html += '  </tr>' + cr
      end

      remember_last_td = {}
      items.each do |item|
        options[:rs] = options[:detail]
        options[:col] = 'action'
        tr_head_str = %Q(<tr#{cycle '', ' class="cycle"'}>)
        html += tr_head_str
        html += "<td>" + (check_box_tag "ids[]", "#{item.id}") + "</td>" if !options['check'].blank?

        part_buttons = ''
        'explore:show:edit:destroy'.split(':').each_with_index do |col, idx|
          if !options['field_td_criteria'].nil? && !options['field_td_criteria'][col].nil? && options['field_td_criteria'][col].is_a?(Proc)

            value_str = options['field_td_criteria'][col].call(item)
            part_buttons += show_field_td(value_str, options)
          else
            opt_link_to_1 = case options["link_to_#{col}"]
            when Proc
              options["link_to_#{col}"].call(item)
            else
              opt_link_to[col]
            end
            opt_col_path = options["#{col}_path".to_sym]
            link_to_caption = [t("rumi.link.open"), t("rumi.link.show"), t("rumi.link.edit"), t("rumi.link.delete")]
            caption_s = nz(options["link_to_#{col}_caption".to_sym], link_to_caption[idx] )
            link_str = if opt_col_path
              opt_col_path_x = get_opt_col_path(opt_col_path, item)
              link_to(caption_s, eval(opt_col_path_x))
            else
              if options[:image_action_button].blank?
                class_s, title_s, _caption_s = %q(nil), %q(nil), "'#{caption_s}'"
              else
                class_s, title_s, _caption_s = %Q('image #{col}'), %Q('#{caption_s}'), %q('&nbsp;')
              end
              col == 'explore' ? link_to_explore(item) :
                eval("link_to_#{col}(item.id, #{_caption_s}, :class=>#{class_s}, :title=>#{title_s})")
            end
            part_buttons += show_field_td(opt_link_to_1 ? link_str : '', options) + cr if opt_link_to[col]
          end
        end

        nz(options[:link_to],[]).each do |lt|
          opt_link_to_x = lt[:proc].is_a?(Proc) ? lt[:proc].call(item) : 1
          if lt[:caption].is_a? Array
            caption_t = nz(lt[:caption][0])
            caption_f = nz(lt[:caption][1])
            caption_nil = nz(lt[:caption][2]) rescue caption_f
          else
            caption_t = lt[:caption]
            caption_f = ''
            caption_nil = ''
          end
          if opt_link_to_x.nil?
            link_to_path_x = caption_nil
          else
            caption_s = opt_link_to_x ? caption_t : caption_f
            if options[:image_action_button].blank?
              class_s, title_s, _caption_s = nil, nil, caption_s
            else
              action_s = !lt[:action].is_a?(Array) ? lt[:action] :
                opt_link_to_x ? lt[:action][0] : lt[:action][1]
              class_s, title_s, _caption_s = %Q(image #{action_s}), %Q(#{caption_s}), %q(&nbsp;)
            end

            _link_opt = {:class=>class_s, :title=>title_s}
            _link_opt[:target] = lt[:target] if lt[:target]
            _link_opt[:class] = lt[:class] if lt[:class]
            link_to_path_x = link_to _caption_s, eval(get_opt_col_path(lt[:path], item)), _link_opt
          end
          part_buttons += show_field_td(link_to_path_x, options) + cr
        end
        html += part_buttons if nf(options[:buttons_right]).blank?

        options.delete :rs

        cols.each do |col|

          options[:col] = col

          trans = trans_hash.assoc(col.to_s)[1] rescue col
          trans = nz(trans)
          field_str, value_str = get_fv(trans, item, col, trans_hash_raw, options)
          unless field_str.nil?
            if !options[:simplize_same_in_column].nil? && !options[:simplize_same_in_column].index(col).nil?
              if nz(remember_last_td[col]) == item.send(col)
                value_str = nz(options[:same_str],'&nbsp;〃')
              else
                remember_last_td[col] = item.send(col)
              end
            end
            html += show_field_td(value_str, options)
          end
        end
        html += part_buttons if !nf(options[:buttons_right]).blank?
        html += '  </tr>' + cr

        unless tr_options[:detail].nil?
          if tr_options[:detail].is_a?(Proc)
            detail_s = tr_options[:detail].call(item).to_s
          else
            col = tr_options[:detail].to_s
            trans = trans_hash.assoc(col)[1] rescue col
            trans = nz(trans)
            field_str, value_str = get_fv(trans, item, col, trans_hash_raw, options)
            detail_s = nz(value_str)
          end
          detail_s = br detail_s if options[:detail_nobr].nil?
          detail = %Q(#{tr_head_str}<td colspan="#{n_cols}">#{detail_s}</td></tr>)
          detail = auto_link detail unless options[:detail_auto_link].nil?
          html += detail
        end
      end
      html += '</table>' if options[:disable_table_tag].nil?
      return html
    else
      raise TypeError, "unknown input type(#{items.class.to_s})"
    end
  end

  def table_to_show(item, options = {})
    cols = item.class.column_names
    html = '<table class="show">' + "\n"
    cols.each do |col|
      begin
        col_title = ::I18n.t("#{item.class.model_name.underscore}.#{col}", :scope => [:activerecord, :attributes], :raise => true)
      rescue
        col_title = col.humanize
      end
      html += '  <tr>' + "\n"
      html += "    <th>#{col_title}</th>\n"
      html += "    <td>#{hbr(item.send(col))}</td>\n"
      html += '  </tr>' + "\n"
    end
    html += '</table>'
    return html
  end

  def table_to_show2(item, _options = {})
    options = HashWithIndifferentAccess.new(_options)
    cr = "\n"
    require 'yaml'
    trans_hash_raw = Gw.load_yaml_files_cache
    action = nz(options[:action], 'show')
    unless options['table_name'].nil?
      hash_name = options['table_name']
    else
      hash_name = item.class.table_name if item.is_a?(ActiveRecord::Base)
    end
    trans_hash = get_trans_hash(trans_hash_raw, hash_name, action)
    cols = !options['columns'].nil? ? options['columns'] :
      ( !trans_hash['_cols'].nil? ? trans_hash['_cols'].split(':') :
        (item.class.column_names.sort == item.attribute_names.sort ? item.class.column_names : item.attribute_names))
    trans_hash = trans_hash.to_a

    class_s = nz(options[:class], 'show')
    html = %Q(<table class="#{class_s}">#{cr}) if options[:disable_table_tag].nil?
    html += show_table_caption(options)
    cols.each do |col|
      trans = trans_hash.assoc(col.to_s)[1] rescue col
      trans = nz(trans)
      field_str, value_str = get_fv(trans, item, col, trans_hash_raw, options)
      show_options = {}
      show_options[:force_td_class] = nz(options[:force_td_class], nil)
      show_options[:force_th_class] = nz(options[:force_th_class], nil)
      show_options[:col] = col
      html += show_field_tr(field_str, value_str, show_options) unless field_str.nil?
    end
    html += '</table>' if options[:disable_table_tag].nil?
    return html
  end

private
  def show_field_tr(f,v, options={})
    c_s = class_str(options[:col], options)
    "<tr><th#{c_s}>#{f}</th><td#{c_s}>#{v}</td></tr>"
  end

  def show_field_th(v = '', sort_link_flag = true, sort_link_field_name = '', sort_link_options = {})
    class_options = {}
    [:force_td_class, :col, :force_th_class].each do |k|
      class_options[k] = sort_link_options[k]
      sort_link_options.delete k
    end unless sort_link_options.nil?
    c_s = class_str(class_options[:col], class_options)

    if sort_link_flag
      return "<th#{c_s}>#{v}</th>" if sort_link_options.blank? || (!sort_link_options['disable_cols'].blank? && !sort_link_options['disable_cols'].index(sort_link_field_name).nil?)
      return %Q(<th#{c_s}>#{sort_link(v, sort_link_options["sort_keys"], sort_link_options["path_index"], sort_link_field_name, sort_link_options["other_query_string"])}</th>)
    else
      return "<th#{c_s}>#{v}</th>"
    end
    return ""
  end

  def show_field_td(v = '', _options={})

    options = HashWithIndifferentAccess.new(_options)
    options.delete :force_th_class

    col_td_class_option = nz(options[:col_td_class], {})
    _tdcls = col_td_class_option[options[:col]] ? col_td_class_option[options[:col]] : ''
    options[:add_class] = _tdcls unless _tdcls.blank?
    c_s = class_str(options[:col], options)

    rs_s = options[:rs].nil? ? '' : ' rowspan="2"'
    "<td#{c_s}#{rs_s}>#{v}</td>"
  end

  def class_str(s, options = {})
    c_s = nil
    _class_name = ((!options[:force_td_class].nil? || !options[:force_th_class].nil?) && Gw.trim(s) != '') ? "#{s}" : ''
    if options[:add_class]
      _class_name = _class_name == '' ? "#{options[:add_class]}" : "#{_class_name} #{options[:add_class]}"
    end
    _class_name == '' ? c_s= '' : c_s = %Q( class="#{_class_name}")

    return c_s
  end

  def get_opt_col_path(opt_col_path, item)
    opt_col_path_x = opt_col_path.dup
    reps = opt_col_path_x.scan(/\[\[(.+?)\]\]/)
    reps.each do |rep|
       opt_col_path_x.sub!(/\[\[#{rep[0]}\]\]/, "#{item.send(rep[0])}")
    end
    opt_col_path_x
  end

  def show_table_caption(options = {})
    html = ''
    class_str = options[:caption_class] ? %Q( class="#{options[:caption_class]}") : ''
    html = "<caption#{class_str}>#{options[:caption]}</caption>" if options[:caption]
    html
  end

  def parse_opt_link_to(options)
    opt_link_to = {}
    opt_link_to['show'] = _op4(options, 'link_to_show', 1)
    opt_link_to['edit'] = _op4(options, 'link_to_edit', nil)
    opt_link_to['destroy'] = _op4(options, 'link_to_destroy', nil)
    opt_link_to['explore'] = _op4(options, 'link_to_explore', nil)
    opt_link_to
  end

  def _op4(obj, key, if_undef)
    if_def_and_falsy = nil
    if_def_and_truthy = 1
    raise TypeError if !obj.is_a?(Hash)
    return if_undef if !obj.key?(key)
    return obj[key] ? (obj[key].to_s == '0' ? if_def_and_falsy : if_def_and_truthy ) : if_def_and_falsy
  end

  def get_trans_hash(trans_hash_raw, hash_name, action)
    trans_hash = {}
    unless hash_name.blank?
      trans_hash_org = trans_hash_raw[hash_name]
      return {} if trans_hash_org.blank?
      unless trans_hash_org['_base'].nil?
        trans_hash_ind = trans_hash_org.dup
        trans_hash_org = trans_hash_raw[trans_hash_org['_base']]
        trans_hash_org = trans_hash_org.deep_merge(trans_hash_ind)
      end
      trans_hash_common = {}
      trans_hash_common = trans_hash_org['_common'] if !trans_hash_org.nil? && !trans_hash_org['_common'].nil?
      trans_hash_action = {}
      trans_hash_action = trans_hash_org['show'] if !trans_hash_org.nil? && action == 'form' && !trans_hash_org['show'].nil?
      trans_hash = trans_hash_org.dup.reject{|k,v| v.is_a?(Hash)}.deep_merge(trans_hash_common).deep_merge(trans_hash_action)
      trans_hash_action = trans_hash_org[action] if !trans_hash_org.nil? && !trans_hash_org[action].nil?
      trans_hash = trans_hash_org.dup.reject{|k,v| v.is_a?(Hash)}.deep_merge(trans_hash_common).deep_merge(trans_hash_action)
    end
    return trans_hash
  end

  def get_fv(trans, item, col, trans_hash_raw, options={})
    options[:noh_cols] = Gw.as_array options[:noh_cols]
    split_trans = trans.split(':')
    field_str = split_trans[1]
    raw_data = item.send(col) rescue ''
    if item.methods.grep(col).blank? && item.attributes.keys.grep(col).blank?
      field_str = split_trans.length > 1 ? split_trans[1] : split_trans[0]
      value_str = raw_data
    else
      field_str, value_str = case split_trans[0]
      when /f\{(.+)\}/
        [split_trans[1], Gw.int_format($1, item.send(col))]
      when 'd'
        d = item.send(col)
        d = d.to_datetime if d.is_a? String
        vd = d.nil? ? '' : d.strftime('%Y-%m-%d %H:%M')
        [split_trans[1], (d.blank? ? '' : vd)]
      when 'D'
        d = item.send(col)
        d = d.to_datetime if d.is_a? String
        vd = d.nil? ? '' : d.strftime('%Y-%m-%d')
        d.nil? ? '' : d.strftime('%Y-%m-%d')
        [split_trans[1], vd]
      when 'r'
        rc = trans_hash_raw[(split_trans[2])].to_a.assoc(item.send(col.to_s))
        rc = trans_hash_raw[(split_trans[2])].to_a.assoc(item.send(col.to_s).to_i) if rc.nil?
        [split_trans[1], rc[1]]

      when 'n'
        item.send(col).to_s.strip != '' ? [nil, nil] : [split_trans[1], hbr(item.send(col))]
      when 'dbraw'

        if item.send(col).blank?
          [split_trans[1], '']
        else
          quote = item.send(col).class.to_s == 'String' ? "'" : ''
          [split_trans[1], Gw::NameValue.get('dbraw', split_trans[2], split_trans[3], "#{split_trans[4]}=#{quote}#{item.send(col)}#{quote}")]
        end

      when 'img'
        c_s = options[:thumbnail].blank? ? '' : %Q( class="thumbnail")
        val = item.send(col).to_s.strip != '' ? %Q(<img src="#{hbr(item.send(col))}" alt=""#{c_s} />) : ''
        [split_trans[1], val]
      else
        detail_nobr_flg = "#{options[:detail]}" == "#{col}" && !options[:detail_nobr].nil?
        case trans
        when ''
          v = if options[:noh_cols].index(col).nil?
            detail_nobr_flg ? item.send(col) : hbr(item.send(col))
          else
            detail_nobr_flg ? item.send(col) : br(item.send(col))
          end rescue ''
          [col.humanize, v]
        when 'x'
          [nil, nil]

        else
          v = if options[:noh_cols].index(col).nil?
            detail_nobr_flg ? item.send(col) : hbr(item.send(col))
          else
            detail_nobr_flg ? item.send(col) : br(item.send(col))
          end rescue ''
          [trans, v]
        end
      end rescue [split_trans[1], raw_data]
    end

    value_str = options['field_td_criteria'][col].call(item) if !options['field_td_criteria'].nil? && !options['field_td_criteria'][col].nil? && options['field_td_criteria'][col].is_a?(Proc)
    return [field_str, value_str]
  end
end

module TableHelper_dust

  def table(items, options = {})
    return 'empty' if items.size == 0
    if options[:cols]
      cols = options[:cols].split(',')
    else
      cols = []; items[0].class.columns.each {|col| cols << col.name; }
    end
    attr = options[:class] ? ' class="' + options[:class] + '"' : ''
    html = "<table#{attr} border=1>\n"
    html += "<tr>\n"
    cols.each do |col|; html += "  <th>#{col}</th>\n"; end
    html += "</tr>\n"
    items.size.times do |i|
      html += "<tr>\n"
      cols.each do |col|; html += "  <td>#{items[i].send(col)}</td>\n"; end
      html += "</tr>\n"
      a = url_for(items[i])
      html += a
    end
    html += "</table>"
    return html
  end

  def th(name, options = {})
    return "<th#{to_css(options)}>#{to_link(name, options)}</th>"
  end

  def td(name, options = {})
    return "<td#{to_css(options)}>#{to_link(name, options)}</td>"
  end

  def to_link(name, options = {})
    return html_escape(name) unless options[:link]
    href = ' href="' + options[:link] + '"'
    return "<a#{href}>#{html_escape(name)}</a>"
  end

  def to_css(options = {})
    css = ''
    css += ' width: ' + options[:size] + ';' if options[:size]
    case options[:type]
    when :num;   css += ' text-align :right;'
    when :label; css += ' text-align :center;'
    when :text;  css += ' text-align :left;'
    end if options[:type]
    return ' style="' + css.strip + '"' if css != ''
  end
end
