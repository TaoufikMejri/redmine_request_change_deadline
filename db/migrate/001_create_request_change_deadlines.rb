class CreateRequestChangeDeadlines < ActiveRecord::Migration[5.2]
  def change
    create_table :request_change_deadlines do |t|
      t.column "issue_id", :integer
      t.column "user_id", :integer
      t.column "approved_by_id", :integer
      t.column "project_id", :integer
      t.column "reason", :text
      t.column "old_deadline", :date
      t.column "new_deadline", :date
      t.column "status", :integer, :default => 0
    end
  end
end
