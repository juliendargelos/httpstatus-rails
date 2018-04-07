Rails.application.routes.draw do
  # handles_not_found_status

  get '/hey' => 'application#index'
end
