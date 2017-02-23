# -*- encoding: utf-8 -*-
class Doclibrary::Admin::GroupFoldersController < Gw::Controller::Admin::Base

  include Gwboard::Controller::Scaffold
  include Doclibrary::Model::DbnameAlias

  layout "admin/template/portal"

  def initialize_scaffold
    @title = Doclibrary::Control.find_by(id: params[:title_id])
    return http_error(404) unless @title

    Page.title = @title.title
    @piece_head_title = I18n.t("rumi.doclibrary.name")
    @side = "doclibrary"

    params[:grp] = 1 if params[:grp].blank?

    if params[:grp].blank? or params[:grp].blank? == '0'
      @parent = Doclibrary::GroupFolder.where(title_id: params[:title_id], id: 0, level_no: 0)
    else
      @parent = Doclibrary::GroupFolder.find_by(id: params[:grp])
      @parent = Doclibrary::GroupFolder.where(title_id: params[:title_id], id: 0, level_no: 0) unless @parent
    end
    @cabinet_title = I18n.t("rumi.doclibrary.name")
  end

  def index
    item = Doclibrary::GroupFolder.where(level_no: 1) if @parent.blank?
    item = Doclibrary::GroupFolder.where(parent_id: @parent.id) unless @parent.blank?
    @items = item.where(title_id: params[:title_id])
                 .order("level_no, sort_no, id")
                 .paginate_doclibrary(params)
    _index @items
  end

  def edit
    @item = Doclibrary::GroupFolder.find_by(id: params[:id]).order('sort_no, id')
    return error_auth unless @item
    @parent_state = @item.parent.state if @item.parent
    @parent_state = 'public' if @parent_state.blank?
    _show @item
  end

  def new
    title_id = params[:title_id]
    @item = Doclibrary::GroupFolder.new({
      :state     => 'closed',
      :use_state => 'public',
      :parent_id => @parent.id,
      :title_id  => title_id,
      :sort_no   => 0
    })

    @parent_state = @item.parent.use_state  if @item.parent
    @parent_state = 'public' if @parent_state.blank?
  end

  def create
    @item = Doclibrary::GroupFolder.new(params[:item])
    @item.title_id = @title.id
    @item.parent_id = @parent.id
    @item.level_no  = @parent.level_no + 1

    @item.state = @parent.state if @parent
    @item.state = 'public' if @item.state.blank?
    _create @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def update
    @item = Doclibrary::GroupFolder.find_by(id: params[:id])
    @item.attributes = params[:item]

    @level_items = Doclibrary::GroupFolder.where(title_id: params[:title_id], parent_id: @item.id)
    lower_level_rewrite('update', @level_items, @item.state)
    _update @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def destroy
    @item = Doclibrary::GroupFolder.find_by(id: params[:id])
    _destroy @item, :success_redirect_uri => url_for(:action => :index, :title_id => @title.id)
  end

  def sync_groups
    sync_group_folders
    sync_children
    unless params[:make].blank?
      redirect_to doclibrary_cabinets_path
    else
      redirect_to doclibrary_group_folders_path({:title_id=>@title.id})
    end
  end

  def sync_group_folders
    folder_item = Doclibrary::GroupFolder
    folder_item.where("title_id = #{@title.id}").update_all("state = 'closed', use_state = 'closed'")

    params[:mode] = 'closed' if params[:mode].blank?
    groups = Gwboard::Group.where(state: 'enabled')
                           .order("level_no, sort_no, id")
    for group in groups
      folder = folder_item.where(title_id: @title.id, code: group.code).first
      s_state = params[:mode]
      s_state = 'closed' if group.ldap == 0

      unless folder.blank?
        folder_item.update(folder.id,
          :state => s_state,
          :use_state => s_state,
          :updated_at => Time.now,
          :parent_id => get_sync_parent_id(folder_item, group.parent_id),
          :sort_no => group.sort_no,
          :level_no => group.level_no,
          :name => group.name,
          :sysgroup_id => group.id,
          :sysparent_id => group.parent_id
        )
      else
        add_folder = folder_item.new(
          :state => s_state,
          :use_state => s_state,
          :title_id => @title.id,
          :parent_id => get_sync_parent_id(folder_item, group.parent_id),
          :sort_no => group.sort_no,
          :level_no => group.level_no,
          :children_size => 0,
          :total_children_size =>0,
          :code => group.code,
          :name => group.name,
          :sysgroup_id => group.id,
          :sysparent_id => group.parent_id
        )
        add_folder.save!
      end
    end

    folder_item.where("title_id = #{@title.id} and level_no = 1").update_all("state = 'public'")

    section_folder_state_update

    item = Doclibrary::Doc.update_group_folder_children_size
  end

  def sync_children
    Doclibrary::Doc.update_group_folder_children_size
  end

  def get_sync_parent_id(folder_item, parent_id)
    ret = nil
    folder = folder_item.where(title_id: params[:title_id], sysgroup_id: parent_id).first
    ret = folder.id if folder
    return ret
  end

  def lower_level_rewrite(mode, items, state)
    if items.size > 0
      items.each do |item|
        level_item = Doclibrary::GroupFolder
        level_item.update(item.id, :state =>'closed') unless mode == 'sync' if state =='closed'#
        if item.children.size > 0
            lower_level_rewrite(mode, item.children, state)
        end
      end
    end
  end

  def section_folder_state_update
    group_item = Doclibrary::GroupFolder
    item = Doclibrary::Doc
    item.where(state: 'public', title_id: params[:title_id])
        .select('section_code').group('section_code').each do |code|
          group_item.where(title_id: params[:title_id], code: code.section_code).each do |group|
            group_state_rewrite(group,group_item)
          end
        end
  end

  def group_state_rewrite(item, group_item)
    group_item.update(item.id, :state =>'public')
    unless item.parent.blank?
      group_state_rewrite(item.parent, group_item)
    end
  end
end
