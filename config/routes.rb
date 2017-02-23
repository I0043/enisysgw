EnisysGw::Application.routes.draw do
#Rails.application.routes.draw do

  root 'gw/admin/portal#index'

  ## Admin
  match '_admin/login.:format'   => 'sys/admin/account#login', :via => [:get, :post]
  match '_admin/login'           => 'sys/admin/account#login', :via => [:get, :post]
  match '_admin/smart_login'     => 'sys/admin/account#smart_login', :via => [:get, :post]
  match '_admin/logout.:format'  => 'sys/admin/account#logout', :via => [:get, :post]
  match '_admin/logout'          => 'sys/admin/account#logout', :via => [:get, :post]
  match '_admin/smart_logout'    => 'sys/admin/account#smart_logout', :via => [:get, :post]
  match "_admin/sso"             => "sys/admin/account#sso", :via => [:get, :post]
  match '_admin/air_login'       => 'sys/admin/air#old_login', :via => [:get, :post]
  match '_admin/air_sso'         => 'sys/admin/air#login', :via => [:get, :post]

  ## Modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\.+$/
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end

  match '/tab_main/:id'  => 'gw/admin/tab_main#show', :via => [:get, :post]

  ## Attachments
  def admin_attaches(sys)
    match "_admin/_attaches/#{sys}/:title_id/:name/:u_code/:d_code", :to => "attaches/admin/#{sys}#download", :format => false, :via => [:get, :post]
    match "_admin/_attaches/#{sys}/:title_id/:name/:u_code/:d_code/*filename", :to => "attaches/admin/#{sys}#download", :format => false, :via => [:get, :post]

    #GW1.1.0移行対応(TinyMCE内のリンクがこのパターン）
    match "_admin/attaches/#{sys}/:title_id/:name/:u_code/:d_code", :to => "attaches/admin/#{sys}#download", :format => false, :via => [:get, :post]
    match "_admin/attaches/#{sys}/:title_id/:name/:u_code/:d_code/*filename", :to => "attaches/admin/#{sys}#download", :format => false, :via => [:get, :post]
  end

  admin_attaches('gwqa')
  admin_attaches('gwbbs')
  admin_attaches('gwfaq')
  admin_attaches('doclibrary')
  admin_attaches('digitallibrary')
  admin_attaches('gwcircular')
  admin_attaches('gwworkflow')
  admin_attaches('gwmonitor')
  admin_attaches('gwmonitor_base')
  admin_attaches('gwworkflow')

  ## Exception
  match '403.:format' => 'exception#index', :via => :all
  match '404.:format' => 'exception#index', :via => :all
  match '500.:format' => 'exception#index', :via => :all
  match '*path'       => 'exception#index', :via => :all

end
