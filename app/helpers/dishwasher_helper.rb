require 'json'

module DishwasherHelper
  
  @@server_url='http://192.168.15.5:3000/api/v1/dishwashers'
  
  def change_status
    @dishwasher = Dishwasher.find(@params['id'])
    new_status = ( @dishwasher.status == 'dirty' ? 'clean' : 'dirty')
    @dishwasher.update_attributes({:status => new_status})
    dishwasher_service_update    
    render :action => :show
  end

  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    dishwasher_service_create
    render :action => :show
  end

  def existing
    @dishwasher = Dishwasher.new
    render :action => :existing
  end
  
  def existing_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    dishwasher_service_update
    render :action => :show
  end
  
  def show_or_create_dishwasher
    @dishwasher = Dishwasher.find(:first)
    if @dishwasher
      dishwasher_service_read
      render :action => :show
    else
      render :action => :new_or_existing
    end
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
    else
      @dishwasher = Dishwasher.find(:first)
      @dishwasher.update_attributes({:code => @params['body']['code']})
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
    if @params['status'] != 'ok'
      puts "Error in connection in dishwasher_read_callback"
    else
      @dishwasher = Dishwasher.find(:first)
      synchronize(@params['body'])
    end
  end
  
  def synchronize(sync_hash)
    status = sync_hash['status']
    puts "Returned status #{status}"
    remote_update_TS = sync_hash['last_updated']
    local_update_TS = @dishwasher.last_updated.to_i
    if remote_update_TS > local_update_TS
      @dishwasher.update_attributes({:status => status})
    else
      dishwasher_service_update
    end
  end

  def dishwasher_service_update
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}/update/#{@dishwasher.code}",
      :body => ::JSON.generate({:name => @dishwasher.name, :status => @dishwasher.status}),
      :callback => url_for(:action => :dummy_callback)
    )
  end

  def dishwasher_service_delete
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}/delete/#{@dishwasher.code}",
      :callback => url_for(:action => :dummy_callback)
    )
  end
  
  def dummy_callback
    puts "DUMMY callback: #{@params}"
  end
  
end