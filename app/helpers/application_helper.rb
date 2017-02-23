# encoding: utf-8
module ApplicationHelper
  ## nl2br
  def br(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  ## nl2br and escape
  def hbr(str)
    str = html_escape(str)
    str.gsub(/\r\n|\r|\n/, '<br />').html_safe
  end

  ## safe calling
  def safe(alt = nil, &block)
    begin
      yield
    rescue NoMethodError => e
      alt
    end
  end

  ## paginates
  def paginate(items, options = {})
    return '' unless items
    defaults = {
      :params         => p,
      :previous_label => t("rumi.paginate.back_page"),
      :next_label     => t("rumi.paginate.next_page"),
      :link_separator => '<span class="separator"> | </span' + "\n" + '>'
    }

    # TODO: paginate関連のエラーが出る事があるので対応する。「undefined method `total_pages' for # <NoMethodError>」
    links = will_paginate(items, defaults.merge!(options))
    return links if links.blank?
    if Core.request_uri != Core.internal_uri
      links.gsub!(/href="#{URI.encode(Core.internal_uri)}/) do |m|
        m.gsub(/^(href=").*/, '\1' + URI.encode(Core.request_uri))
      end
    end
    links
  end

  def div_notice(str = nil)
    str = flash.now[:notice] || str
    flash.now[:notice] = nil
    Gw.div_notice(str)
  end

  def required_head
    Gw.required_head
  end

  def p_required_head
    Gw.p_required_head
  end

  def required(str='※')
    Gw.required(str)
  end

  def p_required(str='※')
    Gw.p_required(str)
  end

  def detail(str='※')
    Gw.detail(str)
  end

  def filter_select_tag(value, relation_name, params, options={})
    before  = options[:before]  ? options[:before]  : [[t("rumi.search.all"), :all]]
    after   = options[:after]   ? options[:after]   : []
    default = options[:default] ? options[:default] : nil
    select_tag( value ,options_for_select( Gw.yaml_to_array_for_select_with_additions(before, relation_name, after), params[value] ? params[value] : default) )
  end
end
