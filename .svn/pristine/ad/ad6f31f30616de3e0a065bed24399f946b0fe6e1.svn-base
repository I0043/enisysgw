# encoding: utf-8
class Gw::Tool::Reminder

  def self.checker_api(uid)
    xml_data = ""
    xml_data  << %Q(<?xml version="1.0" encoding="UTF-8"?>)
    xml_data  << %Q(<feed xmlns="http://www.w3.org/2005/Atom">)
    xml_data  << %Q(<id>tag:2011:/api/pref/rm</id>)
    xml_data  << %Q(<title>#{I18n.t("rumi.reminder.name")}</title>)
    xml_data  << %Q(<updated>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
    xml_data  << %Q(</feed>)
    return xml_data
  end

  def self.checker_api_error
    xml_data = ""
    xml_data  << %Q(<?xml version="1.0" encoding="UTF-8"?>)
    xml_data  << %Q(<feed xmlns="http://www.w3.org/2005/Atom">)
    xml_data  << %Q(<id>tag:2011:/api/pref/rm</id>)
    xml_data  << %Q(<title>#{I18n.t("rumi.reminder.name")}</title>)
    xml_data  << %Q(<updated>#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}</updated>)
    xml_data  << %Q(</feed>)
    return xml_data
  end
end
