# -*- encoding: utf-8 -*-
class Gw::UserProperty < Gw::Database
  include System::Model::Base

  scope :gwmonitor_help_links, -> { where(class_id: 3, name: 'gwmonitor', type_name: 'help_link') }

  def self.is_todos_display?

    raise "Do not call the method!!"

    todos_display = false
    todo_settings = Gw::Model::Schedule.get_settings 'todos', {}
    if todo_settings.key?(:todos_display_schedule)
      todos_display = true if todo_settings[:todos_display_schedule].to_s == '1'
    end
    return todos_display
  end

  def self.load_gwmonitor_help_links
    help = self.gwmonitor_help_links.first

    helps = JsonParser.new.parse(help.options) rescue Array.new(3, [''])
    helps.map{|help| help[0].to_s}
  end
end
