Smartchat::Application.routes.draw do
  resource :device, :only => [:create], :format => false

  resources :friends, :only => [:index], :format => false do
    collection do
      post :search
    end

    member do
      post :add
    end
  end

  resources :media, :only => [:create], :format => false

  resources :users, :only => [:create], :format => false do
    collection do
      post :sign_in
    end
  end

  root :to => "home#index"
end
