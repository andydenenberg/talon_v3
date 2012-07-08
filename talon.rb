require "net/http"
require "uri"
require 'rubygems'
require 'mechanize'
require 'json'


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
    
    puts login
    
    return login    
  end

  def system_down(down_count)
    page = @agent.get(@base_url + '/sites/system_down?down_count=' + down_count.to_s )  
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
          if cl["next_check"] 
              next_check = Time.parse(cl["next_check"])
              now = Time.now
              wait = next_check.to_i - now.to_i
          else
              wait = -1
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
                  time_log = [ cl["id"], status, delay, Time.now.strftime("%Y-%m-%d %H:%M:%S"), checker_name ]
              else
                  status = 'INACTIVE'
                  delay = 0 
              end
              site_checked = [ cl["id"],status, delay, Time.now.strftime("%Y-%m-%d %H:%M:%S"), next_check.strftime("%Y-%m-%d %H:%M:%S"), checker_name ]
              puts i.to_s + " - " + cl["url"] + " - " + status + " - " + delay.to_s + " - " + next_check.strftime("%Y-%m-%d %H:%M:%S")

              update = Updater.new(repo_url)
              update.login(repo_email,repo_password)
              if status != 'INACTIVE' 
                 update.time_log_new(time_log[0],time_log[1],time_log[2],time_log[3],time_log[4])
              end              
              update.site_checked(site_checked[0],site_checked[1],site_checked[2],site_checked[3],site_checked[4],site_checked[5])
              update = nil
              
          end
     end    
  end
  
end


class Updater
  def initialize(repo_url)
    @agent = Mechanize.new
    @base_url = repo_url       
  end
  
  def form_send
    # dry up this section by creating a hash with the field => value pairs
    # use a each do block to create and send the form
    
  end
  
  def login(email,password)
    # login and create an authorized session
    begin
        page = @agent.get(@base_url + '/users/sign_in')
        form = page.forms.first
        form['user[email]'] = email
        form['user[password]'] = password
        page = @agent.submit(form)
    rescue
      return false
    end
  end
  
  def site_new(url, interval, active)
    # Create a new site
    page = @agent.get(@base_url + '/sites/new')
    form = page.forms.first
    form['site[url]'] = url
    form['site[interval]'] = interval
    form['site[active]'] = active
    page = @agent.submit(form)   
  end 
    
  def site_checked(id, status, delay, last_checked, next_checked, watcher)
    # Update the site info
    page = @agent.get(@base_url + '/sites/' + id.to_s + '/edit')
    form = page.forms.first
    form['site[id]'] = id
    form['site[status]'] = status
    form['site[delay]'] = delay
    form['site[last_checked]'] = last_checked
    form['site[next_check]'] = next_checked
    form['site[watcher]'] = watcher    
    page = @agent.submit(form)   
  end 
    
  def time_log_new(site_id, status, delay, checked, watcher)
    # Update the Time Log info
    page = @agent.get(@base_url + '/time_logs/new')
    form = page.forms.first
    form['time_log[site_id]'] = site_id # 2
    form['time_log[status]'] = status # 'SERVER_OK'
    form['time_log[delay]'] = delay 
    form['time_log[watcher]'] = watcher 
    form['time_log[checked]'] = checked # '2012-02-04 01:00:00'
    page = @agent.submit(form)
  end
end


# main loop
  # Initialize
    if ARGV[0] != nil
     checker_name = ARGV[0]
     repo_url = ARGV[1]
     repo_email = ARGV[2]
     repo_password = ARGV[3]
     watcher_delay = (ARGV[4]).to_i
    else
      puts "argument list: checker_name('checker' is reserved), repo_url(http://...), repo_email, repo_password, delay"
      exit 1
    end

    down_count = 0  # set count_down for number of notifications

   while true # forever
      talon = Checker.new(repo_url)
      login = talon.login( repo_email, repo_password )
      puts login
      if  login  
              case checker_name
                when 'checker'
                  delay = talon.check_checker
                  puts delay.to_s + ' seconds' 
              
                  if delay > 200 && down_count < 3
                    down_count += 1
                    puts 'Delay exceeded 200 seconds'
                    talon.system_down(down_count)
                  end
                
                else              
                  puts "\ntop of loop"
                  check_list = talon.get_list
                  talon.check_list(check_list, repo_email, repo_password, repo_url, checker_name)
                end
       else
         puts "\nFailed to login to Repo"
       end
       talon = nil
       sleep(watcher_delay)
    end

    class Ping_sweep  
        require 'net/ping'
        base = '192.168.0.'
        p2 = Net::Ping::External.new('www.denenberg.net')
        response = p2.ping
        puts response
        (1..255).each do |i|
          addr = base + i.to_s
          p1 = Net::Ping::External.new(addr, port=7, timeout=1)
          response = p1.ping?
            if response
                puts addr + ' - ' + response.to_s
            end
        end
    end




