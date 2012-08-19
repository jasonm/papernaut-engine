Journalclub::Application.routes.draw do
  resources :discussions, only: %w(index)
  resources :stats, only: %w(index)
end
