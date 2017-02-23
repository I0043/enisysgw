# encoding: utf-8
module Doclibrary::Model::Recognition
  def self.included(mod)
    mod.after_validation :validate_recognizers
  end

  attr_accessor :_recognition
  attr_accessor :_recognizers

  def validate_recognizers
    if state == 'recognize' && _recognizers
      valid = nil
      is_readable = true
      _recognizers.each do |k, v|
        if v.to_s != ''
          valid = true

          # 分類フォルダが選択されている場合、閲覧権限のあるユーザーかどうかのチェック
          unless category1_id.blank?
            target_user = System::User.find(v)
            if target_user.blank?
              is_readable = false
              break
            else
              unless target_user.readable_folder_in_doclibrarys?(category1_id)
                is_readable = false
                break
              end
            end
          end
        end
      end
      if valid
        errors.add I18n.t('rumi.doclibrary.th.recognizer'), I18n.t('rumi.doclibrary.message.valid_recognizer') unless is_readable
      else
        errors.add I18n.t('rumi.doclibrary.th.recognizer'), I18n.t('rumi.error.input') unless valid
      end
    end
  end
end