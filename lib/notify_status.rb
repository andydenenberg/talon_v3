class Notify_status

  def system_down(down_count)
    
    puts 'down for the count'
        
    Notifier.system_down(down_count).deliver

#    page = @agent.get(@base_url + '/sites/system_down?down_count=' + down_count.to_s )  
  end