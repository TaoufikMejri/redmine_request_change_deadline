class RequestMailer < Mailer

  def request_add(user, request, issues)
    @issues = issues
    @request = request
    @user = user
    @request_url = url_for(:controller => 'change_deadlines', :action => 'show', :id => request)
    mail :to => user.mail, :subject => "New request to change deadline"
  end

  def self.deliver_request_add(user, request, issues)
    request_add(user, request, issues).deliver_now
  end
end