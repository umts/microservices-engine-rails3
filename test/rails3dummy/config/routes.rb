Rails.application.routes.draw do

  mount MicroservicesEngine::Engine => "/microservices_engine"
end
