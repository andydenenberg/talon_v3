class Site < ActiveRecord::Base
  has_many :time_logs, :dependent => :destroy

  def sites_for_select
    site = Array.new
    site += Site.all.collect { |u| [u.url, u.id] }
    return site
  end

  def site_ids
    si = Hash.new
    sites = Site.all
    sites.each do |site|
      si = si.merge({ "#{site.id}" => "#{site.url}" })
    end
    return si
  end
  
  def range_of_data
    tl = Hash.new
    sites = Site.all
    tl = Hash.new
    sites.each do |site|
      # first create the array
       t = Array.new
       count = TimeLog.where("site_id = ?", site.id).count
       first = TimeLog.where("site_id = ?", site.id).first.checked
       last = TimeLog.where("site_id = ?", site.id).last.checked
       diff = ((last - first) / 1.hour).round # hours worth of data
       t = [site.id, count, first, last, diff ]
       tl = tl.merge({ "#{site.id}" => t })
     end
     return tl
  end
  
  def fix_check_times
    sites = Site.all
    sites.each do |site|
      if site.last_checked == nil
        site.last_checked = Time.now 
        end 
      if site.next_check == nil 
        site.next_check = Time.now 
      end
      site.save
    end
    
  end
  
  def log_stats
    tl = Array.new
    self.fix_check_times
    sites = Site.all
    sites.each do |site|
       t = Array.new
       count = TimeLog.where("site_id = ?", site.id).count
       if count != 0
           first = TimeLog.where("site_id = ?", site.id).first.checked
           last = TimeLog.where("site_id = ?", site.id).last.checked
       else
           first = Time.now
           last = Time.now
       end
       t = [site.id, count, first, last ]
       tl.push t
     end
     return tl
  end
    
  def ok
    ok = Site.where(:status => 'SERVER_OK').length
  end

  def warning
    warning = Site.where(:status => 'WARNING').length
  end

  def unable
    unable_to_connect = Site.where(:status => 'UNABLE_TO_CONNECT').length
  end

end


