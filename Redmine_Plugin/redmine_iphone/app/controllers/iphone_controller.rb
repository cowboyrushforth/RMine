class IphoneController < ApplicationController

  skip_before_filter :user_setup, :check_if_login_required, :set_localization
  before_filter :check_api_key_auth, :except => [:getkey]

  #this will setup current user if we have good auth
  #otherwise will return 403
  def check_api_key_auth
    User.current = User.find_by_api_key(params[:key])
    unless User.current
      render :text => "Not Authorized", :status => 403
      return
    end
  end

  #this will return the api key upon successful
  #username/password authentication
  def getkey
    user = User.try_to_login(params[:username], params[:password])
    if user.nil?
        render :text => "Not Authorized", :status => 403
        return
    elsif user.new_record?
        render :text => "Not Authorized", :status => 403
        return
    else    
       render :text => user.api_key
    end
  end

  #returns simply the string issue name
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

  #returns a bunch of tasty data surrounding an issue
  #is typically only called once per issue
  #TODO - ensure user has permission to see this issue.
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

  #this powers the issues tab
  #we use the query model here hopefully
  #to ensure that the issues list matches
  #the issues list for this user in the web ui
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
