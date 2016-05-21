Spliddit::Application.routes.draw do
  
  resources :applications, path: "apps", only: [:index]

  match 'apps/rent/create', to: 'splitting_rent_instances#create', via: [:post]
  match 'apps/rent/demo', to: 'splitting_rent_instances#demo'
  resources :splitting_rent_instances, path: "apps/rent", only: [:new, :show, :index]
  match 'apps/rent/:id/valuations/:pwd', to: 'splitting_rent_instances#submit_valuation'
  match 'apps/rent/:id/survey/:pwd', to: 'splitting_rent_instances#submit_survey'

  match 'apps/goods/create', to: 'dividing_goods_instances#create', via: [:post]
  match 'apps/goods/demo', to: 'dividing_goods_instances#demo'
  # match 'apps/goods/two-people', to: 'dividing_goods_instances#two_people'
  # match 'apps/goods/three-or-more-people', to: 'dividing_goods_instances#three_or_more_people'
  resources :dividing_goods_instances, path: "apps/goods", only: [:new, :show, :index]
  match 'apps/goods/:id/valuations/:pwd', to: 'dividing_goods_instances#submit_valuation'
  match 'apps/goods/:id/survey/:pwd', to: 'dividing_goods_instances#submit_survey'

  match 'apps/credit/create', to: 'sharing_credit_instances#create', via: [:post]
  match 'apps/credit/demo', to: 'sharing_credit_instances#demo'
  resources :sharing_credit_instances, path: "apps/credit", only: [:new, :show, :index]
  match 'apps/credit/:id/valuations/:pwd', to: 'sharing_credit_instances#submit_valuation'
  match 'apps/credit/:id/survey/:pwd', to: 'sharing_credit_instances#submit_survey'

  resources :splitting_fare_instances, path: "apps/fare", only: [:index, :new]

  match 'apps/tasks/create', to: 'assigning_tasks_instances#create', via: [:post]
  match 'apps/tasks/demo', to: 'assigning_tasks_instances#demo'
  resources :assigning_tasks_instances, path: "apps/tasks", only: [:new, :show, :index]
  match 'apps/tasks/:id/valuations/:pwd', to: 'assigning_tasks_instances#submit_valuation'
  match 'apps/tasks/:id/survey/:pwd', to: 'assigning_tasks_instances#submit_survey'

  match '/about',   to: 'static_pages#about'
  match '/feedback', to: 'feedbacks#feedback'
  match '/success', to: 'statuses#success'
  match '/error', to: 'statuses#error'
  match '/404', to: 'statuses#error404'
  match '/422' => 'statuses#error500'
  match '/500', to: 'statuses#error500'

  match '/demo/create', to: 'demos#create'
  match '/demo/poll', to: 'demos#poll'

  match '/mailing_list/add', to: 'mailing_lists#mailing_list'

  match '/submit-feedback', to: 'feedbacks#submit_feedback'

  root to: "applications#index"
end
