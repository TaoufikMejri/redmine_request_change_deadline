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
  end

  permission :approve_requests, :change_deadlines => :approve_request
  permission :reject_requests, :change_deadlines => :reject_request

  settings :default => {'empty' => true}, :partial => 'settings/request_settings'
end

Rails.application.config.to_prepare do
  QueriesController.send(:include, RedmineRequestChangeDeadline::QueriesControllerPatch)
end
