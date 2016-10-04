Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'home', to: "home#index"

  root to: "table#index"
  get :join, to: "table#join"
  get :leave, to: "table#leave"
  get :start, to: "table#start"

  devise_for :players,
    controllers: {
      sessions: 'devise/sessions'
    }

  resource :cards, only: [:show] do
    patch :add, to: "cards#add"
  end

  resources :transactions, only: [:new, :create] do
  end

end
