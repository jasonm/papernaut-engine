Journalclub::Application.routes.draw do
  resources :discussions, only: %w(index create)
end
