# -*- encoding: utf-8 -*-
class Doclibrary::GroupFolder < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include System::Model::Tree

  acts_as_tree :order=>'sort_no'

  validates_presence_of :state, :name

  # === 機能：ファイル管理でpaginateを設定するためのスコープ
  #
  # ==== 引数
  #  * params: パラメータ
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :paginate_doclibrary, lambda { |params|
    item = Doclibrary::Control.find_by(id: params[:title_id])
    default_limit = item.default_limit if item.present?
    default_limit = 20 unless item.present?
    paginate(page: params[:page]).limit(params[:limit].present? ? params[:limit].to_i : default_limit)
  }

  def status_select
    [[I18n.t('rumi.doclibrary.file_folder_option.status_select.public'),'public'], [I18n.t('rumi.doclibrary.file_folder_option.status_select.closed'),'closed']]
  end


  def status_name
    {'public' => I18n.t('rumi.doclibrary.file_folder_option.status_select.public'), 'closed' => I18n.t('rumi.doclibrary.file_folder_option.status_select.closed')}
  end

  def level1
    self.and :level_no, 1
    return self
  end

  def level2
    self.and :level_no, 2
    return self
  end

  def level3
    self.and :level_no, 3
    return self
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        search_keyword v, :name
      end
    end if params.size != 0

    return self
  end

  def item_home_path
    return '/doclibrary/'
  end

  def link_list_path
    return "#{self.item_home_path}group_folders?title_id=#{self.title_id}&state=GROUP&grp=#{self.id}&gcd=#{self.code}"
  end

  def item_path
    return "#{self.item_home_path}group_folders?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def show_path
    return "#{self.item_home_path}group_folders/#{self.id}?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def edit_path
    return "#{self.item_home_path}group_folders/#{self.id}/edit?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def delete_path
    return "#{self.item_home_path}group_folders/#{self.id}?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

  def update_path
    return "#{self.item_home_path}group_folders/#{self.id}?title_id=#{self.title_id}&state=GROUP&grp=#{self.parent_id}&gcd=#{self.code}"
  end

end
