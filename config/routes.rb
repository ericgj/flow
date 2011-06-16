Flow::Application.routes.draw do

  root :to => '/'

  match '/auth/:provider/callback',      :to => 'sessions#create'
  match '/logout' => 'sessions#destroy', :as => 'logout'
  match '/login' => 'sessions#new',      :as => 'login'
  match '/admin/logout' => 'sessions#destroy'
end
