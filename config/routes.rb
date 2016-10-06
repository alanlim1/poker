Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'home', to: "home#index"

  root to: "table#index"
  get :join, to: "table#join"
  get :leave, to: "table#leave"
  get :start, to: "table#start"
  get :call_bet, to: "player_actions#call_bet"
  get :check, to: "player_actions#check"
  post :raise_bet, to: "player_actions#raise_bet"
  get :fold, to: "player_actions#raise"
  get :flush_redis, to: "home#flush_redis"

  devise_for :players,
    controllers: {
      sessions: 'devise/sessions'
    }

  resources :transactions, only: [:new, :create] do
  end

end
