# -*- encoding: utf-8 -*-
class Gwbbs::Admin::ItemdeletesController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Gwbbs::Model::DbnameAlias
  include Gwbbs::Controller::AdmsInclude
  include Gwboard::Controller::Authorize

  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.item_delete.gwbbs.name")
    @piece_head_title = t("rumi.item_delete.gwbbs.name")
    @side = "setting"

    return authentication_error(403) unless @gw_admin
  end

  def index

  end

  def new
    item = Gwbbs::Itemdelete.where(content_id: 0).first
    limit = ''
    limit = item.limit_date unless item.blank?

    @item = Gwbbs::Itemdelete.new({
      :content_id => 0 ,
      :admin_code => Core.user.code ,
      :limit_date => limit
    })
  end

  def create
    Gwbbs::Itemdelete.where("content_id = 0").delete_all
    @item = Gwbbs::Itemdelete.new(item_params)
    @item.content_id = 0
    @item.admin_code = Core.user.code
    _create @item, notice: t("rumi.message.notice.delete_setting")
  end

  def target_record
    create_target_record
    redirect_to "#{admin_item_deletes_path}/direct/edit"
  end

  def edit
    @items = Gwbbs::Itemdelete.where(content_id: 2, admin_code: Core.user.code)
                              .order('board_sort_no, title_id')
                              .paginate(page: params[:page], per_page: 10)
  end

  def destroy
    @title = Gwbbs::Control.find_by(id: params[:id])
    unless @title.blank?
      @img_path = "public/_common/modules/#{@title.system_name}/"
      item = Gwbbs::Doc

      @items = item.where(title_id: @title.id, state: 'preparation')
                   .where("created_at < ?", Date.yesterday.strftime("%Y-%m-%d") + ' 00:00:00')
      for @item in @items
        destroy_comments
        destroy_atacched_files
        #destroy_files
        @item.destroy
      end

      @items = item.where(title_id: @title.id)
                   .where("state != ?", 'preparation')
                   .where("expiry_date < ?", Date.today.strftime("%Y-%m-%d") + ' 00:00:00')
      for @item in @items
        destroy_comments
        destroy_atacched_files
        #destroy_files
        @item.destroy
      end
      create_target_record
    end
    str_page = "?page=#{params[:page]}" unless params[:page].blank?
    redirect_to "#{admin_item_deletes_path}/direct/edit#{str_page}", notice: t("rumi.message.notice.delete")
  end

protected

  def sql_where
    sql = Condition.new
    sql.and :parent_id, @item.id
    sql.and :title_id, @item.title_id
    return sql.where
  end

  def destroy_comments
    Gwbbs::Comment.where(sql_where).destroy_all
  end

  def destroy_atacched_files
    Gwbbs::File.where(sql_where).destroy_all
  end

  def create_target_record
    Gwbbs::Itemdelete.where("content_id = 2 AND admin_code = '#{Core.user.code}'").delete_all

    items = Gwbbs::Control.order('sort_no, id')
    for @title in items
      begin
        count_item = Gwbbs::Doc
        sql = "SELECT COUNT(`id`) AS cnt FROM `gwbbs_docs`"
        sql += " WHERE `state` = 'public'"
        sql += " AND title_id = '#{@title.id}'"
        sql += " AND '" + Time.now.strftime("%Y-%m-%d %H:%M:%S") + "' BETWEEN `able_date` AND `expiry_date` GROUP BY `title_id`;"
        public_count = count_item.count_by_sql(sql)

        sql = "SELECT COUNT(`id`) AS cnt FROM `gwbbs_docs`"
        sql += " WHERE `state` != 'preparation' AND `expiry_date` < '" + Date.today.strftime("%Y-%m-%d") + " 00:00:00'"
        sql += " AND title_id = '#{@title.id}'"
        delete_count = count_item.count_by_sql(sql)

        Gwbbs::Itemdelete.create({
          :content_id => 2 ,
          :admin_code => Core.user.code ,
          :title_id => @title.id ,
          :board_title => @title.title ,
          :board_state => @title.state == 'public' ? I18n.t("rumi.gwbbs.select_item.public") : I18n.t("rumi.gwbbs.select_item.private") ,
          :board_view_hide => @title.view_hide ? I18n.t("rumi.gwbbs.select_item.view_show") : I18n.t("rumi.gwbbs.select_item.view_hide"),
          :board_sort_no => @title.sort_no ,
          :public_doc_count => public_count ,
          :void_doc_count => delete_count ,
          :dbname => @title.dbname ,
          :board_limit_date => @title.limit_date ,
          :limit_date => 'direct'
        })
      rescue
      end
    end
  end

private

  def item_params
    params.require(:item)
          .permit(:limit_date)
  end

end
