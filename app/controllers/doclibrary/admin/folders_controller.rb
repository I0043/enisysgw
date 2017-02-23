class Doclibrary::Admin::FoldersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Gwboard::Controller::Common
  include Doclibrary::Model::DbnameAlias
  include Rumi::Doclibrary::Authorize
  include Doclibrary::Admin::DocsHelper
  include Doclibrary::Admin::Piece::MenusHelper

  layout "admin/template/portal"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title

    Page.title = @title.title
    @piece_head_title = I18n.t("rumi.doclibrary.name")
    @side = "doclibrary"

    params[:cat] = 1 if params[:cat].blank?
    @parent = Doclibrary::Folder.where(title_id: params[:title_id], id: params[:cat]).first
    unless @parent
      @parent = Doclibrary::Folder.where(title_id: params[:title_id]).order("id").first
    end
    return http_error(404) unless @parent
    initialize_value_set
    params[:piece_param] = "TitleDisplayMode"
    get_piece_banners
  end

  def show
    get_role_index
    return http_error(403) unless @is_readable

    @item = Doclibrary::Folder.where(title_id: params[:title_id], id: params[:id]).first
    return http_error(404) unless @item

    @admins = JsonParser.new.parse(@item.admins_json) unless @item.admins_json.blank?
    @admin_groups = JsonParser.new.parse(@item.admin_groups_json) unless @item.admin_groups_json.blank?

    @readers = JsonParser.new.parse(@item.readers_json) unless @item.readers_json.blank?
    @reader_groups = JsonParser.new.parse(@item.reader_groups_json) unless @item.reader_groups_json.blank?

    _show @item
  end

  def index
    get_role_index
    return http_error(403) unless @is_readable

    if @parent.id.blank?
      item = Doclibrary::Folder.where(level_no: 1)
    else
      item = Doclibrary::Folder.where(parent_id: @parent.id)
    end

    @items = item.where(title_id: params[:title_id])
               .order("level_no, sort_no, id")
               .paginate_doclibrary(params)
    _index @items
  end

  def edit
    get_role_new

    @item = Doclibrary::Folder.find_by(id: params[:id])

    # カレントフォルダに閲覧権限があるか？
    return http_error(403) unless @parent.readable_user?

    # フォルダ編集できるか？（フォルダの親フォルダに管理権限があるか？）
    return http_error(403) unless @item.parent.admin_user?

    return error_auth unless @item
    @parent_state = 'public'
    @parent_state = @item.parent.state  if @item.parent

    parent_admins_json = @item.parent.admins_json if @item.parent
    @parent_admins = JsonParser.new.parse(parent_admins_json) unless parent_admins_json.blank?
    parent_admin_groups_json = @item.parent.admin_groups_json if @item.parent
    @parent_admin_groups = JsonParser.new.parse(parent_admin_groups_json) unless parent_admin_groups_json.blank?

    @parent_config = @parent_admins || @parent_admin_groups
    @parent_admins = '' if @parent_admins.blank?
    @parent_admin_groups = '' if @parent_admin_groups.blank?
    @parent_config = '' if @parent_config.blank?

    parent_readers_json = @item.parent.readers_json if @item.parent
    @parent_readers = JsonParser.new.parse(parent_readers_json) unless parent_readers_json.blank?
    parent_reader_groups_json = @item.parent.reader_groups_json if @item.parent
    @parent_reader_groups = JsonParser.new.parse(parent_reader_groups_json) unless parent_reader_groups_json.blank?

    @parent_config = @parent_readers || @parent_reader_groups
    @parent_readers = '' if @parent_readers.blank?
    @parent_reader_groups = '' if @parent_reader_groups.blank?
    @parent_config = '' if @parent_config.blank?
  end

  def new
    get_role_new

    # カレントフォルダに閲覧権限があるか？
    return http_error(403) unless @parent.readable_user?

    # フォルダ作成できるか？（カレントフォルダに管理権限があるか？）
    return http_error(403) unless @parent.admin_user?

    @item = Doclibrary::Folder.new({
      :state      => @parent.state,
      :parent_id  => @parent.id,
      :title_id  => @title.id,
      :sort_no    => 0
    })
    unless @item.parent.blank?
      @item.state = @item.parent.state
      @item.admins = @item.parent.admins
      @item.admins_json = @item.parent.admins_json
      @item.admin_groups = @item.parent.admin_groups
      @item.admin_groups_json = @item.parent.admin_groups_json

      @item.readers = @item.parent.readers
      @item.readers_json = @item.parent.readers_json
      @item.reader_groups = @item.parent.reader_groups
      @item.reader_groups_json = @item.parent.reader_groups_json
    end
  end

  def create
    @item = Doclibrary::Folder.new(item_params)
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1
    @item.children_size  = 0
    @item.total_children_size = 0

    @parent_state = @parent.state
    @item.state = @parent.state if @parent.state=='closed'

    parent_admins_json       = @item.parent.admins_json       if @item.parent
    @item.admins_json        = parent_admins_json             if (params[:item]['admins_json'].blank? and !parent_admins_json.blank?)
    parent_admin_groups_json = @item.parent.admin_groups_json if @item.parent
    @item.admin_groups_json  = parent_admin_groups_json       if (params[:item]['admin_groups_json'].blank? and !parent_admin_groups_json.blank?)

    parent_readers_json       = @item.parent.readers_json       if @item.parent
    @item.readers_json        = parent_readers_json             if (params[:item]['readers_json'].blank? and !parent_readers_json.blank?)
    parent_reader_groups_json = @item.parent.reader_groups_json if @item.parent
    @item.reader_groups_json  = parent_reader_groups_json       if (params[:item]['reader_groups_json'].blank? and !parent_reader_groups_json.blank?)

    @parent_config =
        @parent_admins || @parent_admin_groups || @parent_readers || @parent_reader_groups
    @parent_admins = '' if @parent_admins.blank?
    @parent_admin_groups = '' if @parent_admin_groups.blank?

    @parent_readers = '' if @parent_readers.blank?
    @parent_reader_groups = '' if @parent_reader_groups.blank?
    @parent_config = '' if @parent_config.blank?

    str_params = doclibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _create_plus_location @item, str_params
  end

  def update
    @item = Doclibrary::Folder.find_by(id: params[:id])
    @item.attributes = item_params
    parent_admins_json       = @item.parent.admins_json       if @item.parent
    @item.admins_json        = parent_admins_json             if (params[:item]['admins_json'].blank? and !parent_admins_json.blank?)
    parent_admin_groups_json = @item.parent.admin_groups_json if @item.parent
    @item.admin_groups_json  = parent_admin_groups_json       if (params[:item]['admin_groups_json'].blank? and !parent_admin_groups_json.blank?)

    parent_readers_json       = @item.parent.readers_json       if @item.parent
    @item.readers_json        = parent_readers_json             if (params[:item]['readers_json'].blank? and !parent_readers_json.blank?)
    parent_reader_groups_json = @item.parent.reader_groups_json if @item.parent
    @item.reader_groups_json  = parent_reader_groups_json       if (params[:item]['reader_groups_json'].blank? and !parent_reader_groups_json.blank?)
    @parent_state = @parent.state

    @parent_config =
        @parent_admins || @parent_admin_groups || @parent_readers || @parent_reader_groups
    @parent_admins = '' if @parent_admins.blank?
    @parent_admin_groups = '' if @parent_admin_groups.blank?

    @parent_readers = '' if @parent_readers.blank?
    @parent_reader_groups = '' if @parent_reader_groups.blank?
    @parent_config = '' if @parent_config.blank?

    if @item.state == 'closed'
      update_doc_and_child_state @item
#    else
#      update_doc_state @item
    end

    str_params = doclibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _update_plus_location @item, str_params
  end

  def destroy
    @item = Doclibrary::Folder.find_by(id: params[:id])

    str_params = doclibrary_docs_path({:title_id=>@title.id})
    str_params += "&cat=#{@item.parent_id}"
    str_params += "&state=CATEGORY"
    _destroy_plus_location @item, str_params
  end


  def lower_level_rewrite(items, state,
                          admins, admins_json, admin_groups, admin_groups_json,
                          readers, readers_json, reader_groups, reader_groups_json)
    if items.size > 0
      items.each do |item|
        Doclibrary::Folder.update(item.id,:admins => admins, :admins_json => admins_json, :admin_groups => admin_groups, :admin_groups_json => admin_groups_json) if state =='public'
        Doclibrary::Folder.update(item.id, :state =>'closed',:admins => admins, :admins_json => admins_json, :admin_groups => admin_groups, :admin_groups_json => admin_groups_json) if state =='closed'

        Doclibrary::Folder.update(item.id,:readers => readers, :readers_json => readers_json, :reader_groups => reader_groups, :reader_groups_json => reader_groups_json) if state =='public'
        Doclibrary::Folder.update(item.id, :state =>'closed',:readers => readers, :readers_json => readers_json, :reader_groups => reader_groups, :reader_groups_json => reader_groups_json) if state =='closed'
        if item.children.size > 0
            lower_level_rewrite(item.children, state,
                                admins, admins_json, admin_groups, admin_groups_json,
                                readers, readers_json, reader_groups, reader_groups_json)
        end
      end
    end
  end


  def maintenance_acl
    items = Doclibrary::Folder.all
    items.each do |item|
      item.save_acl_records
    end
    redirect_to "/doclibrary/folders?title_id=#{@title.id}"
  end

  def update_doc_and_child_state(item)
    update_doc_state item
    children = Doclibrary::Folder.where("doclibrary_folders.parent_id = #{item.id}") rescue nil
    return unless children

    children.each{|c|
      c.state = item.state
      c.save!
      update_doc_and_child_state c # call recursively
    }
  end

  def update_doc_state(item)
    docs = Doclibrary::Doc.where("doclibrary_docs.category1_id = #{item.id} and state != 'preparation' and state IS NOT NULL") rescue nil

    if docs
      docs.each{|d|
        d.state = item.state == 'closed' ? 'draft' : item.state
        d.save!
      }
    end
  end

private

  def item_params
    params.require(:item)
          .permit(:state, :sort_no, :name, :admin_groups_json, :admins_json, :reader_groups_json, :readers_json)
  end
end
