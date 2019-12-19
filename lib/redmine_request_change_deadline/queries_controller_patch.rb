require_dependency 'queries_controller'

module RedmineRequestChangeDeadline
  module QueriesControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def redirect_to_request_change_deadline_query(options)
        redirect_to change_deadlines_path
      end
    end
  end
end
