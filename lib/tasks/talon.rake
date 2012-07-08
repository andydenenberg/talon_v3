  task :talon => :environment do
 
include SendGrid

require "net/http"
require "uri"
require 'rubygems'
require 'mechanize'
require 'json'

require 'update'
require 'checker'

# main loop
  # Initialize
    # ARGV[0] is task name for rake
    if ARGV[1] != nil
     checker_name = ARGV[1]
     repo_url = ARGV[2]
     repo_email = ARGV[3]
     repo_password = ARGV[4]
     watcher_delay = (ARGV[5]).to_i
     order = ARGV[6]
    
    else
      puts "argument list: checker_name('checker' is reserved), repo_url(http://...), repo_email, repo_password, delay, order"
      exit 1
    end

    down_count = 0  # set count_down for number of notifications

   while true # forever
      talon = Checker.new(repo_url)
      login = talon.login( repo_email, repo_password )
      if  login  
              case order
                when 'sec'
                  delay = talon.check_checker
                  puts delay.to_s + ' seconds' 
              
                  if delay > 200 && down_count < 3
                    down_count += 1
                    puts 'Delay exceeded 200 seconds'
                    notify = Notifier.system_down(down_count).deliver
                  end
                  # switch to primary if down for 3 attempts
                  if down_count == 3
                    order = 'pri'
                  end
                
                else              
                  puts "\ntop of loop"
                  check_list = talon.get_list
                  if check_list
                    talon.check_list(check_list, repo_email, repo_password, repo_url, checker_name)
                  else
                    puts 'unable to get list'
                  end
                end
       else
         puts "\nFailed to login to Repo"
       end
       talon = nil
       sleep(watcher_delay)
    end 

  end  # task end
