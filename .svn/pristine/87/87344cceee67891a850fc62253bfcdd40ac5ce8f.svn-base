# -*- encoding: utf-8 -*-
class Gwcircular::Itemdelete < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  def item_home_path
    return '/gwcircular/itemdeletes'
  end

  def item_path
    return "#{item_home_path}"
  end

  def edit_path
    return '/gwcircular/itemdeletes/0/edit'
  end

  def update_path
    return '/gwcircular/itemdeletes/0'
  end

  def limit_line
    return [[I18n.t('rumi.gwcircular.select_item.limit_line.day_1'), '1.day'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_1') , '1.month'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_3') , '3.months'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_6') , '6.months'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_9') , '9.months'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_12'),'12.months'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_15'),'15.months'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_18'),'18.months'],
      [I18n.t('rumi.gwcircular.select_item.limit_line.month_24'),'24.months']]
  end

  def limit_line_name
    case self.limit_date
    when '1.day'
      I18n.t('rumi.gwcircular.select_item.limit_line.day_1')
    when '1.month'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_1')
    when '3.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_3')
    when '6.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_6')
    when '9.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_9')
    when '12.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_12')
    when '15.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_15')
    when '18.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_18')
    when '24.months'
      I18n.t('rumi.gwcircular.select_item.limit_line.month_24')
    else
      ''
    end
  end
end
