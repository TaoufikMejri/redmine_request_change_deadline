# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :change_deadlines
#post 'change_deadlines/new', :controller => 'change_deadlines', :action => 'create'
match '/change_deadlines/context_menu', :to => 'context_menus#requests', :as => 'requests_context_menu', :via => [:get, :post]
post 'change_deadlines/new', to: 'change_deadlines#create'
patch '/change_deadlines/:id/edit', to: 'change_deadlines#update'
post '/change_deadlines/:id/approve_request', to: 'change_deadlines#approve_request', :as => 'approve_request'
get '/change_deadlines/:id/approve_request', to: 'change_deadlines#approve_request'
post '/change_deadlines/:id/reject_request', to: 'change_deadlines#reject_request', :as => 'reject_request'
get '/change_deadlines/:id/reject_request', to: 'change_deadlines#reject_request'