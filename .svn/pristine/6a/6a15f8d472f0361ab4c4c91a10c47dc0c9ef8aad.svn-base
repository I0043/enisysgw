# -*- encoding: utf-8 -*-
module Doclibrary::Admin::IndicesHelper

  def doclib_params_set_index
    ret = ""
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    ret += "&creator=#{URI.encode(params[:creator])}" unless params[:creator].blank?
    ret += "&term_start=#{URI.encode(params[:term_start])}" unless params[:term_start].blank?
    ret += "&term_finish=#{URI.encode(params[:term_finish])}" unless params[:term_finish].blank?
    return ret
  end

  def doclib_params_set
    ret = ""
    ret += "&state=#{params[:state]}" unless params[:state].blank?
    ret += "&gcd=#{params[:gcd]}" unless params[:gcd].blank?
    ret += "&cat=#{params[:cat]}" unless params[:cat].blank?
    ret += "&page=#{params[:page]}" unless params[:page].blank?
    ret += "&limit=#{params[:limit]}" unless params[:limit].blank?
    ret += "&drag_option=#{params[:drag_option]}" unless params[:drag_option].blank?
    ret += "&kwd=#{URI.encode(params[:kwd])}" unless params[:kwd].blank?
    ret += "&creator=#{URI.encode(params[:creator])}" unless params[:creator].blank?
    ret += "&term_start=#{URI.encode(params[:term_start])}" unless params[:term_start].blank?
    ret += "&term_finish=#{URI.encode(params[:term_finish])}" unless params[:term_finish].blank?
    return ret
  end

  def doclib_start_line
    l_limit = is_integer(params[:limit])
    l_limit = 30 unless l_limit
    l_page = is_integer(params[:page])
    unless l_page
      l_page = 0
    else
      l_page = l_page - 1
      l_page = 0 if l_page < 0
    end
    return l_limit * l_page
  end

  def retstr_attache(attach)
    str = ''
    unless attach.blank?
      if attach.to_s != '0'
        str = 'class="bbsAttach"'
      end
    end
    return str
  end

  def retstr_balloon(balloon)
    str = ''
    str = 'class="bbsBalloon"' if balloon.to_s == '1' unless balloon.blank?
    return str
  end

  def retstr_important(important)
    str = ''
    str = 'class="bbsImportant"' if important.to_s == '0' unless important.blank?
    return str
  end

  def ret_str_doclibrary_search_title_lbl
    str = ''
    str = '<h4 class="docSearchTitle rumi-search-title">' + t("rumi.search.result") + '</h4>' if @is_doc_searching
    return str
  end

  def is_integer(no)
    if no == nil
      return false
    else
      begin
        Integer(no)
      rescue
        return false
      end
    end
  end

  # === フォルダ名の表示文字列取得メソッド
  #  本メソッドは、フォルダ名の表示文字列を取得するメソッドである。
  # ==== 引数
  #  * folder: カレントフォルダー
  # ==== 戻り値
  #  表示文字列
  def get_doc_folder(folder)
    folder_path = ''
    unless folder.blank?
      # 親フォルダツリーを取得
      parent_tree = folder.parent_tree

      # フォルダ階層によってフォルダ名の表示を変更
      case parent_tree.count
      when 1..2 then
        # そのままパスを表示
        folder_path = parent_tree.map{|tree| tree.name}.join('/')
      else
        # 先頭フォルダと末尾フォルダのみ表示（中間フォルダは /…/ で省略）
        folder_path = parent_tree.first.name + '/.../' + parent_tree.last.name
      end
    end
    return folder_path
  end

  # === フォルダ名ツールチップ作成メソッド
  #  本メソッドは、フォルダ名のツールチップ作成するメソッドである。
  # ==== 引数
  #  * folder: カレントフォルダー
  #  * is_ie: ブラウザがIEかどうか（True:IE / False:IE以外）
  # ==== 戻り値
  #  ツールチップ文字列
  def create_doc_folder_tooltip(folder, is_ie = Gw.ie?(request) )
    path = []
    unless folder.blank?
      parent_tree = folder.parent_tree
      path = parent_tree.map{|tree| tree.name}
    end
    tooltip = Gw.simple_strip_html_tags(path.join('/'), :exclude_tags=>'br/')
    return tooltip
  end
end
