Rails.application.routes.draw do
  root 'welcome#index'
  get 'location_suggester' => 'welcome#location_suggester'
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
