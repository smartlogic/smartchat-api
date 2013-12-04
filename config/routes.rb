Smartchat::Application.routes.draw do
  resources :users, :only => [:create], :format => false

  root :to => "home#index"
end
