Rails.application.routes.draw do

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "home#index"
  devise_for :players, 
    controllers: {
      sessions: 'devise/sessions'
    },
    path_names: { sign_in: 'login', sign_out: 'logout', sign_up: 'register' }

  resource :cards, only: [:show] do
    patch :add, to: "cards#add"
  end
end
