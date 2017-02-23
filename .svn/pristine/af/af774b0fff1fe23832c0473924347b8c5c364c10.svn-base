# -*- encoding: utf-8 -*-
class Gwbbs::Itemdelete < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::ControlCommon
  include Gwboard::Model::AttachFile
  include Gwbbs::Model::Systemname

  validates_presence_of :limit_date

  def item_home_path
    return '/gwbbs/itemdeletes'
  end

  def item_path
    return "#{item_home_path}"
  end

  def delete_path
    return "#{item_home_path}/#{self.title_id}/delete"
  end

  def limit_line
    return [[I18n.t('rumi.gwbbs.select_item.limit_line.day_1'), '1.day'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_1'), '1.month'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_3'), '3.months'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_6'), '6.months'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_9'), '9.months'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_12'),'12.months'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_15'),'15.months'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_18'),'18.months'],
      [I18n.t('rumi.gwbbs.select_item.limit_line.month_24'),'24.months']]
  end

  def delete_fix
    return {
      'none'  => I18n.t('rumi.gwbbs.select_item.limit_line.none') ,
      '1.day' => I18n.t('rumi.gwbbs.select_item.limit_line.day_1') ,
      '3.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_3') ,
      '6.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_6') ,
      '9.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_9') ,
      '12.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_12') ,
      '15.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_15') ,
      '18.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_18') ,
      '24.months'  => I18n.t('rumi.gwbbs.select_item.limit_line.month_24')
    }
  end

end
