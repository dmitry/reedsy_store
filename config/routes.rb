Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :update ] do
        collection do
          post :calculate
        end
      end
    end
  end
end
