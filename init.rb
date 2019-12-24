Redmine::Plugin.register :redmine_request_change_deadline do
  name 'Redmine Request Change Deadline plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'

  module RedmineRequestChangeDeadline
    class Hooks < Redmine::Hook::ViewListener
      render_on :view_issues_context_menu_end, :partial => 'issues/hooks/view_issues_context_menu_end'
    end

    module ContextMenusControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def requests
          if (@requests.size == 1)
            @request = @requests.first
          end
          @request_ids = @requests.map(&:id).sort
          render :layout => false
        end
      end
    end
  end

  menu :admin_menu, :request_change_deadline, {:controller => 'change_deadlines', :action => 'index' },
       :caption => 'Requests to change deadline', html: {class: 'icon icon-list'}

  project_module :deadline_change do
    permission :view_deadline_request, :change_deadlines => :show
    permission :edit_deadline_request, :change_deadlines => :edit
    permission :delete_deadline_request, :change_deadlines => :destroy
    permission :approve_deadline_request, :change_deadlines => :approve_request
    permission :reject_deadline_request, :change_deadlines => :reject_request
    permission :create_deadline_request, :change_deadlines => :create
  end

  #permission :approve_requests, :change_deadlines => :approve_request
  #permission :reject_requests, :change_deadlines => :reject_request

  settings :default => {'empty' => true}, :partial => 'settings/request_settings'
end

Rails.application.config.to_prepare do
  QueriesController.send(:include, RedmineRequestChangeDeadline::QueriesControllerPatch)
    #ContextMenusController.send(:include, RedmineRequestChangeDeadline::ContextMenusControllerPatch)
end


