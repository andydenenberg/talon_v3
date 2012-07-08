class Updater
  def initialize(repo_url)
    @agent = Mechanize.new
    @base_url = repo_url       
  end
    
  def login(email,password)
    # login and create an authorized session
    begin
        page = @agent.get(@base_url + '/users/sign_in')
        form = page.forms.first
        form['user[email]'] = email
        form['user[password]'] = password
        page = @agent.submit(form)
        page.body.match('Graph') ? login = true : login = false
    rescue
      login = false
    end
    return login
  end
      
  def site_checked(id, status, delay, last_checked, next_checked, watcher, down_count)
    # Update the site info
    begin
    page = @agent.get(@base_url + '/sites/' + id.to_s + '/edit')
    form = page.forms.first
    form['site[id]'] = id
    form['site[status]'] = status
    form['site[delay]'] = delay
    form['site[last_checked]'] = last_checked
    form['site[next_check]'] = next_checked
    form['site[watcher]'] = watcher  
    form['site[down_count]'] = down_count  
    page = @agent.submit(form)   
    page.body.match('Watcher') ? status = 'status_update_complete' : status = 'status_update_failed'
    rescue
      status = 'status_update_failed'
    end
    return status
  end 
    
  def time_log_new(site_id, status, delay, checked, watcher)
    # Update the Time Log info
    begin
    page = @agent.get(@base_url + '/time_logs/new')
    form = page.forms.first
    form['time_log[site_id]'] = site_id # 2
    form['time_log[status]'] = status # 'SERVER_OK'
    form['time_log[delay]'] = delay 
    form['time_log[watcher]'] = watcher 
    form['time_log[checked]'] = checked # '2012-02-04 01:00:00'
    page = @agent.submit(form)
    page.body.match('Watcher') ? status = 'tl_update_complete' : status = 'tl_update_failed'
    rescue
      status = 'tl_update_failed'
    end
    return status
  end
end

