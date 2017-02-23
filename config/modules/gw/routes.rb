# -*- coding: utf-8 -*-
EnisysGw::Application.routes.draw do
  match '/api/header_menus' => 'gw/admin/piece/api#header_menus', :via => [:get, :post]
  match '/api/mail_admin' => 'gw/admin/piece/api#mail_admin', :via => [:get, :post]

  mod = "gw"
  scp = "admin"

  namespace mod do
    scope :module => scp do
      ## gw
      resources :portal
      resources :smart_portal

      resources :user_passwords

      resources :config_settings do
        collection do
          get :ind_settings
        end
      end
      resources :year_fiscal_jps
      resources :year_mark_jps
      resources :admin_messages

      resources :edit_link_pieces do
        collection do
          get :getajax_priv
        end
        member do
          get :updown, :swap
        end
      end

      resources :access_logs do
        collection do
          get :export
          post :export
        end
      end
    end
  end

  namespace mod do
    scope :module => scp do
      resources :holidays
      resources :prop_types
      resources :prop_group_settings do
        collection do
          get :getajax
        end
      end
      resources :prop_groups
      resources :prop_admin_settings

      resources :prop_others do
        member do
          get :upload, :image_create, :image_destroy
          post :image_create
        end

        collection do
          get :import, :export
          post :import_file
        end
      end
      resources :prop_other_limits do
        collection do
          get :synchro
        end
      end

      resources :schedules do
        collection do
          get :show_month, :event_week, :event_month, :setting_ind_schedules, :setting_gw_link, :ical, :search
          get :print_index, :print_show_month, :schedule_display
          put :edit_ind_schedules, :edit_ind_ssos, :edit_gw_link, :editlending, :edit_1, :edit_2
        end
        member do
          get :show_one, :editlending, :edit_1, :edit_2, :quote, :destroy_repeat, :delete_schedule, :delete_schedule_repeat, :finish
        end
      end
      resources :smart_schedules do
        collection do
          get :search_group, :search_user, :show_day
        end
        member do
          get :show_one, :delete_schedule, :delete_schedule_repeat, :finish
        end
      end
      resources :smart_schedule_props do
        collection do
          get :select, :show_day
        end
        member do
          get :list
        end
      end
      resources :schedule_props do
        collection do
          get :show_week, :show_2week, :show_month, :setting, :setting_system, :setting_ind, :getajax, :show_guard, :schedule_display
        end
        member do
          get :show_one
        end
      end
      resources :schedule_users do
        collection do
          get :getajax, :user_fields, :group_fields
        end
      end
      resources :schedule_lists do
        collection do
          get :user_fields, :csvput, :icalput
          post :user_select, :user_delete
        end
      end
      resources :schedule_settings do
        collection do
          get :admin_deletes, :export, :import, :potal_display
          put :edit_admin_deletes
          post :import_file
        end
      end
      namespace "piece" do
        resources :reminder do
          collection do
            post :all_seen_remind
            get :smart_index
          end
        end
      end
    end
  end

  # _admin
  scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources :link_sso, :constraints => {:id  => /[0-9]+/}  do
          collection do
            post :convert_hash, :import_csv, :download, :params_viewer
            get :redirect_to_plus
          end
          member do
            get :redirect_rumi_mail
          end
        end
      end
    end
  end
end
