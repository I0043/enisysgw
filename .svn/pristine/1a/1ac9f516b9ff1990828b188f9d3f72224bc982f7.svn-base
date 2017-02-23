# encoding: utf-8
module System::Controller::Scaffold::Recognition
  def recognize(item)
    _recognize(item)
  end

protected
  def _recognize(item, options = {})
    respond_to do |format|
      if item.recognizable?(Core.user) && item.recognize(Core.user)
        options[:after_process].call if options[:after_process]
        location = url_for(:action => :index)

        flash.now[:notice] = options[:notice] || I18n.t("rumi.message.notice.recognize")
        format.html { redirect_to location }
        format.xml  { head :ok }
      else
        flash.now[:notice] = I18n.t("rumi.message.notice.recognize_fail")
        format.html { render :action => :show }
        format.xml  { render :xml => item.errors, :status => :unprocessable_entity }
      end
    end
  end
end
