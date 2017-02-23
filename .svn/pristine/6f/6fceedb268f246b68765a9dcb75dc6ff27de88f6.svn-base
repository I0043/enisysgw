# -*- encoding: utf-8 -*-
class Attaches::Admin::DoclibraryController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Doclibrary::Model::DbnameAlias

  def initialize_scaffold
    skip_layout

    params[:system] = 'doclibrary'

    @title = Doclibrary::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title
    admin_flags(@title.id)
  end

  def download
    params[:id] = "#{params[:u_code].to_s}#{params[:d_code].to_s}"
    return http_error(404) if params[:id].blank?

    item = Doclibrary::File.find_by(id: params[:id])
    return http_error(404) unless item
    return http_error(404) unless params[:name] == sprintf('%08d',Util::CheckDigit.check(item.parent_id))

    get_readable_flag unless @is_readable
    return authentication_error(403) unless @is_readable

    item_filename = Gw.filename_encode(request, item.filename)

    begin
    f = open(item.f_name)
    if item.is_image
      send_data(f.read, :filename => item_filename, :type => item.content_type, :disposition=>'inline')
    else
      send_data(f.read, :filename => item_filename, :type => item.content_type)
    end
    f.close
    rescue
      dump "ダウンロードファイルなし:#{item_filename}"
      return http_error(404)
    end
  end

end
