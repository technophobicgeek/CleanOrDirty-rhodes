require 'json'

module DishwasherHelper
  
  @@server_url='http://192.168.15.8:3000/api/v1/dishwashers'
  
  def change_status
    @dishwasher = Dishwasher.find(@params['id'])
    status = @dishwasher.status
    new_status = (status == 'dirty' ? 'clean' : 'dirty')

    @dishwasher.update_attributes({:status => new_status})
    
    # Sync:
    #   update dishwasher on server
    #   don't bother with response?
    dishwasher_service_update
    
    render :action => :show
  end

  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    # Sync: create dishwasher on server
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
  def dishwasher_service_create()
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}",
      :body => ::JSON.generate({:name => @dishwasher.name}),
      :callback => url_for(:action => :dishwasher_create_callback)
    )
    #render :action => :wait
  end

  def dishwasher_create_callback
    puts "dishwasher_create_callback: #{@params}"
    if @params['status'] != 'ok'
      @@error_params = @params
      puts "Error in dishwasher_create_callback"
      # TODO What do we do when no web connection?
    else
      unless @dishwasher
        @dishwasher = Dishwasher.find(:first)
      end
      code = @params['body']['code']
      @dishwasher.update_attributes({:code => code})
    end
  end

  def dishwasher_service_read()
    Rho::AsyncHttp.get(
      :url => "#{@@server_url}/#{@dishwasher.code}",
      :callback => (url_for :action => :dishwasher_read_callback)
    )
  end

  def dishwasher_read_callback
    puts "dishwasher_read_callback: #{@params}"
    if @params['status'] != 'ok'
      @@error_params = @params
      puts "Error in connection in dishwasher_read_callback"
      # TODO What do we do when no web connection?
    else
      unless @dishwasher
        @dishwasher = Dishwasher.find(:first)
      end      
      status = @params['body']['status']  # should be ruby hash
      puts "Returned status #{status}"
      @dishwasher.update_attributes({:status => status}) # only if newer
      #WebView.navigate(url_for :action => :show)
    end
  end

  def dishwasher_service_update()
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}/update/#{@dishwasher.code}",
      :body => ::JSON.generate({:name => @dishwasher.name, :status => @dishwasher.status}),
      :callback => url_for(:action => :dummy_callback)
    )
  end

  def dishwasher_service_delete()
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}/delete/#{@dishwasher.code}",
      :callback => url_for(:action => :dummy_callback)
    )
  end
  
  def dummy_callback
    puts "DUMMY callback: #{@params}"
  end
  
end