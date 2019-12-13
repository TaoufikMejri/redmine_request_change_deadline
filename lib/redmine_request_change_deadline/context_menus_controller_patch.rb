require_dependency 'context_menus_controller'

module RedmineRequestChangeDeadline
  module ContextMenusControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def requests
        @requests = RequestChangeDeadline.
                    where(:id => (params[:id] || params[:ids])).to_a
        if (@requests.size == 1)
          @request = @requests.first
        end
        @request_ids = @requests.map(&:id).sort
        render :layout => false
      end
    end
  end
end

ContextMenusController.send(:include, RedmineRequestChangeDeadline::ContextMenusControllerPatch)