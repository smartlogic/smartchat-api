Smartchat::Application.routes.draw do
  resource :device, :only => [:create], :format => false

  get "/files/*file_path" => "files#show", :as => "file", :format => false

  resources :friends, :only => [:index], :format => false do
    collection do
      post :search
      get :groupies
    end

    member do
      post :add
    end
  end

  resources :media, :only => [:create, :index], :format => false do
    member do
      post "/" => :viewed
    end
  end

  resources :users, :only => [:create], :format => false do
    collection do
      post :invite
      post :sign_in

      get "/sms/verify" => :sms_verify
      post "/sms/confirm" => :sms_confirm
    end
  end

  mount Raddocs::App => "/docs"
  mount Sidekiq::Web => '/sidekiq'

  root :to => "home#index"
end
