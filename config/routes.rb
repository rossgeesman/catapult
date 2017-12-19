Rails.application.routes.draw do

  resources :tags do
    collection do
      get 'stats'
    end
  end

  resources :breeds do
    resources :tags
    collection do
      get 'stats'
    end
  end

end
