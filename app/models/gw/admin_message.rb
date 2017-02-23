# encoding: utf-8
class Gw::AdminMessage < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :state,:sort_no,:body
  validates_numericality_of :sort_no
  validates_length_of :body, :maximum=>10000

  def self.state_select
    [[I18n.t("rumi.state.use"), 1],[I18n.t("rumi.state.unuse"), 2]]
  end

  def self.state_show(state)
    states = [[1, I18n.t("rumi.state.use")],[2, I18n.t("rumi.state.unuse")]]
    show = states.assoc(state)
    return show[1] unless show.blaknk?
    return ''
  end
end
