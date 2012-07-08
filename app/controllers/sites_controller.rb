class SitesController < ApplicationController

#    skip_before_filter :authenticate_user!, :only => [ :index, :update ]

skip_before_filter :authenticate_user!, :only => [ :main ]

  def site_ids
    @site_ids = Site.new
    render json: @site_ids.site_ids
  end

  def data
    @range = Site.new.range_of_data
    render json: @range
  end

  def test
    site = 1
    @number_records = TimeLog.where( :site_id => site ).count
    @sites = Site.all
    @point_range = Site.new.log_stats
    @sites_for_select = Site.new.sites_for_select
  end

  # make a get request on this method to send off the system_down message
  def system_down
    down_count = params[:down_count]
    Notifier.system_down(down_count).deliver
    redirect_to root_path
  end

  def main      
    @ok = Site.new.ok
    @unable = Site.new.unable
    @warning = Site.new.warning
    @sites = Site.all
    @checker = User.find(:all, :conditions => [ 'email = :em', :em => 'talon@denenberg.net' ] )
#    @point_range = Site.new.log_stats

    ldate = Hash.new
    ldate['logged_in'] = @checker[0].last_sign_in_at

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: ldate }
      end

  end
  
  def index
    @sites = Site.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.json
  def show
    @site = Site.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/new
  # GET /sites/new.json
  def new
    @site = Site.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @site }
    end
  end

  # GET /sites/1/edit
  def edit
    @site = Site.find(params[:id])
  end

  # POST /sites
  # POST /sites.json
  def create
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        format.html { redirect_to @site, notice: 'Site was successfully created.' }
        format.json { render json: @site, status: :created, location: @site }
      else
        format.html { render action: "new" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.json
  def update
    @site = Site.find(params[:id])

    respond_to do |format|
      if @site.update_attributes(params[:site])
        format.html { redirect_to @site, notice: 'Site was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.json
  def destroy
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json { head :ok }
    end
  end
end
