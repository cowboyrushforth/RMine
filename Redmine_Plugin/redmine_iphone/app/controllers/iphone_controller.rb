class IphoneController < ApplicationController

  skip_before_filter :user_setup, :check_if_login_required, :set_localization
  before_filter :check_api_key_auth

  def check_api_key_auth
    User.current = User.find_by_api_key(params[:key])
    unless User.current
      render :text => "Not Authorized", :status => 403
      return
    end
  end


  def issue_status
    id = params[:issue_id]
    if id
      issue = Issue.find(id.to_i)
      if issue
        render :status => 200, :text => issue.status.name
      else
        render :status => 404, :text => 'Issue not found'
      end
    else
      render :status => 400 , :text => 'Invalid issue_id'
    end
  end

  def issue
    id = params[:issue_id]
    if id
      @issue = Issue.find(id.to_i)
      unless @issue
        render :status => 404, :text => 'Issue not found'
      end
    else
      render :status => 400 , :text => 'Invalid issue_id'
    end
    @journals = @issue.journals.find(:all, :include => [:user, :details], :order => "#{Journal.table_name}.created_on ASC")
    @journals.each_with_index {|j,i| j.indice = i+1}
    @journals.reverse! if User.current.wants_comments_in_reverse_order?
    @changesets = @issue.changesets
    @changesets.reverse! if User.current.wants_comments_in_reverse_order?
    @allowed_statuses = @issue.new_statuses_allowed_to(User.current)
    @edit_allowed = User.current.allowed_to?(:edit_issues, @project)
    @priorities = IssuePriority.all
    @time_entry = TimeEntry.new
    @project = @issue.project
    @title = "#{@project.name}: #{@issue.subject}"

    jsonres = Hash.new
    jsonres[:issue] = @issue
    jsonres[:issue_status] = @issue.status.to_s
    jsonres[:authorName] = @issue.author.to_s
    jsonres[:authorEmail] = @issue.author.mail
    jsonres[:journals] = @journals
    jsonres[:project] = @project
    jsonres[:changesets] = @changesets
    render :json => jsonres.to_json

  end

  def issues
    @query = Query.new(:name => "_")
    @issues = @query.issues(:order => "issues.created_on desc", :limit => 50, :include => [:project, :author])
    res = Array.new
    @issues.each do |is|
      res << {:issue_id => is.id, :issue_title => is.subject, :issue_content => is.description, :project_name => is.project.name,
        :author_name => is.author.to_s, :author_email => is.author.mail, :issue_created_at => is.created_on, :issue_status => is.status.to_s }
    end
    render :json => res.to_json
  end

end
