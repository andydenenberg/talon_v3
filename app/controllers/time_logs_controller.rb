class TimeLogsController < ApplicationController

#  skip_before_filter :authenticate_user!, :only => [ :create ]

class Fixnum
   SECONDS_IN_DAY = 24 * 60 * 60
   def days
     self * SECONDS_IN_DAY
   end
   def ago
     Time.now - self
   end
end
# start_date = 2.days.ago 

def convert_time(date)
  return  Time.utc(date[0..4], date[6..7], date[8..9])  
end

  def data
    site_id = params[:site_id] 
    # utc(year, month, day) → time
    start_date = convert_time(params[:start_date])
    stop_date = convert_time(params[:stop_date])
 
    tl = TimeLog.where("site_id = :si and checked >= :checked_start and checked < :checked_stop",
                              :si => site_id, :checked_start => start_date, :checked_stop => stop_date )
    max_y = tl.maximum('delay') * 1.1
    data = tl, tl.count, max_y
  
    render json: data
    
  end
  
  def control    
    site = params[:site_id]
    puts site
    @number_records = TimeLog.where( :site_id => site ).count
    puts @number_records

    render json: @number_records
    
  end

  def main
      @sites = Site.all
      @point_range = Site.new.log_stats
      @sites_for_select = Site.new.sites_for_select      
  end
  
  # GET /time_logs
  # GET /time_logs.json
  def index
#    @time_logs = TimeLog.all
    @time_logs = TimeLog.paginate :page => params[:page], :per_page => 10, :order => 'site_id'
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @time_logs }
    end
  end

  # GET /time_logs/1
  # GET /time_logs/1.json
  def show
    @time_log = TimeLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @time_log }
    end
  end

  # GET /time_logs/new
  # GET /time_logs/new.json
  def new
    @time_log = TimeLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @time_log }
    end
  end

  # GET /time_logs/1/edit
  def edit
    @time_log = TimeLog.find(params[:id])
  end

  # POST /time_logs
  # POST /time_logs.json
  def create
    @time_log = TimeLog.new(params[:time_log])
    
    puts "Creating a new time_log"

    respond_to do |format|
      if @time_log.save
        format.html { redirect_to @time_log, notice: 'Time log was successfully created.' }
        format.json { render json: @time_log, status: :created, location: @time_log }
      else
        format.html { render action: "new" }
        format.json { render json: @time_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /time_logs/1
  # PUT /time_logs/1.json
  def update
    @time_log = TimeLog.find(params[:id])

    respond_to do |format|
      if @time_log.update_attributes(params[:time_log])
        format.html { redirect_to @time_log, notice: 'Time log was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @time_log.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_logs/1
  # DELETE /time_logs/1.json
  def destroy
    @time_log = TimeLog.find(params[:id])
    @time_log.destroy

    respond_to do |format|
      format.html { redirect_to time_logs_url }
      format.json { head :ok }
    end
  end
end
