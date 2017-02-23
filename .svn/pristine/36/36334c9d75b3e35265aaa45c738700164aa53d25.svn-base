# encoding: utf-8
class Gw::Admin::AdminMessagesController < Gw::Controller::Admin::Base
  include System::Controller::Scaffold
  protect_from_forgery :except => [:destroy]
  layout "admin/template/portal"

  def initialize_scaffold
    Page.title = t("rumi.config_settings.admin_message.header")
    @piece_head_title = t("rumi.config_settings.admin_message.header")
    @side = "setting"
    return authentication_error(403) unless @gw_admin
  end

  def index
    init_params
    @items = Gw::AdminMessage.order('state ASC , sort_no ASC , updated_at DESC')
  end
  def show
    init_params

    @item = Gw::AdminMessage.find(params[:id])
    return http_error(404) if @item.blank?
  end

  def new
    init_params

    @item = Gw::AdminMessage.new
    @item.state = 2
    item = Gw::AdminMessage.order('sort_no DESC').first
    if item.blank?
      init_sort_no = 10
    else
      init_sort_no = item.sort_no
    end
    @item.sort_no = init_sort_no+10
  end
  def create
    init_params

    @item = Gw::AdminMessage.new(item_params)

    options={:success_redirect_uri=>"/gw/admin_messages?#{@qs}"}
    _create(@item,options)
  end

  def edit
    init_params

    @item = Gw::AdminMessage.find(params[:id])
    return http_error(404) if @item.blank?
  end
  def update
    init_params
    @item = Gw::AdminMessage.find(params[:id])
    @item.attributes = item_params

    options={:success_redirect_uri=>"/gw/admin_messages/#{@item.id}?#{@qs}"}
    _update(@item,options)
  end

  def destroy
    init_params
    @item = Gw::AdminMessage.find(params[:id])
    return http_error(404) if @item.blank?

    options={:success_redirect_uri=>"/gw/admin_messages?#{@qs}"}
    _destroy(@item,options)
  end

  def init_params
    qsa = ['limit' , 's_keyword']
    @qs = qsa.delete_if{|x| nz(params[x],'')==''}.collect{|x| %Q(#{x}=#{params[x]})}.join('&')
  end

private

  def item_params
    params.require(:item)
          .permit(:state, :sort_no, :body)
  end

end
