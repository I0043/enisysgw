# encoding: utf-8
class Gw::PropGroup < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content

  validates_presence_of :name, :sort_no
  validates :sort_no, numericality: {only_integer: true, less_than_or_equal_to: 999999999}
end
