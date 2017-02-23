class Gwboard::Admin::ReceiptsController < ApplicationController
  include System::Controller::Scaffold
  include Gwboard::Model::DbnameAlias

  def initialize_scaffold
    return http_error(404) if params[:system].blank?

    item = gwboard_control
    @title = item.find_by(id: params[:title_id])
    return http_error(404) unless @title
  end

  def download_object
    mode = 0

    if params[:system] == 'gwbbs'
      mode = 2 if @title.upload_system == 2
    end

    if params[:system] == 'gwfaq'
      mode = 2 if @title.upload_system == 2
    end

    item = gwboard_file
    item = item.find_by(id: params[:id])

    chk = true
    if chk
      get_readable_flag unless @is_readable
      return authentication_error(403) unless @is_readable
    end

    item_filename = Gw.filename_encode(request, item.filename)

    if mode == 2
      f = open(item.f_name)
      if item.is_image
        send_data(f.read, :filename => item_filename, :type => item.content_type, :disposition=>'inline')
      else
        send_data(f.read, :filename => item_filename, :type => item.content_type)
      end
      f.close
    end

    gwboard_file_close
  end

end
