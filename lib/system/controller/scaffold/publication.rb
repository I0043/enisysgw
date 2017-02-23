# encoding: utf-8
module System::Controller::Scaffold::Publication
  def publish(item)
    _publish(item)
  end

  def rebuild(item)
    _rebuild(item)
  end

  def close(item)
    _close(item)
  end

protected
  def _publish(item, options = {})
    respond_to do |format|
      if item.publishable? && item.publish
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash.now[:notice] = options[:notice] || I18n.t("rumi.message.notice.publish")
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash.now[:notice] = I18n.t("rumi.message.notice.publish_fail")
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _rebuild(item, options = {})
    respond_to do |format|
      if item.rebuildable? && item.rebuild
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash.now[:notice] = options[:notice] || I18n.t("rumi.message.notice.rebuild")
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash.now[:notice] = I18n.t("rumi.message.notice.rebuild_fail")
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def _close(item, options = {})
    respond_to do |format|
      if item.closable? && item.close
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash.now[:notice] = options[:notice] || I18n.t("rumi.message.notice.close")
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash.now[:notice] = I18n.t("rumi.message.notice.close_fail")
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
