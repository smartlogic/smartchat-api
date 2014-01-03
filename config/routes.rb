Smartchat::Application.routes.draw do
  resource :device, :only => [:create], :format => false

  get "/files/*file_path" => "files#show", :as => "file", :format => false

  resources :friends, :only => [:index], :format => false do
    collection do
      post :search
    end

    member do
      post :add
    end
  end

  resources :media, :only => [:create, :index], :format => false

  resources :users, :only => [:create], :format => false do
    collection do
      post :invite
      post :sign_in
    end
  end

  mount Sidekiq::Web => '/sidekiq'

  root :to => "home#index"
end
