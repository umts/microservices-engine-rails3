# frozen_string_literal: true
MicroservicesEngine::Engine.routes.draw do
  namespace :v1 do
    match '/data' => 'data#register', :via => :post
  end
end
