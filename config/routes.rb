Rails.application.routes.draw do
  get "/seasons/:season", to: "teams#index", as: "season"
  get "/seasons/", to: "teams#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
