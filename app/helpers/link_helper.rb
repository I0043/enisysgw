# encoding: utf-8
module LinkHelper
  def action_menu(type, link = nil, options = {})
    action = params[:action]
    
    if action =~ /index/
      return '' if [:index, :show, :edit, :destroy].index(type)
    elsif action =~ /(show|destroy)/
      return '' unless [:index, :edit, :destroy].index(type)
    elsif action =~ /(new|create)/
      return '' unless [:index].index(type)
    elsif action =~ /(edit|update)/
      return '' unless [:index, :show].index(type)
    end
    
    if type == :destroy
      options[:confirm] = t("rumi.message.confirm.delete")
      options[:method]  = :delete
    end
    
    if link.class == String
      return link_to(type, link, options)
    elsif link.class == Array
      return link_to(link[0], link[1], options)
    else
      return link_to(type, url_for(:action => type), options)
    end
  end
  
  def link_to(*params)
    labels = {
      up: t("rumi.link.up"),
      index: t("rumi.link.index"),
      list: t("rumi.link.index"),
      show: t("rumi.link.show"),
      new: t("rumi.link.new"),
      edit: t("rumi.link.edit"),
      delete: t("rumi.link.delete"),
      destroy: t("rumi.link.delete"),
      open: t("rumi.link.publish"),
      enabale: t("rumi.link.enabale"),
      disable: t("rumi.link.disable"),
      recognize: t("rumi.link.recognize"),
      publish: t("rumi.link.publish"),
      close: t("rumi.link.close")
    }
    params[0] = labels[params[0]] if labels.key?(params[0])
    
    options = params[2]

    if options && options[:method] == :delete
      options[:method] = nil
      
      onclick = "var f = document.createElement('form');" \
        "f.style.display = 'none';" \
        "this.parentNode.appendChild(f);" \
        "f.method = 'POST';" \
        "f.action = this.href;" \
        "var m = document.createElement('input');" \
        "m.setAttribute('type', 'hidden');" \
        "m.setAttribute('name', '_method');" \
        "m.setAttribute('value', 'delete');" \
        "f.appendChild(m);" \
        "var s = document.createElement('input');" \
        "s.setAttribute('type', 'hidden');" \
        "s.setAttribute('name', 'authenticity_token');" \
        "s.setAttribute('value', '#{form_authenticity_token}');" \
        "f.appendChild(s);" \
        "f.submit();"

      if options[:confirm]
        onclick = "if (confirm('#{options[:confirm]}')) {#{onclick}};"
        options[:confirm] = nil
      end
      options[:onclick] = onclick + "return false;"
    end
    super(*params)
  end

  def link_to_with_external_check(caption, uri, options={})
    options_wrk = options.dup
    options_wrk['class'] = 'ext' if link_external?(uri)
    return link_to(caption, uri, options_wrk)
  end

  def link_external?(uri)
    require 'uri'
    return false if uri.index('://').nil?
    parsed = URI.parse(uri)
    case parsed.class.to_s
    when 'URI::Generic'
      return false
    when 'URI::HTTP'
      rails_env = ENV['RAILS_ENV']
      rails_env = 'development' if rails_env == 'test'
      trans_hash_raw = YAML.load_file('config/site.yml')
      return ( parsed.host != trans_hash_raw[rails_env]['domain'] ) rescue raise t("rumi.message.site_yml")
    else
      return true
    end
  end

  def link_to_list(item, caption = t("rumi.link.open"), options={})
    case Site.mode
    when 'admin'
      link_to_with_external_check caption, url_for(:action => :index, :parent => item)
    when 'public'
      return nil if options[:vri].nil?
    end
  end

  alias :link_to_explore :link_to_list

  def link_to_show(item, caption = t("rumi.link.show"), options={})
    caption = nz(caption, t("rumi.link.show"))
    case Site.mode
    when 'admin'
      uri = url_for(:action => :show, :id => item)
    when 'public'
      uri = url_for("#{Site.current_node.public_uri}#{item}")
    end
    link_to_with_external_check caption, uri, options
  end

  def link_to_edit(item, caption = t("rumi.link.edit"), options={})
    caption = nz(caption, t("rumi.link.edit"))
    case Site.mode
    when 'admin'
      uri = url_for(:action => :edit, :id => item)
    when 'public'
      uri = url_for("#{Site.current_node.public_uri}#{item}/edit")
    end
    opt = options.dup
    uri = "#{uri}?#{opt[:qs]}" if !opt[:qs].blank?
    opt.delete :qs
    link_to_with_external_check caption, uri, opt
  end

  def link_to_destroy(item, caption = t("rumi.link.delete"), options={})
    caption = nz(caption, t("rumi.link.delete"))
    opt = HashWithIndifferentAccess.new(options)
    opt[:confirm] = nz(options[:confirm], t("rumi.message.confirm.delete"))
    opt[:method] = :delete
    case Site.mode
    when 'admin'
      uri = url_for(:action => :destroy, :id => item)
    when 'public'
      uri = url_for("#{Site.current_node.public_uri}#{item}")
    end
    uri = "#{uri}?#{opt[:qs]}" if !opt[:qs].blank? && params[:c1].blank?
    uri = "#{uri}?c1=1}" if opt[:qs].blank? && !params[:c1].blank?
    uri = "#{uri}?#{opt[:qs]}&c1=1" if !opt[:qs].blank? && !params[:c1].blank?
    opt.delete :qs
    link_to_with_external_check caption, uri, opt
  end

  def link_to_id(action, id, caption, base_uri)
      link_to_with_external_check caption, url_for("#{base_uri}#{id}/#{action}")
  end

  def sort_link(title, sort_keys, path_index, field_name, other_query_string='')
    other_query_string = nz(other_query_string, '')
    ret = sort_keys == "#{field_name}%20asc" ? '▲' : link_to_with_external_check('▲', path_index + "?sort_keys=" + "#{field_name}%20asc" + (other_query_string=='' ? '' : '&amp;' + other_query_string ))
    ret += ' '
    ret += sort_keys == "#{field_name}%20desc" ? '▼' : link_to_with_external_check('▼', path_index + "?sort_keys=" + "#{field_name}%20desc" + (other_query_string=='' ? '' : '&amp;' + other_query_string ))
    ret += ' '
    ret += title
    return ret
  end

end
