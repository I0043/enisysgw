# encoding: utf-8
class Gwcircular::Script::Task

  def self.delete
    dump "#{self}, " + I18n.t("rumi.gwcircular.script.start")
    item = Gwcircular::Itemdelete.new
    item.and :content_id, 0
    item = item.first
    dump "#{self}, " + I18n.t("rumi.gwcircular.script.item_no_set") if item.blank?
    return if item.blank?
    dump "#{self}, " + I18n.t("rumi.gwcircular.script.span_no_set") if item.limit_date.blank?
    return if item.limit_date.blank?
    limit = get_limit_date(item.limit_date)
    return if limit.blank?

    destroy_record(limit)
    dump "#{self}, " + I18n.t("rumi.gwcircular.script.end")
  end

  def self.get_limit_date(limit_date)
    limit = Date.today
    case limit_date
    when "1.day"
      limit = limit.days.ago(1.day)
    when "1.month"
      limit = limit.months_ago(1)
    when "3.months"
      limit = limit.months_ago(3)
    when "6.months"
      limit = limit.months_ago(6)
    when "9.months"
      limit = limit.months_ago(9)
    when "12.months"
      limit = limit.months_ago(12)
    when "15.months"
      limit = limit.months_ago(15)
    when "18.months"
      limit = limit.months_ago(18)
    when "24.months"
      limit = limit.months_ago(24)
    else
      limit = ''
    end
    return limit
  end

  def self.destroy_record(limit)
    @title = Gwcircular::Control.find_by(id: 1)
    if @title.present? && @title.limit_date == 'use'
      @img_path = "public/_attaches/#{@title.system_name}/"
      preparation_limit = Gwbbs::Script::Task.preparation_get_limit_date
      item = Gwcircular::Doc
      doc_item = item.new
      doc_item.and :expiry_date, '<' , limit.strftime("%Y-%m-%d") + ' 00:00:00'
      doc_item.or  {|d|
        d.and :state, 'preparation'
        d.and :created_at, '<', "#{preparation_limit.strftime("%Y-%m-%d")} 00:00:00"
      }
      @items = doc_item.find(:all)
      del_count = 0
      for @item in @items
        destroy_atacched_files
        @item.destroy
        del_count += 1
      end
      dump "#{self}, #{@title.id}, #{@title.dbname}, #{@title.title},#{del_count}"
    end
  end

  def self.sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def self.destroy_atacched_files
    item = Gwcircular::File
    files = item.order('id').where(sql_where)
    files.each do |file|
      file.destroy
    end
  end
end
