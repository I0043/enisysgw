# encoding: utf-8
module System::Controller::Scaffold
  def self.included(mod)
    mod.before_action :initialize_scaffold
  end

  def initialize_scaffold

  end

  def edit
    show
  end

protected
  def argument_check(options={})
    # GW2.0ではすべてのコマンドが admin 以下に移動したのでこのチェックを外す
    # raise ArgumentError, 'public call では必ず :success_redirect_uri を指定してください' if Core.mode == 'public' && options[:success_redirect_uri].nil?
  end
  
  def _index(items)
    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => to_xml(items) }
    end
  end

  def _show(item)
    return send(params[:do], item) if params[:do]

    respond_to do |format|
      format.html { render }
      format.xml  { render :xml => to_xml(item) }
      format.json { render :text => item.to_json }
      format.yaml { render :text => item.to_yaml }
    end
  end

  def _create(item, options = {})
    argument_check(options)
    respond_to do |format|
      if item.creatable? && item.save
        options[:after_process].call if options[:after_process]

        location = nz(options[:success_redirect_uri], url_for(:action => :index))
        location.sub!(/\[\[id\]\]/, "#{item.id}") if options[:no_update_id].nil?
        flash[:notice] = options[:notice] || t("rumi.message.notice.create")
        format.html { redirect_to location }
        format.xml  { render :xml => to_xml(item), :status => status, :location => location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # バリデーションの後も"引用作成"の状態を維持するため
  alias quote__create _create unless method_defined? :quote__create
  def _create(x,y = {})
    if params[:sender_action] == 'quote' and @item.invalid?
      flash[:notice] = t("rumi.message.notice.create_fail")
      respond_to do |format|
        format.html { render :action => :new, :params => { :sender_action => 'quote' } }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    else
      quote__create(x,y)
    end
  end

  def _update(item, options = {})
    argument_check(options)
    respond_to do |format|
      if item.editable? && item.save
        options[:after_process].call if options[:after_process]

        location = nz(options[:success_redirect_uri], url_for(:action => :index))
        location.sub!(/\[\[id\]\]/, "#{item.id}") if options[:no_update_id].nil?
        flash[:notice] = options[:notice] || t("rumi.message.notice.update")
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _destroy(item, options = {})
    argument_check(options)
    respond_to do |format|
      if item.deletable? && item.destroy
        options[:after_process].call if options[:after_process]

        flash[:notice] = options[:notice] || t("rumi.message.notice.delete")
        format.html { redirect_to nz(options[:success_redirect_uri], url_for(:action => :index)) }
        format.xml  { head :ok }
      else
        flash[:notice] = t("rumi.message.notice.delete_fail")
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
