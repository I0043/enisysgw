# -*- encoding: utf-8 -*-
class Doclibrary::ViewAclFile < Gw::Database
  include System::Model::Base
  include System::Model::Base::Content
  include Doclibrary::Model::Systemname
  include Gwboard::Model::AttachFile
  include Gwboard::Model::AttachesFile

  self.primary_key = :id

  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'Doclibrary::Doc'

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

  def self.get_keywords_condition(words, *columns)
    cond = Condition.new
    words.to_s.split(/[ 　]+/).each_with_index do |w, i|
      break if i >= 10
      cond.and do |c|
        columns.each do |col|
          qw = connection.quote_string(w).gsub(/([_%])/, '\\\\\1')
          c.or col, 'LIKE', "%#{qw}%"
        end
      end
    end
    return cond
  end
  
  def self.search(params)
    *columns = :filename
    file_arel_table = self.arel_table
    doc_arel_table = Doclibrary::Doc.arel_table
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
      #作成日を検索条件に追加
      when 'term_start'
        value = v.to_s.to_time.strftime("%Y-%m-%d")
        and_cond << doc_arel_table[:created_at].gteq(value+" 00:00:00")
      when 'term_finish'
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

  def item_parent_path(params=nil)
    if params.blank?
      state = 'CATEGORY'
    else
      state = params[:state]
    end
    ret = "/doclibrary/docs/#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}" unless state == 'GROUP'
    ret = "/doclibrary/docs/#{self.parent_id}/?title_id=#{self.title_id}&gcd=#{self.parent.section_code}" if state == 'GROUP'
    return ret
  end

  def item_doc_path(title,item)
    if title.form_name=='form002'
      return "/doclibrary/docs/#{item.id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
    else
      return "/doclibrary/docs/#{self.parent_id}?title_id=#{self.title_id}&cat=#{self.parent.category1_id}"
    end
  end

end
