class RequestChangeDeadline < ActiveRecord::Base

  include Redmine::SafeAttributes

  belongs_to :user
  belongs_to :issue

  delegate :project, to: :issue
  acts_as_customizable

  safe_attributes 'reason',
                  'new_deadline'

  scope :visible, -> { User.current.login != "admin" ? where(user_id: User.current.id) : where(nil) }

  def status
    s = super
    case s
    when '0', 0  then 'Pending'
    when '1', 1  then 'Approved'
    when '2', 2  then 'Rejected'
    else
      '-'
    end
  end

end
