# -*- encoding: utf-8 -*-
class Gwbbs::Script::Dl

  def self.change
    items = Gwbbs::Control.where(upload_system: 1)
    p "対象掲示板件数: #{items.size}"
    for @title in items
      p "変換開始:#{Time.now}, #{@title.title}"
      begin
      item = db_alias(Gwbbs::File)
      files = item.where(unid: 2)
      rec_cnt = 0
      for file in files
        rec_cnt += 1
        item = db_alias(Gwbbs::Doc)
        doc = item.where(id: file.parent_id).first
        unless doc.blank?
          str = sprintf("%08d",file.id)
          str = "#{str[0..3]}/#{str[4..7]}"
          parent_name = Util::CheckDigit.check(format('%07d', file.parent_id))
          bef_file_name = "#{file.file_uri(@title.system_name)}"
          aft_file_name = "/_admin/attaches/gwbbs/#{sprintf('%06d',file.title_id)}/#{parent_name}/#{str}/#{URI.encode(file.filename)}"
          sql = %Q[UPDATE `gwbbs_docs` SET body=REPLACE(body,'#{bef_file_name}', '#{aft_file_name}') WHERE id=#{file.parent_id};]
          doc._execute_sql(sql)

          file.content_id = 3
          file.db_file_id = 0
          file.save
        end
        Gwbbs::Doc.remove_connection
      end
      Gwbbs::File.remove_connection
      @title.upload_system = 3
      @title.save
      p "変換終了:#{Time.now}, #{@title.title}, #{rec_cnt}"
      rescue
        p "データベースが存在しない:#{@title.dbname}"
      end
    end
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end