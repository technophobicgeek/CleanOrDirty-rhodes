require 'json'
require 'time'


# TODO: handle weird failure cases
# - no network while create_dishwasher
# - no network while reading
# - no network while updating

module DishwasherHelper
  
  @@server_url='http://192.168.15.8:3000/api/v1/dishwashers'
  #@@server_url='http://cleanordirty.heroku.com/api/v1/dishwashers'
  
  
  def change_status
    @dishwasher = Dishwasher.find(@params['id'])
    new_status = ( @dishwasher.status == 'dirty' ? 'clean' : 'dirty')
    @dishwasher.update_attributes({:status => new_status})
    dishwasher_service_update    
    render :action => :show
  end

  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    @dishwasher.last_updated = 0
    dishwasher_service_create
    render :action => :show
  end

  def existing
    @dishwasher = Dishwasher.new
    render :action => :existing
  end
  
  def existing_dishwasher
    d_hash = @params['dishwasher']
    d_hash["last_updated"] = 0
    @dishwasher = Dishwasher.create(d_hash)
    puts "Existing dishwasher created: #{d_hash}, #{@dishwasher.last_updated}"
    dishwasher_service_read   # create dishwasher object, but update
  end
  
  def show_or_create_dishwasher
    $current_controller = self
    if sync_dishwasher
      render :action => :show
    else
      render :action => :new_or_existing
    end
  end

  def sync_dishwasher
    puts "DishwasherHelper sync_dishwasher"
    @dishwasher = Dishwasher.find(:first)
    if @dishwasher
      if ($sync_status != :success)
        puts "syncing"
        dishwasher_service_read
      else
        puts "showing"
      end
      @dishwasher
    end
  end
  
  def show_dishwasher
    puts "In show_dishwasher"
    @dishwasher = Dishwasher.find(:first)
    render :action => :show
  end
  
  def edit_dishwasher
    @dishwasher = Dishwasher.find(:first)
    if @dishwasher
      render :action => :edit
    else
      new
    end
  end

  def update_dishwasher
    @dishwasher = Dishwasher.find(@params['id'])
    puts @params['id']
    @dishwasher.update_attributes(@params['dishwasher']) if @dishwasher
    dishwasher_service_update
    render :action => :show
  end



  # Sync:
  #   create dishwasher on server
  #   extract code from response
  #   update code in local db
  def dishwasher_service_create
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}",
      :body => ::JSON.generate({:name => @dishwasher.name}),
      :callback => url_for(:action => :dishwasher_create_callback)
    )
  end

  def dishwasher_create_callback
    puts "dishwasher_create_callback: #{@params}"
    if @params['status'] != 'ok'
      puts "Error in dishwasher_create_callback"
      $sync_status = :failure_to_create
    else
      @dishwasher = Dishwasher.find(:first)
      @dishwasher.update_attributes(
        {
          :code => @params['body']['code'],
          :last_updated => Time.now.utc.to_i 
        }
      )
      $sync_status = :success
    end
  end

  def dishwasher_service_read
    Rho::AsyncHttp.get(
      :url => "#{@@server_url}/#{@dishwasher.code}",
      :callback => (url_for :action => :dishwasher_read_callback)
    )
  end

  def dishwasher_read_callback
    puts "dishwasher_read_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] != 'ok'
      puts "Error in connection in dishwasher_read_callback"
      $sync_status = :failure_to_recv
    else
      synchronize(@params['body'])
      $sync_status = :success
    end
    WebView.navigate(url_for :action => :show_dishwasher)
  end
  
  def synchronize(sync_hash)
    remote_status = sync_hash['status']
    remote_update_TS = sync_hash['last_updated']
    local_update_TS = @dishwasher.last_updated.to_i
    remote_name = sync_hash['name']
    if remote_update_TS > local_update_TS
      puts "Remote: #{remote_update_TS}, #{local_update_TS}, #{remote_status}, #{remote_name}"
      @dishwasher.update_attributes(
        {
          :status => remote_status,
          :last_updated => remote_update_TS,
          :name => remote_name
        }
      )
    else
      dishwasher_service_update
    end
  end

  def dishwasher_service_update
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}/update/#{@dishwasher.code}",
      :body => ::JSON.generate({:name => @dishwasher.name, :status => @dishwasher.status}),
      :callback => url_for(:action => :dishwasher_update_callback)
    )
  end
  
  def dishwasher_update_callback
    puts "dishwasher_update_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] != 'ok'
      puts "Error in connection in dishwasher_update_callback"
      $sync_status = :failure_to_send
    else
      $sync_status = :success
    end
  end
  
  def dishwasher_service_delete
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}/delete/#{@dishwasher.code}",
      :callback => url_for(:action => :dishwasher_delete_callback)
    )
  end

  def dishwasher_delete_callback
    puts "DUMMY callback: #{@params}"
  end
  
end