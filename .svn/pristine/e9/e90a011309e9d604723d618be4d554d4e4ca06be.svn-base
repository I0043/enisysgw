# -*- encoding: utf-8 -*-
class Gwcircular::Admin::AttachmentsController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken

  def initialize_scaffold
    @partial_use_form = Enisys::Config.application["gw.is_attach"]
    return http_error(404) if params[:action].to_sym == :index && (params[:partial_use_form].blank? || params[:partial_use_form] != @partial_use_form)
    @parent_id = params[:gwcircular_id]
    self.class.layout 'admin/gwboard_base'
    params[:title_id] = 1
    @title = Gwcircular::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title
    @doc_type = 0
    item = Gwcircular::Doc.find_by(id: @parent_id)
    @doc_type = item.doc_type unless item.blank?
  end

  def index
    @items = Gwcircular::File.where(title_id: 1, parent_id: @parent_id).order('id')
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

    redirect_to gwcircular_attachments_path(@parent_id) + "?partial_use_form=#{@partial_use_form}"
  end

  def dnd_create
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
             url: gwcircular_attachments_path(@parent_id) + "?partial_use_form=#{@partial_use_form}"})
  rescue => e
    render json: { status: 'NG', message: e.message }
  end

  def create_file
    @uploaded = params[:item]
    unless @uploaded[:upload].blank?
      @item = Gwcircular::File.new({
        :content_type => @uploaded[:upload].content_type,
        :filename => @uploaded[:upload].original_filename,
        :size => @uploaded[:upload].size,
        :memo => @uploaded[:memo],
        :title_id => params[:title_id],
        :parent_id => @parent_id,
        :content_id => @title.upload_system,
        :db_file_id => 0
      })
      @item._upload_file(@uploaded[:upload])
      @item.save
    end
  end

  def destroy
    @item = Gwcircular::File.find_by(id: params[:id])
    @item.destroy
    redirect_to gwcircular_attachments_path(@parent_id) + "?partial_use_form=#{@partial_use_form}"
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
    if params[:attachment_ids].present?
      ids = params[:attachment_ids].split(',')
      ids.each {|id_s|
        attachment_item = Gwcircular::File.find_by(id: id_s.to_i)
        unless attachment_item
          flash[:notice] = I18n.t('rumi.gwcircular.message.attached_file_not_found')
          redirect_to gwcircular_attachments_path(params[:parent_id]) + "?partial_use_form=#{@partial_use_form}"
          return
        end
        attachment_item.destroy
      }
    end
    redirect_to gwcircular_attachments_path(params[:parent_id]) + "?partial_use_form=#{@partial_use_form}"
  end

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

  private
  def invalidtoken

  end
end
