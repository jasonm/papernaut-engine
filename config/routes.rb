PapernautEngine::Application.routes.draw do
  resources :discussions, only: %w(index)
  resources :stats, only: %w(index)

  root to: 'stats#index', format: 'json'
end
