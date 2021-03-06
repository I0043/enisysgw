# -*- encoding: utf-8 -*-
class Gwboard::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  include Gwboard::Controller::SortKey
  include Gwboard::Model::DbnameAlias

  #layout "admin/base"

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  #
  def initialize_scaffold
    self.class.layout 'admin/gwboard_base'
    @partial_use_form = Enisys::Config.application["gw.is_attach"]

    return http_error(404) if params[:system].blank?
    return http_error(404) if params[:action].to_sym == :index && (params[:partial_use_form].blank? || params[:partial_use_form] != @partial_use_form)

    item = gwboard_control
    @title = item.find_by(id: params[:title_id])
    return http_error(404) unless @title
    @disk_full = false
    @capacity_message = ''
    @max_file_message = ''
  end

  def set_graphic_warning_message
    capacity = @title.upload_graphic_file_size_capacity.to_s + @title.upload_graphic_file_size_capacity_unit
    if @title.upload_graphic_file_size_capacity_unit == 'MB'
      used = @title.upload_graphic_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @title.upload_graphic_file_size_capacity.megabyte.to_f
    else
      used = @title.upload_graphic_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @title.upload_graphic_file_size_capacity.gigabytes.to_f
    end
    availability = 0
    availability = (@title.upload_graphic_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @title.upload_graphic_file_size_capacity_unit
    disk_full = (capa_div < @title.upload_graphic_file_size_currently)
    if disk_full
      @capacity_message += '<div class="required">' + I18n.t('rumi.gwboard.message.image_capacity_message1', capacity: capacity, used: used, availability: availability) + "<br />"
      @capacity_message += I18n.t('rumi.gwboard.message.capacity_message2') + '</div>'
    else
      @capacity_message += I18n.t('rumi.gwboard.message.image_capacity_message2', capacity: capacity, used: used) + "<br />"
    end
    @disk_full ||= disk_full
    @max_file_message += "<br />" + I18n.t('rumi.gwboard.message.image_max_file_message', file_size_max: @title.upload_graphic_file_size_max)
  end

  def set_attaches_warning_message
    capacity = @title.upload_document_file_size_capacity.to_s + @title.upload_document_file_size_capacity_unit
    if @title.upload_document_file_size_capacity_unit == 'MB'
      used = @title.upload_document_file_size_currently.to_f / 1.megabyte.to_f
      capa_div = @title.upload_document_file_size_capacity.megabyte.to_f
    else
      used = @title.upload_document_file_size_currently.to_f / 1.gigabyte.to_f
      capa_div = @title.upload_document_file_size_capacity.gigabytes.to_f
    end
    availability = 0
    availability = (@title.upload_document_file_size_currently / capa_div) * 100 unless capa_div == 0
    tmp = availability * 100
    tmp = tmp.to_i
    availability = sprintf('%g',tmp.to_f / 100)
    tmp = used * 100
    tmp = tmp.to_i
    used = sprintf('%g',tmp.to_f / 100)
    used = used.to_s + @title.upload_document_file_size_capacity_unit
    disk_full = (capa_div < @title.upload_document_file_size_currently)
    if disk_full
      @capacity_message += '<div class="required">' + I18n.t('rumi.gwboard.message.tmp_capacity_message1', capacity: capacity, used: used, availability: availability) + "<br />"
      @capacity_message += I18n.t('rumi.gwboard.message.capacity_message2') + '/div>'
    else
      @capacity_message += I18n.t('rumi.gwboard.message.tmp_capacity_message2', capacity: capacity, used: used)
    end
    @disk_full ||= disk_full
    @max_file_message += I18n.t('rumi.gwboard.message.tmp_max_file_message', file_size_max: @title.upload_document_file_size_max)
  end

  #
  def index
    item = gwboard_file
    @items = item.where(title_id: params[:title_id], parent_id: params[:parent_id])
                 .order('id')
    set_graphic_warning_message
    set_attaches_warning_message
    gwboard_file_close
  end

  def create
    if request.xhr?
      dnd_create
    else
      normal_create
    end
  end

  def normal_create
    @uploaded = params[:item]
    if @uploaded.blank?
      flash[:notice] = I18n.t('rumi.attachment.message.no_file')
    else
      unless @uploaded[:upload].blank?
        if @uploaded[:upload].content_type.index("image").blank?
          @max_size = is_integer(@title.upload_document_file_size_max)
        else
          @max_size = is_integer(@title.upload_graphic_file_size_max)
        end
        @max_size = 5 if @max_size.blank?
        if @max_size.megabytes < @uploaded[:upload].size
          if @uploaded[:upload].size != 0
            mb = @uploaded[:upload].size.to_f / 1.megabyte.to_f
            mb = (mb * 100).to_i
            mb = sprintf('%g', mb.to_f / 100)
          end
          flash[:notice] = I18n.t('rumi.attachment.message.exceed_max_size',max_size: @max_size, file_size: mb)
        elsif @uploaded[:upload].original_filename.bytesize >
            Enisys.config.application['sys.max_file_name_length']
          flash[:notice] = I18n.t('rumi.attachment.message.name_too_long')
        else
          begin
            create_file
          rescue => ex
            if ex.message=~/File name too long/
              flash[:notice] = I18n.t('rumi.attachment.message.name_too_long')
            else
              flash[:notice] = ex.message
            end
          end
        end
      end
    end

    redirect_to gwboard_attachments_path(params[:parent_id]) +
        "?system=#{params[:system]}&title_id=#{params[:title_id]}&partial_use_form=#{@partial_use_form}"
  end

  def dnd_create
    file_ids = []
    params[:files].each_value {|file|
      params[:item] = { upload: file }
      @uploaded = params[:item]
      if @uploaded[:upload].content_type.index("image").blank?
        @max_size = is_integer(@title.upload_document_file_size_max)
      else
        @max_size = is_integer(@title.upload_graphic_file_size_max)
      end
      @max_size = 5 if @max_size.blank?
      if @max_size.megabytes < @uploaded[:upload].size
        if @uploaded[:upload].size != 0
          mb = @uploaded[:upload].size.to_f / 1.megabyte.to_f
          mb = (mb * 100).to_i
          mb = sprintf('%g', mb.to_f / 100)
        end
        raise I18n.t('rumi.attachment.message.exceed_max_size',
                     max_size: @max_size, file_size: mb)
      elsif file.original_filename.bytesize >
          Enisys.config.application['sys.max_file_name_length']
        raise I18n.t('rumi.attachment.message.name_too_long')
      else
        begin
          create_file
          file_ids << @item.id if @item.id
        rescue => ex
          if ex.message=~/File name too long/
            raise I18n.t('rumi.attachment.message.name_too_long')
          else
            raise ex.message
          end
        end
      end
    }

    render(json: {
             status: 'OK',
             url: gwboard_attachments_path(params[:parent_id]) +
                  "?system=#{params[:system]}&title_id=#{params[:title_id]}&partial_use_form=#{@partial_use_form}"})
  rescue => e
    if file_ids.present?
      gwboard_file.where(id: file_ids).destroy_all
    end
    render json: { status: 'NG', message: e.message }
  end

  def create_file
    @uploaded = params[:item]
    unless @uploaded[:upload].blank?
      item = gwboard_file
      @item = item.new({
        :content_type => @uploaded[:upload].content_type,
        :filename => @uploaded[:upload].original_filename,
        :size => @uploaded[:upload].size,
        :memo => @uploaded[:memo],
        :title_id => params[:title_id],
        :parent_id => params[:parent_id],
        :content_id => @title.upload_system,
        :db_file_id => 0
      })
      @item._upload_file(@uploaded[:upload])
      @item.save
      update_total_file_size
      gwboard_file_close
    end
  end

  def destroy
    item = gwboard_file
    @item = item.find_by(id: params[:id])
    @item.destroy
    update_total_file_size
    gwboard_file_close
    redirect_to gwboard_attachments_path(params[:parent_id]) +
        "?system=#{params[:system]}&title_id=#{params[:title_id]}&partial_use_form=#{@partial_use_form}"
  end

  # === 添付ファイル一括削除用メソッド
  #  本メソッドは、添付ファイルを一括削除するメソッドである。
  #  params[：attachment_ids]に含まれるIDの添付ファイルを全て削除する。
  #    params[：attachment_ids]にはカンマ区切りで添付ファイルIDを記述する。
  #    例） 添付ファイルIDが「1」と「3」と「5」の場合 ⇒ params[：attachment_ids] = '1,3,5'
  # ==== 引数
  #  なし
  # ==== 戻り値
  #  なし
  def destroy_by_ids
    gwboard_cnn = gwboard_file
    if params[:attachment_ids].present?
      ids = params[:attachment_ids].split(',')
      ids.each {|id_s|
        attachment_item = gwboard_cnn.find_by(id: id_s.to_i)

        unless attachment_item
          flash[:notice] = I18n.t('rumi.gwboard.message.attached_file_not_found')
          gwboard_file_close
          redirect_to gwboard_attachments_path(params[:parent_id]) +
              "?system=#{@title.system_name}&title_id=#{params[:title_id]}&partial_use_form=#{@partial_use_form}"
          return
        end
        attachment_item.destroy
      }
    end
    update_total_file_size
    gwboard_file_close
    redirect_to gwboard_attachments_path(params[:parent_id]) +
        "?system=#{@title.system_name}&title_id=#{params[:title_id]}&partial_use_form=#{@partial_use_form}"
  end

  def update_total_file_size
    item = gwboard_file
    total = item.where('unid = 1').sum(:size)
    total = 0 if total.blank?
    @title.upload_graphic_file_size_currently = total.to_f

    total = item.where('unid = 2').sum(:size)
    total = 0 if total.blank?
    @title.upload_document_file_size_currently = total.to_f

    @title.save
  end

  def update_file_memo
    file = gwboard_file
    @file = file.find_by(id: params[:id])
    @file.memo  = params[:file]['memo']
    @file.save

    ret = ''
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&cat1=#{params[:cat1]}" unless params[:cat1].blank?
    ret += "&grp=#{params[:grp]}" unless params[:grp].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{params[:kwd]}" unless params[:kwd].blank?

    if params[:system].to_s == 'doclibrary'
      if @title.form_name == 'form002'
        parent  = Doclibrary::Doc.where("id=#{params[:parent_id]}").first
        parent_show_path  = "/doclibrary/docs/#{parent.id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      else
        parent_show_path  = "/doclibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      end
      redirect_to parent_show_path
      return
    end
    if params[:system].to_s == 'digitallibrary'
      parent_show_path  = "/digitallibrary/docs/#{@file.parent_id}?system=#{params[:system]}&title_id=#{params[:title_id]}"+ret
      redirect_to parent_show_path
      return
    end
    if params[:system].to_s == 'gwbbs'
      parent_show_path  = "/gwbbs/docs/#{@file.parent_id}?title_id=#{params[:title_id]}"+ret
      redirect_to parent_show_path
      return
    end
    gwboard_file_close
    redirect_to gwboard_attachments_path(params[:parent_id]) + "?system=#{params[:system]}&title_id=#{params[:title_id]}"
  end

  private
  def invalidtoken

  end
end
