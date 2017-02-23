EnisysGw::Application.routes.draw do
  mod = "doclibrary"
  scp = "admin"

  match "doclibrary",                                    :to => "doclibrary/admin/menus#index", :via => [:get, :post]
  match "doclibrary/docs/:parent_id/edit_file_memo/:id", :to => "doclibrary/admin/docs#edit_file_memo", :via => [:get, :post]
  
  #scope "_#{scp}" do
    namespace mod do
      scope :module => scp do
        resources "menus",
          :controller => "menus",
          :path => "menus"
        resources "docs",
          :controller => "docs",
          :path => "docs" do
            member do
              get :recognize_update, :publish_update, :clone
            end
            collection do
              get :destroy_void_documents, :files_drag, :folder_drag
            end
          end
        resources "cabinets",
          :controller => "cabinets",
          :path => "cabinets" do
              member do
                get :delete
              end
          end
        resources "folders",
          :controller => "folders",
          :path => "folders" do
              member do
                get :delete
              end
              collection do
                get :maintenance_acl
              end
          end
        resources "group_folders",
          :controller => "group_folders",
          :path => "group_folders" do
              member do
                get :delete
              end
              collection do
                get :sync_groups, :sync_children
              end
          end
        resources "menus",
          :controller => "piece/menus",
          :path => "piece/menus" do
            collection do
              get :refresh_folder_trees
            end
          end
      end
    end
  #end

end
