Spliddit::Application.routes.draw do
  
  resources :applications, path: "apps", only: [:index]

  post 'apps/rent/create', to: 'splitting_rent_instances#create'
  get 'apps/rent/demo', to: 'splitting_rent_instances#demo'
  resources :splitting_rent_instances, path: "apps/rent", only: [:new, :show, :index] do
    member do
      post 'valuations/:pwd', action: 'submit_valuation', as: :submit_valuation
      post 'survey/:pwd', action: 'submit_survey', as: :submit_survey
    end
  end

  post 'apps/goods/create', to: 'dividing_goods_instances#create'
  get 'apps/goods/demo', to: 'dividing_goods_instances#demo'
  resources :dividing_goods_instances, path: "apps/goods", only: [:new, :show, :index] do
    member do
      post 'valuations/:pwd', action: 'submit_valuation', as: :submit_valuation
      post 'survey/:pwd', action: 'submit_survey', as: :submit_survey
    end
  end

  post 'apps/credit/create', to: 'sharing_credit_instances#create'
  get 'apps/credit/demo', to: 'sharing_credit_instances#demo'
  resources :sharing_credit_instances, path: "apps/credit", only: [:new, :show, :index] do
    member do
      post 'valuations/:pwd', action: 'submit_valuation', as: :submit_valuation
      post 'survey/:pwd', action: 'submit_survey', as: :submit_survey
    end
  end

  resources :splitting_fare_instances, path: "apps/fare", only: [:index, :new]

  post 'apps/tasks/create', to: 'assigning_tasks_instances#create'
  get 'apps/tasks/demo', to: 'assigning_tasks_instances#demo'
  resources :assigning_tasks_instances, path: "apps/tasks", only: [:new, :show, :index] do
    member do
      post 'valuations/:pwd', action: 'submit_valuation', as: :submit_valuation
      post 'survey/:pwd', action: 'submit_survey', as: :submit_survey
    end
  end

  get '/about', to: 'static_pages#about'
  get '/feedback', to: 'feedbacks#feedback'
  get '/success', to: 'statuses#success'
  get '/error', to: 'statuses#error'
  get '/404', to: 'statuses#error404'
  get '/422', to: 'statuses#error500'
  get '/500', to: 'statuses#error500'

  post '/demo/create', to: 'demos#create'
  get '/demo/poll', to: 'demos#poll'

  post '/mailing_list/add', to: 'mailing_lists#mailing_list'

  post '/submit-feedback', to: 'feedbacks#submit_feedback'

  root to: "applications#index"
end