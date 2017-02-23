# encoding: utf-8
def dump(data)
  Sys::Lib::Debugger::Dump.dump_log(data)
end

def error_log(message)
  Rails.logger.error "[ USER ERROR #{I18n.l Time.now, format: :time3} ]: #{message}"
end

def debug_log(data)
  Rails.logger.debug "[ DEBUG #{I18n.l Time.now, format: :time3} ]: #{data.pretty_inspect}"
end
