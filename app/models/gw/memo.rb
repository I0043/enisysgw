# encoding: utf-8
class Gw::Memo < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :title
#  gw_validates_datetime :ed_at

  has_many :memo_users, :foreign_key => :schedule_id, :class_name => 'Gw::MemoUser', :dependent=>:destroy
  has_one :created_by, :primary_key => :uid, :foreign_key => :id, :class_name => 'System::User'

  def deletable?
    return true
  end

  def editable?
    return true
  end

  def self.cond(_uid = nil)
    return "" if _uid.nil? && (Core.user.nil? || Core.user.id.nil?)
    uid = nz(_uid, Core.user.id)
    return "(gw_memos.class_id = 1 and gw_memos.uid = #{uid})"
  end

  def send_mail_after_addition(uids)
    if self.is_system == 1
      return
    end

    uids = uids.to_s.split(':') if !uids.is_a?(Array)
    uids = uids.uniq.collect{|x| x.to_i}

    target_users = []
    uids.each do |uid|
      target_users << System::User.where("id=#{uid}").first.name if System::User.where("id=#{uid}").count(:all)> 0
    end
    if uids.size > 1
      same_send_users = I18n.t("rumi.memo.same_send") + "：" + target_users.join(',')
    else
      same_send_users = ""
    end
    send_addresses = []
    uids.each{|uid|

      up = Gw::Model::Schedule.get_settings(:mobiles, :uid=>uid)
      send_flg_1 = up[:ktrans].to_s == "1"
      send_flg_2 = Gw.is_valid_email_address?(up[:kmail])
      send_addresses.push up[:kmail] if send_flg_1 && send_flg_2
    }
    system_settings = Gw::NameValue.get('yaml', nil, "gw_mobiles_settings_system_default")
    admin_email_from = nz(system_settings[:admin_email_from],"admin@127.0.0.1")
    item = self
    creator_u = Gw::Model::Schedule.get_user(item.uid) rescue nil
    creator_name = creator_u.name rescue nil
    creator_email = ''
    creator_email = %Q[#{creator_u.email}] unless creator_u.email.blank?
    email_from = admin_email_from
    subject = system_settings[:subject]+creator_name
    message_add_ln = lambda{|fld_name, body| body.blank? ? '' : fld_name.blank? ? "#{body}\n" : %Q(#{fld_name}:) +" #{body}\n"}
    message = I18n.t("rumi.memo.get_at") + " \n\n"
    [[I18n.t("rumi.memo.title"), item.title],['', item.body],[I18n.t("rumi.memo.group"), item.fr_group],[I18n.t("rumi.memo.user"), item.fr_user],[I18n.t("rumi.memo.ed_at"), Gw.datetime_str(item.ed_at)],[I18n.t("rumi.memo.creator"), "#{creator_name}<#{creator_email}>"],['',same_send_users]].each {|x| message += message_add_ln.call x[0], x[1] }
    send_addresses.each{|mail_to| Gw.send_mail(email_from, mail_to, subject, message)}
  end

  def save_with_rels(item, mode)
    di = item.dup
    di.delete :schedule_users
    users = ::JsonParser.new.parse(item['schedule_users_json'])
    di.delete :schedule_users_json
    _item = self
    _item.st_at = Gw.date_common(Gw.get_parsed_date(item[:st_at])) rescue nil
    _item.ed_at = Gw.date_common(Gw.get_parsed_date(item[:ed_at])) rescue nil
    _item.class_id = 1
    _item.title = item[:title]

    _item.uid = Core.user.id if /`create'/ =~ caller.grep(/gw_dev/).grep(/memos/)[0] || _item.uid.nil?
    validate = true
    if users.blank?
      self.errors.add :memo_user, I18n.t("rumi.error.select")
      validate = false
    end
    if item[:title].blank?
      self.errors.add :title, I18n.t("rumi.error.input")
      validate = false
    end
    if validate==false
      return false
    end
    begin
      transaction do

        if mode == :update
          _item.update_attributes!(di)
          Gw::MemoUser.where("schedule_id=#{self.id}").destroy_all
        else
          _item.update_attributes!(di)
        end
        uids = []
        users.each do |user|
          item_sub = Gw::MemoUser.new()
          item_sub.schedule_id = _item.id
          item_sub.class_id = user[0].to_i
          item_sub.uid = user[1]
          case item_sub.class_id
          when 1
            uids.push user[1]
          else

            raise TypeError, I18n.t("rumi.message.incorrect_call") + "(:class_id=#{item_sub.class_id}"
          end
          item_sub.save!
        end
        _item.send_mail_after_addition uids
      end
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

  def _send_cls(s_send_cls='1')
    _uid    = Core.user.id
    _target = self.memo_users

    case s_send_cls.to_i
    when 1

      if self.uid == _uid
        if _target.length == 0
          ''
        else
          ("#{System::User.get(nz(self.uid,0)).display_name}=>" rescue '') + I18n.t("rumi.memo.reception")
        end
      else
        ("#{System::User.get(nz(self.uid,0)).display_name}=>" rescue '') + I18n.t("rumi.memo.reception")
      end
    when 2

      if self.uid == _uid
        user_html = _target.collect{|x|
          mobile_class = 'mobileOff'
          if mobile_class == 'mobileOn'
            class_str = "<span class=\"#{mobile_class}\">"
            class_str_end = '</span>'
          else
            class_str = class_str_end = ''
          end
          class_str + System::User.get(x.uid).display_name + class_str_end
        }
        I18n.t("rumi.memo.transmission") + '=>' + user_html.join(',　')
      else
        ''
      end
    else

      if self.uid == _uid
        I18n.t("rumi.memo.transmission") + "=>#{Gw.trim(_target.collect{|x| "　"+System::User.get(x.uid).display_name}.join(','))}"
      else
        ("#{System::User.get(nz(self.uid,0)).display_name}=></span>" rescue '') + I18n.t("rumi.memo.reception")
      end
    end
  end

  def _is_finished
    nz(is_finished,0) == 0 ? I18n.t("rumi.state.unread") : I18n.t("rumi.state.already")
  end

  def memo_text
    cap = Gw.yaml_to_array_for_select('gw_memos_categories').rassoc(self.memo_category_id)
    cap_s = cap[0] rescue self.memo_category_id.to_s
    md = cap_s.match /^t:(.+?):(.+)$/
    if !md.nil?
      cap_s = "#{md[2]}"
      cap_s += "(#{self.send(md[1])})" if !self.send(md[1]).nil?
    end
    detail = Gw.join([cap_s, self.body], "\n")
    return detail
  end

  def self.options_for_select(container, selected = nil, options = {})
    title_base = options[:title].nil? ? '' : !options[:title].is_a?(Symbol) ? %Q( title="#{options[:title]}") :
      case options[:title]
      when :n0, :n1
        title_flg = options[:title]
      end

    container = container.to_a if Hash === container
    idx = -1
    firefox = options[:firefox]
    if !options[:include_blank].nil?
      blanker = options[:include_blank].is_a?(Array) ? options[:include_blank] : ['', '---']
      blanker[1], blanker[0] = blanker[0], blanker[1]
      container.unshift blanker
    end
    options_for_select = container.inject([]) do |options, element|
      idx += 1
      text, value = Gw.option_text_and_value(element)

      mobile_class = 'mobileOff'
      keitai_str = '&nbsp;&nbsp;&nbsp;&nbsp;'

      selected_attribute = ' selected="selected"' if Gw.option_value_selected?(value, selected)
      title = case title_flg
      when :n0
        %Q( title="#{idx}")
      when :n1
        %Q( title="#{idx + 1}")
      else
        title_base
      end
      if firefox
        options << %(<option class="#{mobile_class}" value="#{Gw.html_escape(value.to_s)}"#{selected_attribute}#{title}>#{Gw.html_escape(text.to_s)}</option>)
      else
        options << %(<option value="#{Gw.html_escape(value.to_s)}"#{selected_attribute}#{title}><span class="#{mobile_class}">#{keitai_str if !firefox}#{Gw.html_escape(text.to_s)}</span></option>)
      end
    end
    options_for_select.join("\n").html_safe
  end

  def mobile_params(params)
    param = params
    ed_at_str = %Q(#{param['ed_at(1i)']}-#{param['ed_at(2i)']}-#{param['ed_at(3i)']} #{param['ed_at(4i)']}:#{param['ed_at(5i)']})
    params.delete "ed_at(1i)"
    params.delete "ed_at(2i)"
    params.delete "ed_at(3i)"
    params.delete "ed_at(4i)"
    params.delete "ed_at(5i)"
    params[:ed_at]= ed_at_str
    users_json = []
    if params[:schedule_users].blank?
      #
    else
      i = 0
      params[:schedule_users].each do |u|
        if u[1].to_i != 0
          user_name = System::User.find_by(id: u[1])
          users_json << ["1",u[1],"#{user_name.name}"]
        end
        i+=1
      end
      params[:schedule_users_json] = users_json.to_json
    end
    return params
  end

  def set_participants(member_str)
    users = member_str.split(',')
    users_json = []
    unless users.blank?
      users.each do |u|
        user_name = System::User.find_by(id: u)
        memo_user  = Gw::MemoUser.find_by_uid(u)
        if memo_user.blank?
          class_id = 1
        else
          class_id = memo_user.class_id
        end
        users_json << [class_id,u,"#{user_name.name}"]
      end
    end
    return users_json
  end
end
