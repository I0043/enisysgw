# -*- encoding: utf-8 -*-
class Gwcircular::File < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile
  include Gwcircular::Model::Systemname

  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Gwcircular::Doc'

  before_create :before_create
  after_create :after_create
  after_destroy :after_destroy
  validates_presence_of :filename, :message => I18n.t('rumi.attachment.message.no_file')

  # === 転送用の元記事情報を取得するスコープ
  #
  # ==== 引数
  #  * parent_id: 転送用の元記事ID
  # ==== 戻り値
  #  抽出結果(ActiveRecord::Relation)
  scope :get_file, lambda { |parent_id|
    where(parent_id: parent_id)
  }

  def self.search(params)
    *columns = :filename
    file_arel_table = self.arel_table
    doc_arel_table = Gwcircular::Doc.arel_table
    and_cond = []
    params.each do |n, v|
      next if v.to_s == ''
      case n
      when 'kwd'
        or_cond  = []
        v.to_s.split(/[ 　]+/).each_with_index do |w, i|
          break if i >= 10
          columns.each do |col|
            qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
            or_cond << file_arel_table[col].matches("%#{qw}%")
          end
        end
        or_cond1 = or_cond.shift
        or_cond.each do |c|
          or_cond1 = or_cond1.or c
        end
        and_cond << or_cond1
      #作成者を検索条件に追加
      when 'creator'
        or_cond  = []
        quote_string = connection.quote_string(v).gsub(/([_%])/, '\\\\\1')

        # == 作成者名での部分一致検索条件 ==
        or_cond << doc_arel_table[:creater].matches("%#{quote_string}%")
        # == 所属名での部分一致検索条件 ==
        # 所属名で部分一致するSystem::Groupを取得
        groups = System::Group.where("name LIKE '%#{quote_string}%'")

        # 所属コード配列を取得
        # ※Gwbbs::Doc.createrdivision_idには所属コードが登録されているので
        # 　検索条件には所属コードを使用する
        group_codes = groups.map(&:code)
        or_cond << doc_arel_table[:createrdivision_id].in(group_codes)

        or_cond1 = or_cond.shift
        or_cond.each do |c|
          or_cond1 = or_cond1.or c
        end
        and_cond << or_cond1
      #期限日を検索条件に追加
      when 'expirydate_start'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:expiry_date].gteq(value+" 00:00:00")
      when 'expirydate_end'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:expiry_date].lteq(value+" 23:59:59")
      #作成日を検索条件に追加
      when 'createdate_start'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:created_at].gteq(value+" 00:00:00")
      when 'createdate_end'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:created_at].lteq(value+" 23:59:59")
      end
    end if params.size != 0
    if and_cond.present?
      and_cond1 = and_cond.shift
      and_cond.each do |c|
        and_cond1 = and_cond1.and c
      end
      and_cond = and_cond1
    end
    return self.where(and_cond)
  end

  def item_path
    return "#{Site.current_node.public_uri.chop}?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end

  def edit_memo_path(title,item)
    return "#{Site.current_node.public_uri}#{self.parent_id}/edit_file_memo/#{self.id}?title_id=#{self.title_id}"
  end

  def item_parent_path
    return "#{Site.current_node.public_uri}#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
  end

  def item_doc_path(title,item)
    return "#{Site.current_node.public_uri}#{self.parent_id}?title_id=#{self.title_id}"
  end

  def delete_path
    return "#{Site.current_node.public_uri}#{self.id}/delete?title_id=#{self.title_id}&p_id=#{self.parent_id}"
  end
end
