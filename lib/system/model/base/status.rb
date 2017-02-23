# encoding: utf-8
module System::Model::Base::Status
  def status_list
    [[I18n.t("rumi.state.enabled"), "enabled"],
     [I18n.t("rumi.state.disabled"), "disabled"],
     [I18n.t("rumi.state.view"), "visible"],
     [I18n.t("rumi.state.hidden"), "hidden"],
     [I18n.t("rumi.state.draft"), "draft"],
     [I18n.t("rumi.state.recognize"), "recognize"],
     [I18n.t("rumi.state.recognized"), "recognized"],
     [I18n.t("rumi.state.open"), "public"],
     [I18n.t("rumi.state.close"), "closed"],
     [I18n.t("rumi.state.completed"), "completed"]]
  end

  def status_show
    status_list.each {|a| return a[0] if a[1] == state }
    return nil
  end
end
