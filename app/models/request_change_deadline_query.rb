class RequestChangeDeadlineQuery < Query
  self.queried_class = RequestChangeDeadline

  self.available_columns = [
      QueryColumn.new(:id, :sortable => "#{RequestChangeDeadline.table_name}.id", :groupable => true),
      QueryColumn.new(:user_id, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new( :issue, :sortable => "#{Issue.table_name}.subject", :groupable => true),
      QueryColumn.new(:reason, :sortable => "#{RequestChangeDeadline.table_name}.reason", :groupable => true),
      QueryColumn.new(:status, :sortable => "#{RequestChangeDeadline.table_name}.status", :groupable => true),
      QueryColumn.new(:old_deadline, :sortable => "#{RequestChangeDeadline.table_name}.old_deadline", :groupable => true),
      QueryColumn.new(:new_deadline, :sortable => "#{RequestChangeDeadline.table_name}.new_deadline", :groupable => true),

      QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true),
      QueryColumn.new(:subject, :sortable => "#{Issue.table_name}.subject"),
      QueryColumn.new(:assigned_to, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
      QueryColumn.new(:author, :sortable => lambda {User.fields_for_order_statement("authors")}, :groupable => true)
  ]

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
    @available_columns
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= { 'issue_id' => {:operator => "*", :values => [""]} }
  end

  def initialize_available_filters
    add_available_filter"user_id",
                        :type => :list,
                        :values => requester_values,
                        :name => "Requester"

    add_available_filter"project_id", :type => :list, :values => project_values

    add_available_filter"issue_id", :type => :text

    add_available_filter"reason", :type => :text

    add_available_filter"status", :type => :list,
                        values:[  ['Pending', '0'],  ['Approved', '1'],  ['Rejected', '2'] ]

    add_available_filter"old_deadline", :type => :date

    add_available_filter "new_deadline", :type => :date

    add_available_filter "priority_id",
                         :type => :list, :values => IssuePriority.all.collect{|s| [s.name, s.id.to_s] }

    add_available_filter "subject", :type => :text

    add_available_filter"assigned_to_id",
                        :type => :list_optional, :values => assigned_to_values

    add_available_filter "author_id",
                       :type => :list, :values => author_values

  end

  def default_columns_names
    @default_columns_names = [:id, :project, :issue, :user, :reason,  :old_deadline, :new_deadline, :status]
  end

  def default_sort_criteria
    [['id', 'desc']]
  end

  def requests(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
    scope = RequestChangeDeadline.visible.
        includes(:user, :issue=> [:status, :project, :assigned_to, :author, :priority]).
        where(statement).
        order(order_option).
        limit(options[:limit]).
        offset(options[:offset])

    requests = scope.to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def base_scope
    RequestChangeDeadline.visible.
        includes(:user, :issue=> [:status, :project])
  end

  def requests_count
    base_scope.count
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def sql_for_project_id_field(field, operator, value)
    sql = '('
    sql << sql_for_field(field, operator, value, Issue.table_name, 'project_id')
    sql << ')'
    sql
  end

  def sql_for_author_id_field(field, operator, value)
    sql = '('
    sql << sql_for_field(field, operator, value, Issue.table_name, 'author_id')
    sql << ')'
    sql
  end
  private

  def requester_values
    requester_values = []
    requester_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    users = User.all
    requester_values += users.sort_by(&:name).collect{|s| s.name }
    requester_values
  end


end