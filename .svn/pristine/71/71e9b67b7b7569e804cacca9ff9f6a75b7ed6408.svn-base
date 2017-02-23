#encoding:utf-8
class Gwboard

  def self.add_reminder_circular(uid, title, body, options={})
    fr_u = System::User.where("id=#{uid}").first rescue Core.user
    fr_u = Core.user if fr_u.blank?
    begin
      return true
    rescue => e
      case e.class.to_s
      when 'ActiveRecord::RecordInvalid', 'Gw::ARTransError'
      else
        raise e
      end
      return false
    end
  end
end