module SitesHelper
  
  def server_state_color(status)
    if status == 'SERVER_OK'
       color = 'success' 
    elsif status == 'UNABLE_TO_CONNECT'
       color = 'important'
    else 
       color = 'warning'
    end
    return color
  end
    
end
