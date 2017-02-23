# encoding: utf-8
class System::Script::Session
  def self.delete_expired_sessions
    start_str = "System::Script::Session.delete_expired_sessions " + I18n.t("rumi.session.auto_delete_start") + "：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
    puts start_str
    dump start_str

    #削除実行
    expired = (24 * 3).hours.ago
    delete_cnt1 = System::Session.count_by_sql(["select count(*) from sessions where updated_at < ?", expired]) # 削除対象データの数を取得
    System::Session.where("updated_at < ?", expired).delete_all
    delete_cnt2 = System::Session.count_by_sql(["select count(*) from sessions where updated_at < ?", expired]) # 削除対象データの数を取得

    # インデックス再構築
    if delete_cnt1 > delete_cnt2
      connect = System::Session.connection()
      connect.execute('optimize table `sessions`;')
      connect.execute('analyze table `sessions`;')
    end

    delete_cnt = delete_cnt1 - delete_cnt2
    end_str = "System::Script::Session.delete_expired_sessions " + I18n.t("rumi.session.auto_delete_end") + "：#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} - delete_count:#{delete_cnt}"
    puts end_str
    dump end_str
  end
end
