#encoding:utf-8
module Gwcircular::DocsHelper

  def gwcircular_attachments_form(form, item, mode=nil)
    form_id = '' if form_id.blank?
    return render(partial: 'gwcircular/admin/tool/attachments/form', locals: {f: form, item: item, mode: mode, partial_use_form: Enisys::Config.application["gw.is_attach"]})
  end

  def readers_table(title, objects, col, s_class)
    ret = ''
    ret += %Q[<table class="#{s_class}">]
    ret += %Q[<tr><th colspan="#{col}">#{title}</th></tr>]
    i=0
    s_table = ''
    for object in objects
      if col <= i
        i = 0
        s_table += '</tr>'
      end
      s_table += '<tr>' if i == 0
      s_table += %Q[<td style="width: auto;">・#{object[2]}&nbsp;</td>]
      i += 1
    end
    unless i == 0
      j = col - i
      for i in 1..j
        s_table += %Q[<td style="width: auto;"></td>]
      end
      s_table += '</tr>'
    end
    ret += s_table
    ret += '</table>'
    return ret
  end

  def open_mail_form(uri)
    uri = escape_javascript(uri)
    "openMailForm('#{uri}', '#{mail_form_style}');"
  end

  def mail_form_style
    "resizable=yes,scrollbars=yes"
  end

  def open_gwbbs_form(uri)
    uri = escape_javascript(uri)
    "openGwbbsForm('#{uri}', '#{gwbbs_form_style}');"
  end

  def gwbbs_form_style
    "resizable=yes,scrollbars=yes"
  end

  def get_piece_menus
    params[:category] = 'EXPIRY' if params[:category].blank? && (params[:cond] != 'owner' && params[:cond] != 'admin')
    get_role_index
    return authentication_error(403) unless @is_readable
    case params[:cond]
    when 'unread'
      piece_unread_index
    when 'already'
      piece_already_read_index
    when 'owner'
      piece_owner_index
    when 'void'
      piece_owner_index
    when 'admin'
      return authentication_error(403) unless @gw_admin
      piece_admin_index
    else
      piece_unread_index
    end
    
    @piece_group_names = Array.new
    for grp_item in @piece_groups
      str_count = ''
      str_count = "(#{grp_item.cnt.to_s})" unless grp_item.cnt.blank?
      group_name = "#{System::Group.where(code: grp_item.createrdivision_id).first.name}"
      @piece_group_names << [group_name, grp_item.createrdivision_id ]
    end
  end

  def piece_unread_index
    @piece_groups = Gwcircular::Doc.unread_info(@title.id).select_createrdivision_info
    @piece_monthlies = Gwcircular::Doc.unread_info(@title.id).select_monthly_info
  end

  def piece_already_read_index
    @piece_groups = Gwcircular::Doc.already_info(@title.id).select_createrdivision_info
    @piece_monthlies = Gwcircular::Doc.already_info(@title.id).select_monthly_info
  end

  def piece_owner_index
    @piece_groups = Gwcircular::Doc.owner_info(@title.id).select_createrdivision_info
    @piece_monthlies = Gwcircular::Doc.owner_info(@title.id).select_monthly_info
  end

  def piece_admin_index
    @piece_groups = Gwcircular::Doc.admin_info(@title.id).select_createrdivision_info
    @piece_monthlies = Gwcircular::Doc.admin_info(@title.id).select_monthly_info
  end
end
