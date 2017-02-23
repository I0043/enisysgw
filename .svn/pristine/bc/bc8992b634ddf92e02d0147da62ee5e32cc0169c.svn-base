# -*- encoding: utf-8 -*-
class Gwbbs::Admin::CommentsController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwboard::Controller::Authorize
  include Gwbbs::Admin::DocsHelper
  include Gwbbs::Controller::AdmsInclude

  rescue_from ActionController::InvalidAuthenticityToken, :with => :invalidtoken
  layout "admin/template/portal"

  def initialize_scaffold
    @title = Gwbbs::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title
    Page.title = @title.title
    initialize_value_set_new_css

    params[:piece_param] = "TitleDisplayMode"
    get_piece_menus
  end

  def docs_show
    @item = @title.docs.where(id: params[:p_id]).where(gwbbs_select_status(params)).first
    return http_error(404) unless @item

    @files = @item.files.order('id')
  end

  def edit
    get_role_index
    return http_error(403) unless @is_readable

    @comment = Gwbbs::Comment.where(title_id: params[:title_id], id: params[:id]).first
    return http_error(404) unless @comment
    params[:p_id] = @comment.parent_id
    docs_show
  end

  def new
    get_role_index
    return http_error(403) unless @is_readable

    docs_show
    @comment = Gwbbs::Comment.new({
      :state => 'public' ,
      :published_at => Core.now ,
    })
 end

  def create
    @comment = Gwbbs::Comment.new(item_params)
    @comment.title_id = params[:title_id]
    @comment.parent_id = params[:p_id]
    @comment.latest_updated_at = Core.now

    @comment.createdate = Core.now
    @comment.creater_id = Core.user.code unless Core.user.code.blank?
    @comment.creater = Core.user.name unless Core.user.name.blank?
    @comment.createrdivision = Core.user_group.name unless Core.user_group.name.blank?
    @comment.editdate = Core.now
    @comment.editor_id = Core.user.code unless Core.user.code.blank?
    @comment.editor = Core.user.name unless Core.user.name.blank?
    @comment.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @comment.save

    # 記事管理課に所属するユーザーに通知
    item = Gwbbs::Doc.where(id: params[:p_id]).first
    item.build_reply_remind(@comment.id)

    flash[:notice] = I18n.t("rumi.gwbbs.message.regist_comment")
    redirect_to "/gwbbs/docs/#{params[:p_id]}?title_id=#{params[:title_id]}#{gwbbs_params_set}"
  end

  def update
    @comment = Gwbbs::Comment.find(params[:id])
    @comment.attributes = item_params
    @comment.title_id = params[:title_id]
    @comment.parent_id = params[:p_id]
    @comment.latest_updated_at = Core.now
    @comment.editdate = Core.now
    @comment.editor_id = Core.user.code unless Core.user.code.blank?
    @comment.editor = Core.user.name unless Core.user.name.blank?
    @comment.editordivision = Core.user_group.name unless Core.user_group.name.blank?
    @comment.body = '・' if @comment.body.blank?
    @comment.save

    # 記事管理課に所属するユーザーに通知
    item = Gwbbs::Doc.where(id: params[:p_id]).first
    item.build_reply_remind(@comment.id)

    flash.notice = I18n.t("rumi.gwbbs.message.edit_comment")
    redirect_to "/gwbbs/docs/#{params[:p_id]}?title_id=#{params[:title_id]}#{gwbbs_params_set}"
  end

  def destroy
    @item = Gwbbs::Comment.find(params[:id])

    # 該当コメントの新着情報を削除
    item = Gwbbs::Comment.where(id: params[:id]).first
    destroy_remind = Gw::Reminder.where(title_id: params[:title_id], item_id: item.parent_id)
                                  .where(sub_category: params[:id].to_s)
    destroy_remind.destroy_all

    _destroy_plus_location(@item, "/gwbbs/docs/#{@item.parent_id}?title_id=#{@item.title_id}#{gwbbs_params_set}", :notice => "コメントを削除しました。")
  end

private
  def item_params
    params.require(:comment)
          .permit(:body, :state)
  end
end
