Smartchat::Application.routes.draw do
  resources :friends, :only => [:index], :format => false do
    collection do
      post :search
    end

    member do
      post :add
    end
  end

  resources :media, :only => [:create], :format => false

  resources :users, :only => [:create], :format => false

  root :to => "home#index"
end
