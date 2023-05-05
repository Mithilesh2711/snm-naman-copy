## AUTHOR      :: UMESH CHAUHAN || ROR CONSULTANT & DEPLOYMENT OF LINUX(HOSTGATOR)
## HISTORY     :: 1.0.0
## DESCRIPTION :: This module control all common process integration for main controller
### FOR REST API ######


Rails.application.routes.draw do  
  get   '/index.html.var'=>'login#index'
  root  'login#index'  
  get   '/404.shtml'=>"invoice#show" 
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  post  'login/ajax_process'=>'login#ajax_process'
  #:return_ca_material  
  resources :login,:logout
end

Rails.application.routes.draw do
   
  get   "medical_aid/search"=>"medical_aid#index"
  post  "medical_aid/search"=>"medical_aid#index"
  post  "medical_aid/ajax"=>"medical_aid#index" 
  resources :medical_aid

end

Rails.application.routes.draw do  
  get   'postal#index'=>'postal#index'
  get   'postal/postal_received_entry'=>'postal#postal_received_entry'
  post  'postal/postal_received_entry'=>'postal#postal_received_entry'
  get   'postal/dispatch_entry_list'=>'postal#dispatch_entry_list'
  post  'postal/dispatch_entry_list'=>'postal#dispatch_entry_list'
  get   'postal/dispatch_entry'=>'postal#dispatch_entry'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :postal
end

Rails.application.routes.draw do  
  get   'dashboard#index'=>'dashboard#index'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :dashboard
end

Rails.application.routes.draw do  
  get   'change_password#index'=>'change_password#index'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :change_password
end

Rails.application.routes.draw do
  get   'state/index'=>'state#index'
  post  'state/index'=>'state#index'
  get   'state/add_state'=>'state#add_state'
  post  'state/add_state'=>'state#add_state'
  get   "state/:id"=>'state#index'
  get   'state/add_state/:id'=>'state#add_state'
  post  'state/add_state/:id'=>'state#add_state'
  get   'state/:id/deletes'=>'state#destroy'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :state
end

Rails.application.routes.draw do
    get   'magazine/index'=>'magazine#index'
    post  'magazine/index'=>'magazine#index'
    get   'magazine/add_magazine'=>'magazine#add_magazine'
    post  'magazine/add_magazine'=>'magazine#add_magazine'
    get   "magazine/:id"=>'magazine#index'
    get   'magazine/add_magazine/:id'=>'magazine#add_magazine'
    post  'magazine/add_magazine/:id'=>'magazine#add_magazine'
    get   'magazine/:id/deletes'=>'magazine#destroy'
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :magazine
  end

Rails.application.routes.draw do
  get   'district/index'=>'district#index'
  post  'district/index'=>'district#index'
  post  'district/search' =>'district#index'
  get   'district/search' =>'district#index'
  
  get   'district/add_district'=>'district#add_district'
  post  'district/add_district'=>'district#add_district'
  get   "district/:id"=>'district#index'
  get   "district/add_district/:id"=>'district#add_district'
  get   "district/:id/deletes"=>'district#destroy'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :district
end

Rails.application.routes.draw do
  get   'city/index'=>'city#index'
  post  'city/index'=>'city#index'  
  get   'city/search'=>'city#index'
  post  'city/search'=>'city#index'
  get   'city/add_city'=>'city#add_city'
  post  'city/add_city'=>'city#add_city'
  get   'city/:id'=>'city#index'
  post  'city/ajax_process'=>'city#ajax_process'
  get   'city/add_city/:id'=>'city#add_city'
  get   'city/:id/deletes'=>'city#destroy'
 
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :city
end

Rails.application.routes.draw do
  get   'department/index'=>'department#index'
  post  'department/index'=>'department#index'
  get   'department/search'=>'department#index'
  post  'department/search'=>'department#index'
  get   'department/add_department'=>'department#add_department'
  post  'department/add_department'=>'department#add_department'
  get   'department/add_department/:id'=>'department#add_department'
  get   'department/sub_department'=>'department#sub_department'
  get   'department/:id'=>'department#index'
  get   'department/:id/deletes'=>'department#destroy'
  post  'department/ajax_process'=>'department#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :department
end

Rails.application.routes.draw do
  get   'sub_department/index'=>'sub_department#index'
  post  'sub_department/index'=>'sub_department#index'
  get   'sub_department/search'=>'sub_department#index'
  post  'sub_department/search'=>'sub_department#index'
  get   'sub_department/add_sub_department'=>'sub_department#add_sub_department'
  post  'sub_department/add_sub_department'=>'sub_department#add_sub_department'
  get   'sub_department/add_sub_department/:id'=>'sub_department#add_sub_department'
  get   'sub_department/:id'=>'sub_department#index'
  get   'sub_department/:id/deletes'=>'sub_department#destroy'
  post  'sub_department/ajax_process'=>'sub_department#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :sub_department
end


Rails.application.routes.draw do
  get   'designation/index'=>'designation#index'
  post  'designation/index'=>'designation#index'
  get   'designation/add_designation'=>'designation#add_designation'
  post  'designation/add_designation'=>'designation#add_designation'
  get   'designation/add_designation/:id'=>'designation#add_designation'
  get   'designation/search'=>'designation#index'
  post  'designation/search'=>'designation#index'
  get   'designation/:id'=>'designation#index'
  get   'designation/:id/deletes'=>'designation#destroy'

  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :designation
end

Rails.application.routes.draw do
    get   'language/index'=>'language#index'
    post  'language/index'=>'language#index'
    get   'language/add_language'=>'language#add_language'
    post  'language/add_language'=>'language#add_language'
    get   'language/add_language/:id'=>'language#add_language'
    get   'language/search'=>'language#index'
    post  'language/search'=>'language#index'
    get   'language/:id'=>'language#index'
    get   'language/:id/deletes'=>'language#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :language
  end

  Rails.application.routes.draw do
    get   'currency/index'=>'currency#index'
    post  'currency/index'=>'currency#index'
    get   'currency/add_currency'=>'currency#add_currency'
    post  'currency/add_currency'=>'currency#add_currency'
    get   'currency/add_currency/:id'=>'currency#add_currency'
    get   'currency/search'=>'currency#index'
    post  'currency/search'=>'currency#index'
    get   'currency/:id'=>'currency#index'
    get   'currency/:id/deletes'=>'currency#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :currency
  end

  Rails.application.routes.draw do
    get   'courier/index'=>'courier#index'
    post  'courier/index'=>'courier#index'
    get   'courier/add_courier'=>'courier#add_courier'
    post  'courier/add_courier'=>'courier#add_courier'
    get   'courier/add_courier/:id'=>'courier#add_courier'
    get   'courier/search'=>'courier#index'
    post  'courier/search'=>'courier#index'
    get   'courier/:id'=>'courier#index'
    get   'courier/:id/deletes'=>'courier#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :courier
  end

  Rails.application.routes.draw do
    get   'complaint_type/index'=>'complaint_type#index'
    post  'complaint_type/index'=>'complaint_type#index'
    get   'complaint_type/add_complaint_type'=>'complaint_type#add_complaint_type'
    post  'complaint_type/add_complaint_type'=>'complaint_type#add_complaint_type'
    get   'complaint_type/add_complaint_type/:id'=>'complaint_type#add_complaint_type'
    get   'complaint_type/search'=>'complaint_type#index'
    post  'complaint_type/search'=>'complaint_type#index'
    get   'complaint_type/:id'=>'complaint_type#index'
    get   'complaint_type/:id/deletes'=>'complaint_type#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :complaint_type
  end

  Rails.application.routes.draw do
    get   'dispatch_mode/index'=>'dispatch_mode#index'
    post  'dispatch_mode/index'=>'dispatch_mode#index'
    get   'dispatch_mode/add_dispatch_mode'=>'dispatch_mode#add_dispatch_mode'
    post  'dispatch_mode/add_dispatch_mode'=>'dispatch_mode#add_dispatch_mode'
    get   'dispatch_mode/add_dispatch_mode/:id'=>'dispatch_mode#add_dispatch_mode'
    get   'dispatch_mode/search'=>'dispatch_mode#index'
    post  'dispatch_mode/search'=>'dispatch_mode#index'
    get   'dispatch_mode/:id'=>'dispatch_mode#index'
    get   'dispatch_mode/:id/deletes'=>'dispatch_mode#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :dispatch_mode
  end

  Rails.application.routes.draw do
    get   'escalation_matrix/index'=>'escalation_matrix#index'
    post  'escalation_matrix/index'=>'escalation_matrix#index'
    get   'escalation_matrix/add_escalation_matrix'=>'escalation_matrix#add_escalation_matrix'
    post  'escalation_matrix/add_escalation_matrix'=>'escalation_matrix#add_escalation_matrix'
    get   'escalation_matrix/add_escalation_matrix/:id'=>'escalation_matrix#add_escalation_matrix'
    get   'escalation_matrix/search'=>'escalation_matrix#index'
    post  'escalation_matrix/search'=>'escalation_matrix#index'
    get   'escalation_matrix/:id'=>'escalation_matrix#index'
    get   'escalation_matrix/:id/deletes'=>'escalation_matrix#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :escalation_matrix
  end


  Rails.application.routes.draw do
    get   'dispatch_type/index'=>'dispatch_type#index'
    post  'dispatch_type/index'=>'dispatch_type#index'
    get   'dispatch_type/add_dispatch_type'=>'dispatch_type#add_dispatch_type'
    post  'dispatch_type/add_dispatch_type'=>'dispatch_type#add_dispatch_type'
    get   'dispatch_type/add_dispatch_type/:id'=>'dispatch_type#add_dispatch_type'
    get   'dispatch_type/search'=>'dispatch_type#index'
    post  'dispatch_type/search'=>'dispatch_type#index'
    get   'dispatch_type/:id'=>'dispatch_type#index'
    get   'dispatch_type/:id/deletes'=>'dispatch_type#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :dispatch_type
  end


  Rails.application.routes.draw do
    get   'rate_chart/index'=>'rate_chart#index'
    post  'rate_chart/index'=>'rate_chart#index'
    get   'rate_chart/add_rate_chart'=>'rate_chart#add_rate_chart'
    post  'rate_chart/add_rate_chart'=>'rate_chart#add_rate_chart'
    get   'rate_chart/add_rate_chart/:id'=>'rate_chart#add_rate_chart'
    get   'rate_chart/search'=>'rate_chart#index'
    post  'rate_chart/search'=>'rate_chart#index'
    get   'rate_chart/:id'=>'rate_chart#index'
    get   'rate_chart/:id/deletes'=>'rate_chart#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :rate_chart
  end


  Rails.application.routes.draw do
    get   'subscription_type/index'=>'subscription_type#index'
    post  'subscription_type/index'=>'subscription_type#index'
    get   'subscription_type/add_subscription_type'=>'subscription_type#add_subscription_type'
    post  'subscription_type/add_subscription_type'=>'subscription_type#add_subscription_type'
    get   'subscription_type/add_subscription_type/:id'=>'subscription_type#add_subscription_type'
    get   'subscription_type/search'=>'subscription_type#index'
    post  'subscription_type/search'=>'subscription_type#index'
    get   'subscription_type/:id'=>'subscription_type#index'
    get   'subscription_type/:id/deletes'=>'subscription_type#destroy'
  
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :subscription_type
  end


Rails.application.routes.draw do
  get   'qualification/index'=>'qualification#index'
  post  'qualification/index'=>'qualification#index'
  get   'qualification/add_qualification'=>'qualification#add_qualification'
  post  'qualification/add_qualification'=>'qualification#add_qualification'
  get   'qualification/add_qualification/:id'=>'qualification#add_qualification'
  post  'qualification/add_qualification/:id'=>'qualification#add_qualification'
  get   'qualification/search'=>'qualification#index'
  post  'qualification/search'=>'qualification#index'
  get   'qualification/:id'=>'qualification#index'
  get   'qualification/:id/deletes'=>'qualification#destroy'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :qualification
end

Rails.application.routes.draw do
  get   'responsibility/index'=>'responsibility#index'
  post  'responsibility/index'=>'responsibility#index'
  get   'responsibility/add_responsibility'=>'responsibility#add_responsibility'
  post  'responsibility/add_responsibility'=>'responsibility#add_responsibility'
  get   'responsibility/add_responsibility/:id'=>'responsibility#add_responsibility'
  get   'responsibility/search'=>'responsibility#index'
  post  'responsibility/search'=>'responsibility#index'
  get   'responsibility/:id'=>'responsibility#index'
  post  'responsibility/ajax_process'=>'responsibility#ajax_process'
  get   'responsibility/:id/deletes'=>'responsibility#destroy'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :responsibility
end


Rails.application.routes.draw do
  get   'sewadar_information/refresh_sewadar_information'    
  get   'sewadar_information/new_sewadar_user'
  get   'sewadar_information/index'=>'sewadar_information#index'
  post  'sewadar_information/index'=>'sewadar_information#index'
  get   'sewadar_information/add_sewadar'=>'sewadar_information#add_sewadar'
  post  'sewadar_information/add_sewadar'=>'sewadar_information#add_sewadar'
  get   'sewadar_information/add_sewadar/:id'=>'sewadar_information#add_sewadar'
  get   'sewadar_information/search'=>'sewadar_information#index'
  post  'sewadar_information/search'=>'sewadar_information#index'
  get   'sewadar_information/:id/deletes'=>'sewadar_information#destroy'
  post  'sewadar_information/ajax_process'=>'sewadar_information#ajax_process'
  
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :sewadar_information
end

Rails.application.routes.draw do
  get   'generate_ticket/refresh_ticket_list'
  get   'generate_ticket/refresh_generate_ticket'
  get   'generate_ticket/index'=>'generate_ticket#index'
  post  'generate_ticket/index'=>'generate_ticket#index'
  get   'generate_ticket/ticket_list'=>'generate_ticket#ticket_list'
  get   'generate_ticket/ticket_list/search'=>'generate_ticket#ticket_list'
  post  'generate_ticket/ticket_list/search'=>'generate_ticket#ticket_list'
  get   'generate_ticket/ticket_list/:id'=>'generate_ticket#ticket_list'
  get   'generate_ticket/:id/cancel'=>'generate_ticket#cancel'
  get   'view_ticket/index'=>'view_ticket#index'
  post  'view_ticket/index'=>'view_ticket#index'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :generate_ticket,:view_ticket
end

Rails.application.routes.draw do
  get   'resolve_ticket_issue/index'=>'resolve_ticket_issue#index'
  post  'resolve_ticket_issue/index'=>'resolve_ticket_issue#index' 
  get   'resolve_ticket_issue/search'=>'resolve_ticket_issue#index'
  post  'resolve_ticket_issue/search'=>'resolve_ticket_issue#index'
  post  'assign_ticket_issue/ajax_process'=>'assign_ticket_issue#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"

  resources :resolve_ticket_issue
end

Rails.application.routes.draw do
  get   'assign_ticket_issue/index'=>'assign_ticket_issue#index'
  post  'assign_ticket_issue/index'=>'assign_ticket_issue#index'
  get   'assign_ticket_issue/search'=>'assign_ticket_issue#index'
  post  'assign_ticket_issue/search'=>'assign_ticket_issue#index'
  post  'assign_ticket_issue/ajax_process'=>'assign_ticket_issue#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
 
  resources :assign_ticket_issue
end


Rails.application.routes.draw do
  get   'accomodation_allotment/index'=>'accomodation_allotment#index'
  post  'accomodation_allotment/index'=>'accomodation_allotment#index'
  get   'accomodation_allotment/search'=>"accomodation_allotment#allotment_list"
  post  'accomodation_allotment/search'=>"accomodation_allotment#allotment_list"
  get   "accomodation_allotment/allotment_list"=>"accomodation_allotment#allotment_list"
  get   "accomodation_allotment/allotment_list/:id"=>"accomodation_allotment#allotment_list"
  get   'accomodation_allotment/:id/deletes'=>"accomodation_allotment#destroy"
  get   'accomodation_allotment/:id/cancel'=>"accomodation_allotment#cancel"
  post  'accomodation_allotment/ajax_process'=>'accomodation_allotment#ajax_process'
  get   'accomodation_allotment/:id'=>"accomodation_allotment#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :accomodation_allotment
end

Rails.application.routes.draw do
  
  get   'holiday/add_holiday/:id'=>'holiday#add_holiday'
  get   'holiday/add_holiday'=>'holiday#add_holiday'
  post  'holiday/add_holiday'=>'holiday#add_holiday'
  
  get   'holiday/:id/deletes'=>'holiday#destroy'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :holiday
end


Rails.application.routes.draw do
  get   'manage_serial_numbers/index'=>'manage_serial_numbers#index'
  post  'manage_serial_numbers/index'=>'manage_serial_numbers#index'
  post  'manage_serial_numbers/ajax_process'=>'manage_serial_numbers#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :manage_serial_numbers
end

Rails.application.routes.draw do
  get   'sewadar_dashboard/index'=>'sewadar_dashboard#index'
  post  'sewadar_dashboard/index'=>'sewadar_dashboard#index'
  get   'sewadar_dashboard/:id'=>'sewadar_dashboard#index'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :sewadar_dashboard
end

Rails.application.routes.draw do
  get   's_dashboard/index'=>'s_dashboard#index'
  post  's_dashboard/index'=>'s_dashboard#index'
  get   's_dashboard/:id'=>'s_dashboard#index'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :s_dashboard
end

Rails.application.routes.draw do
  get   "ec_announcement/ec_announcement_refresh"
  get   "ec_announcement/add_announcement"=>"ec_announcement#add_announcement"
  post  "ec_announcement/add_announcement"=>"ec_announcement#add_announcement"
  get   "ec_announcement/add_announcement/:id"=>"ec_announcement#add_announcement"
  get   "ec_announcement/:id/cancel"=>"ec_announcement#cancel"
  get   "ec_announcement/:id/approve"=>"ec_announcement#request_approve"
  get   "ec_announcement/search"=>"ec_announcement#index"
  post  "ec_announcement/search"=>"ec_announcement#index"
  post  "ec_announcement/ajax_process"=>"ec_announcement#ajax_process"

  resources :ec_announcement
end

Rails.application.routes.draw do
  get   'user_access/index'=>'user_access#index'
  post  'user_access/index'=>'user_access#index'
  get   'user_access/:user_list'=> "user_access#user_list"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :user_access
end
Rails.application.routes.draw do
  get   'bank/index'=>'bank#index'
  post  'bank/index'=>'bank#index'
  get   'bank/add_bank'=>"bank#add_bank"
  get   'bank/add_bank/:id'=>"bank#add_bank"
  get   'bank/search'=>"bank#index"
  post  'bank/search'=>"bank#index"
  get   'bank/:id'=>"bank#index"
  get   'bank/:id/deletes'=>"bank#destroy"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :bank
end


Rails.application.routes.draw do
  get   'products/index'=>'products#index'
  post  'products/index'=>'products#index'
  get   'products/add_products'=>"products#add_products"
  get   'products/add_products/:id'=>"products#add_products"
  get   'products/search'=>"products#index"
  post  'products/search'=>"products#index"
  get   'products/:id'=>"products#index"
  get   'products/:id/deletes'=>"products#destroy"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :products
end


Rails.application.routes.draw do
  get   'medical_history/index'=>'medical_history#index'
  post  'medical_history/index'=>'medical_history#index'
  get   'medical_history/medical_list'=>"medical_history#medical_list"
  get   'medical_history/medical_list/:id'=>"medical_history#medical_list"
  get   'medical_history/search'=>"medical_history#index"
  post  'medical_history/search'=>"medical_history#index"
  get   'medical_history/:id/deletes'=>"medical_history#destroy"
  get   'medical_history/:id'=>"medical_history#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :medical_history
end

Rails.application.routes.draw do
  get   'calendar/index'=>'calendar#index'
  post  'calendar/index'=>'calendar#index'
  get   'calendar/search'=>"calendar#index"
  post  'calendar/search'=>"calendar#index"
  get   'calendar/:id/deletes'=>"calendar#destroy"
  get   'calendar/:id'=>"calendar#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :calendar
end


Rails.application.routes.draw do
  get   'university/index'=>'university#index'
  post  'university/index'=>'university#index'
  get   'university/add_university'=>"university#add_university"
  get   'university/add_university/:id'=>"university#add_university"
  get   'university/search'=>"university#index"
  post  'university/search'=>"university#index"
  get   'university/:id/deletes'=>"university#destroy"
  get   'university/:id'=>"university#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :university
end


Rails.application.routes.draw do
  get   'head_office/index'=>'head_office#index'
  post  'head_office/index'=>'head_office#index'
  get   'head_office/add_head_office'=>"head_office#add_head_office"
  get   'head_office/add_head_office/:id'=>"head_office#add_head_office"
  get   'head_office/search'=>"head_office#index"
  post  'head_office/search'=>"head_office#index"
  get   'head_office/sublocation/search'=>"head_office#index"
  post  'head_office/sublocation/search'=>"head_office#index"

  get   'head_office/:id/deletes'=>"head_office#destroy"
  get   'head_office/:id'=>"head_office#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :head_office
end

Rails.application.routes.draw do
  get   'sub_location/index'=>'sub_location#index'
  post  'sub_location/index'=>'sub_location#index'
  get   'sub_location/add_sub_location'=>"sub_location#add_sub_location"
  get   'sub_location/add_sub_location/:id'=>"sub_location#add_sub_location"
  get   'sub_location/search'=>"sub_location#index"
  post  'sub_location/search'=>"sub_location#index"
  get   'sub_location/:id/deletes'=>"sub_location#destroy"
  get   'sub_location/:id'=>"sub_location#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :sub_location
end

Rails.application.routes.draw do
  get   'accomodation/index'=>'accomodation#index'
  post  'accomodation/index'=>'accomodation#index'
  get   "accomodation/manage_accomodation"=> "accomodation#manage_accomodation"
  get   "accomodation/manage_accomodation/:id"=> "accomodation#manage_accomodation"
  get   "accomodation/:id/deletes"=> "accomodation#destroy"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :accomodation
end
Rails.application.routes.draw do
  get   'branch/index'=>'branch#index'
  post  'branch/index'=>'branch#index'
  get   'branch/add_branch'=>"branch#add_branch"
  get   'branch/add_branch/:id'=>"branch#add_branch"
  get   'branch/search'=>"branch#index"
  post  'branch/search'=>"branch#index"
  get   'branch/:id/deletes'=>"branch#destroy"
  get   'branch/:id'=>"branch#index"
  post  'branch/ajax_process'=>"branch#ajax_process"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :branch
end

Rails.application.routes.draw do
    get   'postal_directory/index'=>'postal_directory#index'
    post  'postal_directory/index'=>'postal_directory#index'
    get   'postal_directory/add_postal_directory'=>"postal_directory#add_postal_directory"
    get   'postal_directory/add_postal_directory/:id'=>"postal_directory#add_postal_directory"
    get   'postal_directory/search'=>"postal_directory#index"
    post  'postal_directory/search'=>"postal_directory#index"
    get   'postal_directory/:id/deletes'=>"postal_directory#destroy"
    get   'postal_directory/:id'=>"postal_directory#index"
    post  'postal_directory/ajax_process'=>"postal_directory#ajax_process"
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :postal_directory
  end

  Rails.application.routes.draw do
    get   'member/index'=>'member#index'
    post  'member/index'=>'member#index'
    get   'member/add_member'=>"member#add_member"
    get   'member/add_member/:id'=>"member#add_member"
    get   'member/search'=>"member#index"
    post  'member/search'=>"member#index"
    get   'member/:id/deletes'=>"member#destroy"
    get   'member/:id'=>"member#index"
    get   'member/view_logs/:id'=>"member#view_logs"
    post  'member/ajax_process'=>"member#ajax_process"
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :member
  end

  Rails.application.routes.draw do
    get   'address/index'=>'address#index'
    post  'address/index'=>'address#index'
    get   'address/add_address'=>"address#add_address"
    get   'address/add_address/:id'=>"address#add_address"
    get   'address/search'=>"address#index"
    post  'address/search'=>"address#index"
    get   'address/:id/deletes'=>"address#destroy"
    get   'address/:id'=>"address#index"
    post  'address/ajax_process'=>"address#ajax_process"
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :address
  end

  Rails.application.routes.draw do
    get   'subscription/index'=>'subscription#index'
    post  'subscription/index'=>'subscription#index'
    get   'subscription/add_subscription'=>"subscription#add_subscription"
    get   'subscription/add_subscription/:id'=>"subscription#add_subscription"
    get   'subscription/search'=>"subscription#index"
    post  'subscription/search'=>"subscription#index"
    get   'subscription/:id/deletes'=>"subscription#destroy"
    get   'subscription/:id'=>"subscription#index"
    get   'subscription/view_logs/:memid'=>"subscription#view_logs"
    get   'subscription/view_logs/:id'=>"subscription#view_logs"
    post  'subscription/ajax_process'=>"subscription#ajax_process"
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :subscription
  end

  Rails.application.routes.draw do
    get   'individual_head/index'=>'individual_head#index'
    post  'individual_head/index'=>'individual_head#index'
    get   'individual_head/add_individual_head'=>"individual_head#add_individual_head"
    get   'individual_head/add_individual_head/:id'=>"individual_head#add_individual_head"
    get   'individual_head/search'=>"individual_head#index"
    post  'individual_head/search'=>"individual_head#index"
    get   'individual_head/:id/deletes'=>"individual_head#destroy"
    get   'individual_head/:id'=>"individual_head#index"
    post  'individual_head/ajax_process'=>"individual_head#ajax_process"
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :individual_head
  end

Rails.application.routes.draw do
  get   'zone/index'=>'zone#index'
  post  'zone/index'=>'zone#index'
  get   'zone/add_zone'=>"zone#add_zone"
  get   'zone/add_zone/:id'=>"zone#add_zone"
  get   'zone/search'=>"zone#index"
  post  'zone/search'=>"zone#index"
  get   'zone/:id/deletes'=>"zone#destroy"
  get   'zone/:id'=>"zone#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :zone
end

Rails.application.routes.draw do
    get   'magazine_receipt/index'=>'magazine_receipt#index'
    post  'magazine_receipt/index'=>'magazine_receipt#index'
    get   'magazine_receipt/add_magazine_receipt'=>"magazine_receipt#add_magazine_receipt"
    get   'magazine_receipt/add_magazine_receipt/:id'=>"magazine_receipt#add_magazine_receipt"
    get   'magazine_receipt/add_magazine_receipt_by_subscription/:subid'=>"magazine_receipt#add_magazine_receipt"
    get   'magazine_receipt/search'=>"magazine_receipt#index"
    post  'magazine_receipt/search'=>"magazine_receipt#index"
    get   'magazine_receipt/:id/deletes'=>"magazine_receipt#destroy"
    get   'magazine_receipt/:id'=>"magazine_receipt#index"
    get   '/404.shtml'=>"invoice#show"
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
    #:return_ca_material
    resources :magazine_receipt
  end

Rails.application.routes.draw do
  get   'member_list/index'=>'member_list#index'
  post  'member_list/index'=>'member_list#index'
  get   'member_list/add_member'=>"member_list#add_member"
  get   'member_list/add_member/:id'=>"member_list#add_member"
  get   'member_list/search'=>"member_list#index"
  post  'member_list/search'=>"member_list#index"
  get   'member_list/:id/deletes'=>"member_list#destroy"
  get   'member_list/:id'=>"member_list#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :member_list
end
Rails.application.routes.draw do
  get   'zone_district/index'=>'zone_district#index'
  post  'zone_district/index'=>'zone_district#index'
  get   'zone_district/add_zone_district'=>"zone_district#add_zone_district"
  get   'zone_district/add_zone_district/:id'=>"zone_district#add_zone_district"
  get   'zone_district/search'=>"zone_district#index"
  post  'zone_district/search'=>"zone_district#index"
  get   'zone_district/:id/deletes'=>"zone_district#destroy"
  get   'zone_district/:id'=>"zone_district#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :zone_district
end

Rails.application.routes.draw do
  get   'create_user/index'=>'create_user#index'
  post  'create_user/index'=>'create_user#index'
  get   'create_user/user_list'=>"create_user#user_list"
  get   'create_user/user_list/search'=>"create_user#user_list"
  post  'create_user/user_list/search'=>"create_user#user_list"
  get   'create_user/:id/deletes'=>"create_user#destroy"
  get   'create_user/:id'=>"create_user#index"
  
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  #:return_ca_material
  resources :create_user
end

Rails.application.routes.draw do
  post  "manualpunch/ajax/insert_manual_punch"=>"manualpunch#index"
  get   "manage_punch/manage_punch_refresh"
  get   "manualpunch/add_manual_punch"=> "manualpunch#add_manual_punch"
  get   "manualpunch/add_manual_punch/:id"=> "manualpunch#add_manual_punch"
  get   "manage_punch/search" => "manage_punch#index"
  post  "manage_punch/search" => "manage_punch#index"
  get   "manage_punch/:id/deletes" => "manage_punch#destroy"
  resources :manualpunch
end

Rails.application.routes.draw do
  get   'loans_advance/refresh_loans_advance'    
  get   'loans_advance/index'=>'loans_advance#index'
  post  'loans_advance/index'=>'loans_advance#index'
  get   'loans_advance/search'=>"loans_advance#loans_advance_list"
  post  'loans_advance/search'=>"loans_advance#loans_advance_list"
  post  'loans_advance/ajax_process'=>'loans_advance#ajax_process'
  get   'loans_advance/:id/cancel'=>"loans_advance#cancel"
  get   'loans_advance/loans_advance_list'=>"loans_advance#loans_advance_list"
  get   'loans_advance/:id'=>"loans_advance#index"
  

  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"  
  resources :loans_advance
end

Rails.application.routes.draw do
  get   'loans_approval/index'=>'loans_approval#index'
  post  'loans_approval/index'=>'loans_approval#index'
  get   'loans_approval/search'=>"loans_approval#index"
  post  'loans_approval/search'=>"loans_approval#index"
  get   'loans_approval/:id/deletes'=>"loans_approval#destroy"
  get   'loans_approval/:id'=>"loans_approval#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :loans_approval
end




Rails.application.routes.draw do
  get   'hr_parameters/index'=>'hr_parameters#index'
  post  'hr_parameters/index'=>'hr_parameters#index'
  get   'hr_parameters/search'=>"hr_parameters#user_list"
  post  'hr_parameters/search'=>"hr_parameters#user_list"
  get   'hr_parameters/:id/deletes'=>"hr_parameters#destroy"
  post  'hr_parameters/ajax_process'=>'hr_parameters#ajax_process'
  get   'hr_parameters/:id'=>"hr_parameters#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :hr_parameters
end

Rails.application.routes.draw do
  get   'vouchers/index'=>'vouchers#index'
  post  'vouchers/index'=>'vouchers#index'
  get   'vouchers/search'=>"vouchers#index"
  post  'vouchers/search'=>"vouchers#index"
  get   "vouchers/generate_vouchers"=>"vouchers#generate_vouchers"
  get   "vouchers/generate_vouchers/:id"=>"vouchers#generate_vouchers"
  get   'vouchers/:id/deletes'=>"vouchers#destroy"
  get   'vouchers/:id/cancel'=>"vouchers#cancel"
  post  'vouchers/ajax_process'=>'vouchers#ajax_process' 
  get   'vouchers/:id'=>"vouchers#index"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :vouchers
end

Rails.application.routes.draw do
  get   'electric_consumption/refresh_electric_consumption'
  get   'electric_consumption/search'=>"electric_consumption#consumption_list"
  post  'electric_consumption/search'=>"electric_consumption#consumption_list"
  get   "electric_consumption/consumption_list"=>"electric_consumption#consumption_list"
  get   'electric_consumption/:id'=>"electric_consumption#index"
  get   'electric_consumption/:id/deletes'=>"electric_consumption#destroy"
  get   'electric_consumption/:id/cancel'=>"electric_consumption#cancel"  
  post  'electric_consumption/ajax_process'=>'electric_consumption#ajax_process'
 
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :electric_consumption
end

Rails.application.routes.draw do

  get   'monthly_advice/search'=>"monthly_advice#index"
  post  'monthly_advice/search'=>"monthly_advice#index" 
  get   'monthly_advice/:id'=>"monthly_advice#index"
  get   'monthly_advice/:id/deletes'=>"monthly_advice#destroy"
  get   'monthly_advice/:id/cancel'=>"monthly_advice#cancel"
  post  'monthly_advice/ajax_process'=>'monthly_advice#ajax_process'

  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :monthly_advice
end

Rails.application.routes.draw do

  get   'monthly_import/search'=>"monthly_import#index"
  post  'monthly_import/search'=>"monthly_import#index" 
  get   'monthly_import/:id'=>"monthly_import#index"
  get   'monthly_import/:id/deletes'=>"monthly_import#destroy"
  get   'monthly_import/:id/cancel'=>"monthly_import#cancel"
  post  'monthly_import/ajax_process'=>'monthly_import#ajax_process'

  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :monthly_import
end

Rails.application.routes.draw do

  get   'calculate_salary/search'=>"calculate_salary#index"
  post  'calculate_salary/search'=>"calculate_salary#index"
  get   'calculate_salary/:id'=>"calculate_salary#index"
  get   'calculate_salary/:id/deletes'=>"calculate_salary#destroy"
  get   'calculate_salary/:id/cancel'=>"calculate_salary#cancel"
  post  'calculate_salary/ajax_process'=>'calculate_salary#ajax_process'

  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :calculate_salary
end

Rails.application.routes.draw do

  get   'month_end_process/search'=>"month_end_process#index"
  post  'month_end_process/search'=>"month_end_process#index"
  get   'month_end_process/:id'=>"month_end_process#index"
  get   'month_end_process/:id/deletes'=>"month_end_process#destroy"
  get   'month_end_process/:id/cancel'=>"month_end_process#cancel"
  post  'month_end_process/ajax_process'=>'month_end_process#ajax_process'

  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :month_end_process
end

Rails.application.routes.draw do
    
  get   'reports/salary_register'=>"reports#salary_register"
  get   'reports/salary_slip'=>"reports#salary_slip"
  get   'reports/monthly_deduction'=>"reports#monthly_deduction"
  get   'reports/allowances'=>"reports#allowances"
  get   'reports/personal_details'=>"reports#personal_details"
  get   'reports/yearly_report'=>"reports#yearly_report"
  get   'reports/monthly_report'=>"reports#monthly_report"
  get   'reports/daily_report'=>"reports#daily_report"
  post  'reports/ajax_process'=>'reports#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :reports
end
Rails.application.routes.draw do
  get   "daily_dashboard/daily_dashboard_refresh" 
  get   "daily_dashboard/search"=>"daily_dashboard#index"
  post  "daily_dashboard/search"=>"daily_dashboard#index"
  post  "daily_dashboard/ajax"=>"daily_dashboard#index" 
  resources :daily_dashboard

end
Rails.application.routes.draw do
  get   "daily_calculation/daily_calculation_refresh"
  post  "daily_calculation/ajax_process"=>"daily_calculation#ajax_process"
  get   "daily_calculation/:id"=>"daily_calculation#index"
  get   "report/my_customer_refresh"
  resources :daily_calculation
end
 Rails.application.routes.draw do
    get   "monthly_performance/monthly_performance_refresh" 
    get   "monthly_performance/:id"=>"monthly_performance#index"
    post  "monthly_performance/:id"=>"monthly_performance#index"  
    get   "monthly_performance/search"=>"monthly_performance#index"
    post  "monthly_performance/search"=>"monthly_performance#index"
   
    resources :monthly_performance
  end
Rails.application.routes.draw do

  get   'views/monthly_deduction'=>"views#monthly_deduction"
  post  'views/ajax_process'=>'views#ajax_process'
  get   'views/birthday_list'=>"views#birthday_list"
  get   'views/birthday_list/search'=>"views#birthday_list"
  post  'views/birthday_list/search'=>"views#birthday_list"
  get   'views/sewadar_cards'=>"views#sewadar_cards"
  get   'views/sewadar_cards/search'=>"views#sewadar_cards"
  post  'views/sewadar_cards/search'=>"views#sewadar_cards"
  get   "views/deductions_list"=>"views#deductions_list"
  post  "views/deductions_list"=>"views#deductions_list"
  get   "views/deductions_list/search"=>"views#deductions_list"
  post  "views/deductions_list/search"=>"views#deductions_list"
  get   "views/deductions_list/:id"=>"views#deductions_list"
  get   "views/deductions_list/:id/cancel"=>"views#cancel"  
  post  "views/deductions_list/ajax_process"=>"views#ajax_process"
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :views
end

Rails.application.routes.draw do

  post  'education_parameter/ajax_process'=>'education_parameter#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :education_parameter
end
Rails.application.routes.draw do

  post  'marriage_parameter/ajax_process'=>'marriage_parameter#ajax_process'
  get   '/404.shtml'=>"invoice#show"
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :marriage_parameter
end

Rails.application.routes.draw do

  get   "leave/apply_leave"=>"leave#apply_leave"
  post  "leave/apply_leave"=>"leave#apply_leave"
  get   "leave/apply_leave/:id"=>"leave#apply_leave"
  get   "leave/:id/cancel"=>"leave#cancel"
  get   "leave/:id/approve"=>"leave#request_approve"

  get   "leave/search"=>"leave#index"
  post  "leave/search"=>"leave#index"
  post  "leave/ajax_process"=>"leave#ajax_process"


  get   "leaves/search"=>"leaves#index"
  post  "leaves/search"=>"leaves#index"
  get   "leave/leave_new_refresh"
  post  "leave/ajax/add_leave_details"=>"leave#index"
  resources :leave
end

Rails.application.routes.draw do
  get   "accounts/accounts_refresh" 
  get   "accounts/tds_reports"=>"accounts#tds_reports"
  get   "accounts/tds_entry"=>"accounts#tds_entry"
  post  "accounts/tds_entry"=>"accounts#tds_entry"
  get   "accounts/:id"=>"accounts#index"
  get   "accounts/tds_entry/:id"=>"accounts#tds_entry"
  get   "accounts/:id/cancel"=>"accounts#cancel"
  get   "accounts/:id/tds_entry"=>"accounts#tds_entry"
  
  

  get   "accounts/search"=>"accounts#index"
  post  "accounts/search"=>"accounts#index"
  post  "accounts/ajax_process"=>"accounts#ajax_process"
  resources :accounts
end

Rails.application.routes.draw do

  get   "generate_requisition/requisition_list"=>"generate_requisition#requisition_list"
  post  "generate_requisition/requisition_list"=>"generate_requisition#requisition_list"
  get   "generate_requisition/requisition_list/:id"=>"generate_requisition#requisition_list"
  get   "generate_requisition/:id/cancel"=>"generate_requisition#cancel"
  get   "generate_requisition/:id/requisition_list"=>"generate_requisition#requisition_list"
  get   "generate_requisition/tds_reports"=>"generate_requisition#tds_reports"
  

  get   "generate_requisition/search"=>"generate_requisition#index"
  post  "generate_requisition/search"=>"generate_requisition#index"
  post  "generate_requisition/ajax_process"=>"generate_requisition#ajax_process"
  resources :generate_requisition
end

Rails.application.routes.draw do

  get   "electric_report/electric_report_refresh"  
  post  "electric_report/ajax_process"=>"electric_report#ajax_process"
  get   "electric_report/:id"=>"electric_report#index"
  post  "electric_report/:id"=>"electric_report#index"  
  get   "electric_report/search"=>"electric_report#index"
  post  "electric_report/search"=>"electric_report#index"
 
  resources :electric_report
end

Rails.application.routes.draw do
  get   "leave_details/leave_details_new_refresh"  
  get   "leave_details/search"=>"leave_details#index"
  post  "leave_details/search"=>"leave_details#index"
  post  "leave/ajax/add_leave_details"=>"leave#index"
 
  resources :leave_details
end
Rails.application.routes.draw do

  get   "request_co_od/apply_co_od"=>"request_co_od#apply_co_od"
  post  "request_co_od/apply_co_od"=>"request_co_od#apply_co_od"
  get   "request_co_od/apply_co_od/:id"=>"request_co_od#apply_co_od"
  get   "request_co_od/:id/cancel"=>"request_co_od#cancel"
  get   "request_co_od/:id/approve"=>"request_co_od#request_approve"

  get   "request_co_od/search"=>"request_co_od#index"
  post  "request_co_od/search"=>"request_co_od#index"
  post  "request_co_od/ajax_process"=>"request_co_od#ajax_process"


  get   "request_co_od/search"=>"request_co_od#index"
  post  "request_co_od/search"=>"request_co_od#index"
  get   "request_co_od/request_co_od_new_refresh"
  post  "request_co_od/ajax/add_request_co_od_details"=>"request_co_od#index"
  resources :request_co_od
end


Rails.application.routes.draw do
  get   "co_od/apply_co_od"
  get   "co_od/apply_co_od"=>"co_od#apply_co_od"
  post  "co_od/apply_co_od"=>"co_od#apply_co_od"
  get   "co_od/apply_co_od/:id"=>"co_od#apply_co_od"
  get   "co_od/:id/cancel"=>"co_od#cancel"
  get   "co_od/:id/approve"=>"co_od#request_approve"

  get   "co_od/search"=>"co_od#index"
  post  "co_od/search"=>"co_od#index"
  post  "co_od/ajax_process"=>"co_od#ajax_process"


  get   "co_od/search"=>"co_od#index"
  post  "co_od/search"=>"co_od#index"
  get   "co_od/co_od_new_refresh"
  post  "co_od/ajax/add_request_co_od_details"=>"co_od#index"
  resources :co_od
end

Rails.application.routes.draw do

  get   "electric_report/electric_report_refresh"  
  post  "electric_report/ajax_process"=>"electric_report#ajax_process"
  get   "electric_report/:id"=>"electric_report#index"
  post  "electric_report/:id"=>"electric_report#index"  
  get   "electric_report/search"=>"electric_report#index"
  post  "electric_report/search"=>"electric_report#index"
 
  resources :electric_report
end
Rails.application.routes.draw do

  get   'ledger_report/search'=>"ledger_report#index"
  post  'ledger_report/search'=>"ledger_report#index"
  get   'ledger_report/:id'=>"ledger_report#show"
  get   'ledger_report/:id/deletes'=>"ledger_report#destroy"
  get   'ledger_report/:id/cancel'=>"ledger_report#cancel"
  post  'ledger_report/ajax_process'=>'ledger_report#ajax_process'

  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :ledger_report
end

Rails.application.routes.draw do
  get   "change_password/change_password_refresh" 
  get   "change_password/:id"=>"change_password#index"
  post  "change_password/:id"=>"change_password#index"  
  get   "change_password/search"=>"change_password#index"
  post  "change_password/search"=>"change_password#index"
  resources :change_password
end

Rails.application.routes.draw do

  get   'super_annuation/search'=>"super_annuation#index"
  post  'super_annuation/search'=>"super_annuation#index"
  get   'super_annuation/:id'=>"super_annuation#show"
  get   'super_annuation/:id/deletes'=>"super_annuation#destroy"
  get   'super_annuation/:id/cancel'=>"super_annuation#cancel"
  post  'super_annuation/ajax_process'=>'super_annuation#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :super_annuation
end

Rails.application.routes.draw do
  get   'full_final/add_fullfinal'=>"full_final#add_fullfinal"
  get   'full_final/add_fullfinal/:id'=>"full_final#add_fullfinal"
  get   'full_final/search'=>"full_final#index"
  post  'full_final/search'=>"full_final#index"
  get   'full_final/:id'=>"full_final#show"
  get   'full_final/:id/deletes'=>"full_final#destroy"
  get   'full_final/:id/cancel'=>"full_final#cancel"
  post  'full_final/ajax_process'=>'full_final#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :full_final
end

Rails.application.routes.draw do

  get   'all_formats/search'=>"all_formats#index"
  post  'ledger_report/search'=>"all_formats#index"
  get   'all_formats/:id'=>"all_formats#show"
  get   'all_formats/:id/deletes'=>"all_formats#destroy"
  get   'all_formats/:id/cancel'=>"all_formats#cancel"
  post  'all_formats/ajax_process'=>'all_formats#ajax_process'
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :all_formats
end


Rails.application.routes.draw do
  get   "apply_marriageaid/marriageaid_list"=>"apply_marriageaid#marriageaid_list" 
  post  "apply_marriageaid/marriageaid_list"=>"apply_marriageaid#marriageaid_list" 
  get   "apply_marriageaid/marriageaid_list/:id"=>"apply_marriageaid#marriageaid_list" 
  get   'apply_marriageaid/search'=>"apply_marriageaid#marriageaid_list"
  post  'apply_marriageaid/search'=>"apply_marriageaid#marriageaid_list"
  get   'apply_marriageaid/:id'=>"apply_marriageaid#index"
  get   'apply_marriageaid/:id/deletes'=>"apply_marriageaid#destroy"
  get   'apply_marriageaid/:id/cancel'=>"apply_marriageaid#cancel"
  post  'apply_marriageaid/ajax_process'=>'apply_marriageaid#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :apply_marriageaid
end

Rails.application.routes.draw do
  get   "apply_educationaid/educationaid_list"=>"apply_educationaid#educationaid_list"
  post  "apply_educationaid/educationaid_list"=>"apply_educationaid#educationaid_list"
  get   "apply_educationaid/educationaid_list/:id"=>"apply_educationaid#educationaid_list"
  get   'apply_educationaid/search'=>"apply_educationaid#educationaid_list"
  post  'apply_educationaid/search'=>"apply_educationaid#educationaid_list"
  get   'apply_educationaid/:id'=>"apply_educationaid#index"
  get   'apply_educationaid/:id/deletes'=>"apply_educationaid#destroy"
  get   'apply_educationaid/:id/cancel'=>"apply_educationaid#cancel"
  post  'apply_educationaid/ajax_process'=>'apply_educationaid#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :apply_educationaid
end

Rails.application.routes.draw do
 
  get   "postal/dispatch_entry"=>"postal#dispatch_entry"
  get   "postal/dispatch_entry/:id"=>"postal#dispatch_entry"  
  get   'postal/search'=>"postal#index"
  post  'postal/search'=>"postal#index"
  get   'postal/:id'=>"apply_educationaid#show"
  get   'postal/:id/deletes'=>"postal#destroy"
  get   'postal/:id/cancel'=>"postal#cancel"
  post  'postal/ajax_process'=>'postal#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :postal
end

Rails.application.routes.draw do
 
  get   "postal_receive/postal_receive_entry"=>"postal_receive#postal_receive_entry"
  get   "postal_receive/postal_receive_entry/:id"=>"postal_receive#postal_receive_entry"  
  get   'postal_receive/search'=>"postal_receive#index"
  post  'postal_receive/search'=>"postal_receive#index"
  get   'postal_receive/:id'=>"postal_receive#show"
  get   'postal_receive/:id/deletes'=>"postal_receive#destroy"
  get   'postal_receive/:id/cancel'=>"postal_receive#cancel"
  post  'postal_receive/ajax_process'=>'postal_receive#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :postal_receive
end

Rails.application.routes.draw do
  get   "transactions/add_transaction"=>"transactions#add_transaction"
  get   "transactions/search" => "transactions#index"
  post  "transactions/search" => "transactions#index"  
  get   'transactions/:id'=>"transactions#show"
  get   'transactions/:id/deletes'=>"transactions#destroy"
  get   'transactions/:id/cancel'=>"transactions#cancel"
  post  'transactions/ajax_process'=>'transactions#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :transactions
end

Rails.application.routes.draw do 
  get   "marriageaid_approval/search" => "marriageaid_approval#index"
  post  "marriageaid_approval/search" => "marriageaid_approval#index"  
  get   'marriageaid_approval/:id'=>"marriageaid_approval#show"  
  post  'marriageaid_approval/ajax_process'=>'marriageaid_approval#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :marriageaid_approval
end

Rails.application.routes.draw do 
  get   "educationaid_approval/search" => "educationaid_approval#index"
  post  "educationaid_approval/search" => "educationaid_approval#index"  
  get   'educationaid_approval/:id'=>"educationaid_approval#show"  
  post  'educationaid_approval/ajax_process'=>'educationaid_approval#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :educationaid_approval
end

Rails.application.routes.draw do
  get   "advance_detail/advance_detail_new_refresh"  
  get   "advance_detail/search"=>"advance_detail#index"
  post  "advance_detail/search"=>"advance_detail#index"
  post  "advance_detail/ajax/add_advance_detail"=>"advance_detail#index" 
  resources :advance_detail

end

Rails.application.routes.draw do 
    get   "process_machine_data/search" => "process_machine_data#index"
    post  "process_machine_data/search" => "process_machine_data#index"  
    get   'process_machine_data/:id'=>"process_machine_data#show"  
    post  'process_machine_data/ajax_process'=>'process_machine_data#ajax_process'  
    get   "/404" ,:to =>"erros#not_found"
    get   "/422" ,:to =>"erros#not_found"
    get   "/500" ,:to =>"erros#unacceptable"
  resources :process_machine_data
end

Rails.application.routes.draw do
  get   "raw_punch/raw_punch_new_refresh"  
  get   "raw_punch/search"=>"raw_punch#index"
  post  "raw_punch/search"=>"raw_punch#index"
  post  "raw_punch/ajax"=>"raw_punch#index" 
  resources :raw_punch

end


Rails.application.routes.draw do
  get   "daily_dashboard/daily_dashboard_refresh" 
  get   "daily_dashboard/search"=>"daily_dashboard#index"
  post  "daily_dashboard/search"=>"daily_dashboard#index"
  post  "daily_dashboard/ajax"=>"daily_dashboard#index" 
  resources :daily_dashboard

end

Rails.application.routes.draw do
    get   "monthly_performance/monthly_performance_refresh" 
    get   "monthly_performance/:id"=>"monthly_performance#index"
    post  "monthly_performance/:id"=>"monthly_performance#index"  
    get   "monthly_performance/search"=>"monthly_performance#index"
    post  "monthly_performance/search"=>"monthly_performance#index"   
    resources :monthly_performance
  end

Rails.application.routes.draw do
  get   "education_report/education_report_refresh"  
  get   "education_report/search"=>"education_report#index"
  post  "education_report/search"=>"education_report#index"
  post  "education_report/ajax"=>"education_report#index" 
  resources :education_report

end





Rails.application.routes.draw do
  get   "process_update_installment/add_installment"=>"process_update_installment#add_installment"
  get   "process_update_installment/search" => "process_update_installment#index"
  post  "process_update_installment/search" => "process_update_installment#index"  
  get   'process_update_installment/:id'=>"process_update_installment#show"
  post  'process_update_installment/ajax_process'=>'process_update_installment#ajax_process'  
  get   'process_update_installment/:id/deletes'=>"process_update_installment#destroy"
  get   'process_update_installment/:id/cancel'=>"process_update_installment#cancel"
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :process_update_installment
end

Rails.application.routes.draw do   
  get  'forget_password/index'
  
  get   "dailyattendance/attendance_summary"=>"dailyattendance#attendance_summary"
  get   "attendance/leave" => "attendance#index"
  get   "attendance/shift" => "attendance#shift"
  post  "attendance/save_master_leave" => "attendance#save_master_leave"
  post  "attendance/save_master_shift_leave" => "attendance#save_master_shift_leave"
  get   "attendance/leave/:id/deletes" => "attendance#destroy"
  get   "attendance/leave/:id" => "attendance#index"
  patch "attendance/:id/edit" => "attendance#edit"
  get   "attendance/shift" => "attendance#shift"
  post  "attendance/shift" => "attendance#shift"
  get   "attendance/shift_list"=> "attendance#shift_list"
  get   "attendance/leave_list"=> "attendance#leave_list"
  get   "attendance/shift/:id" => "attendance#shift"
  post  "attendance/shift/:id" => "attendance#shift"
  get   "attendance/shift/:id/deletes" => "attendance#deletes"
#   get   "generate_requisition/requisition_list"=>"generate_requisition#requisition_list"
  post  "employee/ajax/process_action_module"=>"employee#index"
  get   "sewadar_reports/search"=>"sewadar_reports#index"
  post  "sewadar_reports/search"=>"sewadar_reports#index"  
  
  
  
  post  "material_issue/ajax_process"=>"material_issue#ajax_process"
  get   "discipline/add_discipline"=>"discipline#add_discipline"
  post  "discipline/add_discipline"=>"discipline#add_discipline"
  get   "discipline/search" => "discipline#index"
  post  "discipline/search" => "discipline#index"
 
#   get   "generate_requisition/requisition_list"=>"generate_requisition#requisition_list"
   resources :customer,:o_dashboard,:discipline,:material_issue,:stationary_vouchers,:stationary_approval,:sewadar_reports,:category,:dataimports,:attendance,:leaves,:sewadar_leaves,:sewadar_attendance,:hr_dashboard,:employee,:forget_password
  
end

Rails.application.routes.draw do
    
  get   'attendance_summary/search'=>"attendance_summary#index"
  post  'attendance_summary/search'=>"attendance_summary#index" 
  post  'attendance_summary/ajax_process'=>'attendance_summary#ajax_process'
  get   'attendance_summary/:id'=>"attendance_summary#index"

  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :attendance_summary
end


Rails.application.routes.draw do
  get   "employee_attendance/employee_attendance_refresh"
  get   "employee_attendance/search" => "employee_attendance#index"
  post  "employee_attendance/search" => "employee_attendance#index"
  resources :employee_attendance
end


Rails.application.routes.draw do
  get   "advance_adjustment/add_installment"=>"advance_adjustment#add_installment"
  get   "advance_adjustment/search" => "advance_adjustment#index"
  post  "advance_adjustment/search" => "advance_adjustment#index"  
  get   'advance_adjustment/:id'=>"advance_adjustment#show"
  post  'advance_adjustment/ajax_process'=>'advance_adjustment#ajax_process'  
  get   'advance_adjustment/:id/deletes'=>"advance_adjustment#destroy"
  get   'advance_adjustment/:id/cancel'=>"advance_adjustment#cancel"
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :advance_adjustment
end

Rails.application.routes.draw do

  get   'periodicreport/search'=>"periodicreport#index"
  post  'periodicreport/search'=>"periodicreport#index"
  get   'periodicreport/:id'=>"periodicreport#show"
  get   'periodicreport/:id/deletes'=>"periodicreport#destroy"
  get   'periodicreport/:id/cancel'=>"periodicreport#cancel"
  post  'periodicreport/ajax_process'=>'periodicreport#ajax_process'
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :periodicreport
end

Rails.application.routes.draw do
  get   'samagam_bakshis/search'=>"samagam_bakshis#index"
  post  'samagam_bakshis/search'=>"samagam_bakshis#index"
  get   'samagam_bakshis/:id'=>"samagam_bakshis#show"
  get   'samagam_bakshis/:id/deletes'=>"samagam_bakshis#destroy"
  get   'samagam_bakshis/:id/cancel'=>"samagam_bakshis#cancel"
  post  'samagam_bakshis/ajax_process'=>'samagam_bakshis#ajax_process'  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :samagam_bakshis
end

Rails.application.routes.draw do
  get   'leave_credit_process/search'=>"leave_credit_process#index"
  post  'leave_credit_process/search'=>"leave_credit_process#index"
  get   'leave_credit_process/:id'=>"leave_credit_process#show"
  get   'leave_credit_process/:id/deletes'=>"leave_credit_process#destroy"
  get   'leave_credit_process/:id/cancel'=>"leave_credit_process#cancel"
  post  'leave_credit_process/ajax_process'=>'leave_credit_process#ajax_process' 
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :leave_credit_process
end

Rails.application.routes.draw do

  get   'facilities_list/search'=>"facilities_list#index"
  post  'facilities_list/search'=>"facilities_list#index"
  get   'facilities_list/:id'=>"facilities_list#show"
  get   'facilities_list/:id/deletes'=>"facilities_list#destroy"
  get   'facilities_list/:id/cancel'=>"facilities_list#cancel"
  post  'facilities_list/ajax_process'=>'facilities_list#ajax_process'
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :facilities_list
end
Rails.application.routes.draw do
  get   "new_dashboard/new_dashboard_refresh" 
  get   "new_dashboard/search"=>"new_dashboard#index"
  post  "new_dashboard/search"=>"new_dashboard#index"
  post  "new_dashboard/ajax_process"=>"new_dashboard#ajax_process" 
  resources :new_dashboard

end

Rails.application.routes.draw do

  get   'exgratia_register/search'=>"exgratia_register#index"
  post  'exgratia_register/search'=>"exgratia_register#index"
  get   'exgratia_register/:id'=>"exgratia_register#show"
  get   'exgratia_register/:id/deletes'=>"exgratia_register#destroy"
  get   'exgratia_register/:id/cancel'=>"exgratia_register#cancel"
  post  'exgratia_register/ajax_process'=>'exgratia_register#ajax_process'
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :exgratia_register
end

Rails.application.routes.draw do 
  get   'leave_summary/search'=>"leave_summary#index"
  post  'leave_summary/search'=>"leave_summary#index"
  get   'leave_summary/:id'=>"leave_summary#show"
  get   'leave_summary/:id/deletes'=>"leave_summary#destroy"
  get   'leave_summary/:id/cancel'=>"leave_summary#cancel"
  post  'leave_summary/ajax_process'=>'leave_summary#ajax_process'

  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :leave_summary
end

Rails.application.routes.draw do
  get   "sewadar_ma_view/sewadar_ma_view_new_refresh"  
  get   "sewadar_ma_view/search"=>"sewadar_ma_view#index"
  post  "sewadar_ma_view/search"=>"sewadar_ma_view#index"
  resources :sewadar_ma_view

end

Rails.application.routes.draw do

  get   'advance_report/search'=>"advance_report#index"
  post  'advance_report/search'=>"advance_report#index"
  get   'advance_report/:id'=>"advance_report#show"
  get   'advance_report/:id/deletes'=>"advance_report#destroy"
  get   'advance_report/:id/cancel'=>"advance_report#cancel"
  post  'advance_report/ajax_process'=>'advance_report#ajax_process'
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :advance_report
end

Rails.application.routes.draw do

  get   'summary_reports/search'=>"summary_reports#index"
  post  'summary_reports/search'=>"summary_reports#index"
  get   'summary_reports/:id'=>"summary_reports#show"
  get   'summary_reports/:id/deletes'=>"summary_reports#destroy"
  get   'summary_reports/:id/cancel'=>"summary_reports#cancel"
  post  'summary_reports/ajax_process'=>'summary_reports#ajax_process'
  
  get   "/404" ,:to =>"erros#not_found"
  get   "/422" ,:to =>"erros#not_found"
  get   "/500" ,:to =>"erros#unacceptable"
  resources :summary_reports
end
Rails.application.routes.draw do
  get   "leave_summary_mi/leave_summary_mi_new_refresh"  
  get   "leave_summary_mi/search"=>"leave_summary_mi#index"
  post  "leave_summary_mi/search"=>"leave_summary_mi#index" 
  resources :leave_summary_mi

end


