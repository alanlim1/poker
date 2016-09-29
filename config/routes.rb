Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "table#index"
  get :join, to: "table#join"
  devise_for :players,
    controllers: {
      sessions: 'devise/sessions'
    }

end
