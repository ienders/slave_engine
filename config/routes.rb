ActionController::Routing::Routes.draw do |map|
  map.with_options :path_prefix => 'admin' do |admin|
    admin.resources :roles
    admin.resources :users
  end

  map.admin '/admin', :controller => 'admin', :action => 'redirect_for_role'

  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'

  map.user_account '/account/:action', :controller => 'account', :action => 'index'

  map.resource :session
  map.resources :account
end