class ChangeDeadlinesController < ApplicationController

  helper :queries
  include QueriesHelper
  include ChangeDeadlinesHelper
  helper :change_deadlines

  before_action :find_request, only: [:edit, :update, :show, :destroy, :approve_request, :reject_request]

  def new
    @request = RequestChangeDeadline.new
    @issue_ids = params[:issue_ids]
    @issues = Issue.find @issue_ids
  end

  def create
    @issue_ids = params[:issue_ids]
    @issues = Issue.find(@issue_ids)
    @issues.each do |issue|
      @request = RequestChangeDeadline.new
      @request.safe_attributes = request_params
      @request.user_id = User.current.id
      @request.issue_id = issue.id
      @request.project_id = issue.project_id
      @cf_setting = Setting.plugin_redmine_request_change_deadline['custom_field']
      @cfv = issue.custom_values.detect { |cv|
        cv.custom_field_id == @cf_setting.first.to_i
      }
      @request.old_deadline = @cfv.value if @cfv
      @request.save
    end
    RequestMailer.deliver_request_add(User.admin.first, @request, @issues)
    redirect_to change_deadlines_path
  end

  def index
    retrieve_request_change_deadline_query
    if @query.valid?
      @requests_count = @query.requests_count
      @request_pages = Paginator.new @requests_count, per_page_option, params['page']
      @requests = @query.requests(:offset => @request_pages.offset, :limit => @request_pages.per_page)
    end
  end

  def edit
  end

  def update
    @request.safe_attributes = request_params
    @request.approved_by_id = User.current.id
    @request.save
    redirect_to change_deadlines_path
  end

  def show
  end

  def destroy
    @request.destroy
    redirect_to change_deadlines_path
  end

  def approve_request
    @request.status = 1
    @request.approved_by_id = User.current.id
    @issue = Issue.find(@request.issue_id)
    @cf_setting = Setting.plugin_redmine_request_change_deadline['custom_field']
    @cfv = @issue.custom_values.detect { |cv|
      cv.custom_field_id == @cf_setting.first.to_i
    }
    if @cfv
      @cfv.value = @request.new_deadline
      @cfv.save
      @request.save
    end
    redirect_to change_deadlines_path
  end

  def reject_request
    @request.status = 2
    @request.save
    redirect_to change_deadlines_path
  end

  private

  def request_params
    params.require(:request_change_deadline).permit!
  end

  def find_request
    @request = RequestChangeDeadline.find params[:id]
  end

  def retrieve_request_change_deadline_query
    request_retrieve_query(RequestChangeDeadlineQuery, false, :defaults => @default_columns_names)
  end
  
end
