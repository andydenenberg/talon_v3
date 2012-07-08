class Checker
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
      page = @agent.get(@base_url)
      page.body.match('Graph') ? login = true : login = false
    rescue 
      login = false    
    end
    return login    
  end

  def system_down(down_count)    
    puts 'down for the count'
    Notifier.system_down(down_count).deliver
#    page = @agent.get(@base_url + '/sites/system_down?down_count=' + down_count.to_s )  
  end
  
  def check_checker
    page = @agent.get(@base_url + '/sites/main.json')
    raw_data = page.body
    list = JSON.parse(raw_data)
    
    if list["logged_in"]
      temp = (list["logged_in"]).split('T')
      date = temp[0]
      time = (temp[1]).split('Z')[0] 
      list["logged_in"] = date + ' ' + time
      
      last_check = Time.parse(list['logged_in'])
      now = Time.now
      wait = now.to_i - last_check.to_i
      return wait      
    end
       
  end
  
  def get_list
    page = @agent.get(@base_url + '/sites.json')
    raw_data = page.body
    list = JSON.parse(raw_data)
    # fix the format of dates
    list.each_with_index do |l, i|
          if l["last_checked"]
            temp = (l["last_checked"]).split('T')
            date = temp[0]
            time = (temp[1]).split('Z')[0] 
            l["last_checked"] = date + ' ' + time
          end
          if l["next_check"]
            temp = (l["next_check"]).split('T')
            date = temp[0]
            time = (temp[1]).split('Z')[0] 
            l["next_check"] = date + ' ' + time
          end
     end
     return list
  end
    
  def monitor(url,content)
    begin
    before = Time.now
#    response = @agent.get('http://' + url)
    # check to see if this is faster? 
    uri = URI.parse('http://' + url)    
    response = Net::HTTP.get_response(uri)
    elapsed = Time.now - before
    response.body.match(content) ? status = "SERVER_OK" : status = "WARNING"
    rescue 
      elapsed = 0
      status = "UNABLE_TO_CONNECT"  
    end
    return status, elapsed
  end
  
  def check_list(site_list,repo_email,repo_password,repo_url,checker_name)
    site_list.each_with_index do |cl, i|
          
          # check to see if wait time has elapsed
          if cl["next_check"] 
              next_check = Time.parse(cl["next_check"])
              now = Time.now
              wait = next_check.to_i - now.to_i
          else
              wait = -1 # first time, no previous next_check in db
          end
          
          if wait > 0
              puts cl["url"] + " is waiting.... " + wait.to_s
          else
              puts "Wait time has elapsed = "  + wait.to_s
              interval = cl["interval"]
              next_check = Time.now + interval                  
              if cl["active"] == 'yes'
                  response = self.monitor(cl["url"],cl["content"])
                  status = response[0]
                  delay = response[1]
                  
                    if status == 'UNABLE_TO_CONNECT'
                      if cl['down_count'] < 3
                        cl['down_count'] =+ 1
                        notify = Notifier.device_down(cl['down_count'], cl['url']).deliver
                      else
                        cl['down_count'] == 0
                      end
                    end

                  time_log = [ cl["id"], status, delay, Time.now.strftime("%Y-%m-%d %H:%M:%S"), checker_name ]
              else
                  status = 'INACTIVE'
                  delay = 0 
              end
              site_checked = [ cl["id"],status, delay, Time.now.strftime("%Y-%m-%d %H:%M:%S"), next_check.strftime("%Y-%m-%d %H:%M:%S"), checker_name, down_count ]
              puts i.to_s + " - " + cl["url"] + " - " + status + " - " + delay.to_s + " - " + next_check.strftime("%Y-%m-%d %H:%M:%S")

              update = Updater.new(repo_url)
              if update.login(repo_email,repo_password)
                  if status != 'INACTIVE' 
                     time_log_update = update.time_log_new(time_log[0],time_log[1],time_log[2],time_log[3],time_log[4])
                     puts time_log_update #  Need to write this to a log file
                  end              
                  status_update = update.site_checked(site_checked[0],site_checked[1],site_checked[2],site_checked[3],site_checked[4],site_checked[5], site_checked[6])
                  puts status_update # Need to write this to a log file
                  update = nil
              else
                puts 'unable to login'
              end
              
          end
     end    
  end
  
end
