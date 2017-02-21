# frozen_string_literal: true
MicroservicesEngineRails3::Engine.routes.draw do
  namespace :v1 do
    match '/data' => 'data#register', :via => :post
  end
end
