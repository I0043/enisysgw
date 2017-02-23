class Doclibrary::Script::Conv

  def self.convert(title_id)
    #files_converter(title_id)
    #images_converter(title_id)
  end

  def self.db_alias(item)
    cnn = item.establish_connection
    cnn.spec.config[:database] = @title.dbname.to_s
    Gwboard::CommonDb.establish_connection(cnn.spec.config)
    return item
  end
end
