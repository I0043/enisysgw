module Gwcircular::Model::Systemname
  def system_name
    return 'gwcircular'
  end
  def file_base_path
    return "/_attaches/#{self.system_name}"
  end
end
