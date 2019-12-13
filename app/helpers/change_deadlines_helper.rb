module ChangeDeadlinesHelper

  include QueriesHelper
  include ApplicationHelper

  def request_retrieve_query(klass, use_session=true, options={})
    session_key = klass.name.underscore.to_sym

    if params[:query_id].present?
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = klass.where(cond).find(params[:query_id])
      raise ::Unauthorized unless @query.visible?
      @query.project = @project
      session[session_key] = {:id => @query.id, :project_id => @query.project_id} if use_session
    elsif api_request? || params[:set_filter] || !use_session || session[session_key].nil? || session[session_key][:project_id] != (@project ? @project.id : nil)
      # Give it a name, required to be valid
      @query = klass.new(:name => "_", :project => @project)
      @query.build_from_params(params, options[:defaults])
      session[session_key] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names, :totalable_names => @query.totalable_names, :sort => @query.sort_criteria.to_a} if use_session
    else
      # retrieve from session
      @query = nil
      @query = klass.find_by_id(session[session_key][:id]) if session[session_key][:id]
      @query ||= klass.new(:name => "_", :filters => session[session_key][:filters], :group_by => session[session_key][:group_by], :column_names => session[session_key][:column_names], :totalable_names => session[session_key][:totalable_names], :sort_criteria => session[session_key][:sort])
      @query.project = @project
    end
    if params[:sort].present?
      @query.sort_criteria = params[:sort]
      if use_session
        session[session_key] ||= {}
        session[session_key][:sort] = @query.sort_criteria.to_a
      end
    end
    @query
  end

  def grouped_request_list(requests, query, &block)
    ancestors = []
    grouped_query_results(requests, query) do |request, group_name, group_count, group_totals|
      yield request, ancestors.size, group_name, group_count, group_totals
      ancestors << request
    end
  end

  def requests_destroy_confirmation_message(requests)
    requests = [requests] unless requests.is_a?(Array)
    message = "Êtes-vous sûr de vouloir supprimer la ou les demandes(s) selectionnée(s) ?"
  end
end
