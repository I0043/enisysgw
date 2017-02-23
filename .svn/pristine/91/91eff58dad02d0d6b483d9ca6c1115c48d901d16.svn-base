# -*- encoding: utf-8 -*-

module Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile

  def sidelist_style
    str = ''
    styles = []
    styles << %Q[background-image:url(#{self.wallpaper});] if self.wallpaper.present?
    styles << %Q[background-color:#{self.left_index_bg_color};] if self.left_index_bg_color.present?
    str = %Q[style="#{styles.join()}"] if styles.size != 0
    return str
  end

  def states
    {'public' => I18n.t('rumi.state.open'), 'closed' => I18n.t('rumi.state.close')}
  end

  def importance_states
    {'0' => I18n.t('rumi.gwbbs.select_item.oneline_comment.unused'), '1' => I18n.t('rumi.gwbbs.select_item.oneline_comment.use')}
  end

  def category_states
    {'0' => I18n.t('rumi.gwbbs.select_item.oneline_comment.unused'), '1' => I18n.t('rumi.gwbbs.select_item.oneline_comment.use')}
  end

  def one_line_use_states
    {'0' => I18n.t('rumi.gwbbs.select_item.oneline_comment.unused'), '1' => I18n.t('rumi.gwbbs.select_item.oneline_comment.use')}
  end

  def notification_states
    {'0' => I18n.t('rumi.gwbbs.select_item.oneline_comment.unused'), '1' => I18n.t('rumi.gwbbs.select_item.oneline_comment.use')}
  end

  def state_list
    [[I18n.t('rumi.state.open'),"public"], [I18n.t('rumi.state.close'),"closed"]]
  end


  def recognize_states_list
    [[I18n.t('rumi.state.unneed'),"0"],[I18n.t('rumi.state.need'),"1"],[I18n.t('rumi.state.optional'),"2"]]
  end

  def default_limit_line
    return [
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_10'), 10],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_20'), 20],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_30'), 30],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_50'), 50],
      [I18n.t('rumi.gwcircular.select_item.default_limit.line_100'),100]
    ]
  end

  def size_unit_name
    return [
      ['MB', 'MB'],
      ['GB', 'GB']
    ]
  end

  def delete_date_name
    return [
      [I18n.t('rumi.state.unuse'), 'none'],
      [I18n.t('rumi.state.use'), 'use']]
  end

  def use_recognize
    ret = true
    ret = false if self.recognize.to_s == '0'
    return ret
  end

  def use_free_public
    ret = true
    ret = false if self.recognize.to_s == '1'
    return ret
  end

  def use_other_system
    ret = false
    ret = true unless self.other_system_link.blank?
    return ret
  end

  def item_path
    return "#{Core.current_node.public_uri}"
  end

  def new_doc_path
    if self.system_name == 'gwqa'
      return "#{Core.current_node.public_uri}new?title_id=#{self.id}&p_id=Q"
    end
    return "#{Core.current_node.public_uri}new?title_id=#{self.id}"
  end

  def new_portal_doc_path
    ret = "/_admin/#{self.system_name}/docs/new?title_id=#{self.id}"
    ret = "#{ret}&p_id=Q" if self.system_name == 'gwqa'
    return ret
  end

  def show_path
    return "#{Core.current_node.public_uri}#{self.id}/"
  end

  def edit_path
    return "#{Core.current_node.public_uri}#{self.id}/edit"
  end

  def delete_path
    return "#{Core.current_node.public_uri}#{self.id}/delete"
  end

  def update_path
    return "#{Core.current_node.public_uri}#{self.id}/update"
  end

end
