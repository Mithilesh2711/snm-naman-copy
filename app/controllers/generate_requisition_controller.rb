class GenerateRequisitionController < ApplicationController
	before_action :require_login
	before_action :allowed_security
	skip_before_action :verify_authenticity_token,:only=>[:index,:ajax_process,:search]
	 helper_method :get_department_detail,:total_all_counts
	def requisition_list
		
	end
end
