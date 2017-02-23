# encoding: utf-8
class System::Script::Access_log
  class << self
    def delete
      log_write("Access_log.delete start")
      accesslog = System::AccessLog
              .where(System::AccessLog.arel_table[:updated_at].lt(Enisys.config.application['gw.access_log_delete_month'].to_i.month.ago))
      delcnt = accesslog.size
      accesslog.delete_all
      log_write("Total #{delcnt} accesslogs deleted.")
      log_write("Access_log.delete end")
    end

  private
    def log_write(str)
      puts(str)
      dump(str)
    end
  end
end
