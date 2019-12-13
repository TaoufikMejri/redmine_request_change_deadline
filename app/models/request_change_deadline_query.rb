class RequestChangeDeadlineQuery < Query
  self.queried_class = RequestChangeDeadline

  self.available_columns = [
      QueryColumn.new(:user, :sortable => lambda {User.fields_for_order_statement}, :groupable => true),
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new( :issue, :sortable => "#{Issue.table_name}.subject", :groupable => true),

      #QueryColumn.new( :issue_id, :sortable => "#{Issue.table_name}.id", :groupable => true),
      QueryColumn.new(:reason, :sortable => "#{RequestChangeDeadline.table_name}.reason", :groupable => true),
      QueryColumn.new(:status, :sortable => "#{RequestChangeDeadline.table_name}.status", :groupable => true),
      QueryColumn.new(:old_deadline, :sortable => "#{RequestChangeDeadline.table_name}.old_deadline", :groupable => true),
      QueryColumn.new(:new_deadline, :sortable => "#{RequestChangeDeadline.table_name}.new_deadline", :groupable => true)
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
    add_available_filter("user",
                         :type => :text
    )

    add_available_filter("project",
                         :type => :text
    )

    add_available_filter("issue_id",
                         :type => :text
    )

    add_available_filter("reason",
                         :type => :text
    )

    add_available_filter("status",
                         :type => :list,
                         values:[  ['Pending', '0'],  ['Approved', '1'],  ['Rejected', '2'], ]
    )

    add_available_filter("old_deadline",
                         :type => :date
    )

    add_available_filter("new_deadline",
                              :type => :date
    )

  end

  def default_columns_names
    @default_columns_names = [:user, :project, :issue, :reason, :status, :old_deadline, :new_deadline]
  end

  def default_sort_criteria
    [['id', 'desc']]
  end

  def requests(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
    scope = RequestChangeDeadline.visible.
        joins(:user, :issue=> [:project]).where(statement).
        order(order_option).
        limit(options[:limit]).
        offset(options[:offset])

    requests = scope.to_a
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def base_scope
    RequestChangeDeadline.visible.joins(:user, :issue=> [:project])
  end

  def requests_count
    base_scope.count
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

end