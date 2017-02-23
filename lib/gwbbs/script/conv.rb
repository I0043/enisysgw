# -*- encoding: utf-8 -*-
class Gwbbs::Script::Conv

  def self.convert(title_id, link)
    #files_converter(title_id, link)
    #images_converter(title_id)
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
