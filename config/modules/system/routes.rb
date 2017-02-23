EnisysGw::Application.routes.draw do
#Rails.application.routes.draw do
  
  mod = "system"
  scp = "admin"
  
  namespace mod do
    scope :module => scp do
      ## admin
      resources "ldap_groups",
        :controller => "ldap_groups",
        :path => ":parent/ldap_groups"
      resources "ldap_temporaries",
        :controller => "ldap_temporaries",
        :path => "ldap_temporaries" do
          member do
            get :synchronize
            post :synchronize
            put :synchronize
            delete :synchronize
          end
        end
      resources :users do
        collection do
          get :csv, :csvget, :csvup, :csvset, :profile_settings
          post :csvup, :csvset, :image_create
          put :edit_profile_settings, :update_profile
        end
        member do
          get :csvshow, :edit_profile, :show_profile, :profile_upload, :image_destroy
        end
      end
      resources :groups
      resources :users_groups
      resources "roles" do
        collection do
          get :user_fields
        end
      end
      resources :custom_groups do
        collection do
          put :sort_update
          post :get_users
        end
      end
      resources :group_changes do
        collection do
          get :prepare, :reflects, :pickup, :fixed, :csv, :deletes, :prepare_run, :reflects_run, :pickup_run, :fixed_run, :csv_run, :deletes_run
        end
      end
      resources :access_logs do
        collection do
          get :export
          post :export
          put :export
          delete :export
        end
      end
      resources :schedule_roles
      resources :login_images do
        collection do
          post :image_upload
        end
      end
    end
  end
  
  ##API
  match 'api/checker'         => 'system/admin/api#checker', :via => [:get, :post]
  match 'api/checker_login'   => 'system/admin/api#checker_login', :via => [:get, :post]
  match 'api/air_sso'         => 'system/admin/api#sso_login', :via => [:get, :post]
  
  match ':controller(/:action(/:id))(.:format)', :via => [:get, :post]
end
