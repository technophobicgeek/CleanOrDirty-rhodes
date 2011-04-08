require 'json'
require 'time'


module DishwasherHelper
  
  @@server_url='http://192.168.15.5:3000/api/v1/dishwashers'
  #@@server_url='http://cleanordirty.heroku.com/api/v1/dishwashers'
  


  def log(msg)
    $rholog.info("APP",msg)
  end

  # Sync:
  #   create dishwasher on server
  #   extract code from response
  #   update code in local db
  def dishwasher_service_create
    Rho::AsyncHttp.post(
      :url => "#{@@server_url}",
      :body => ::JSON.generate({:name => @dishwasher.name, :status => @dishwasher.status}),
      :callback => url_for(:action => :dishwasher_create_callback)
    )
      WebView.navigate(url_for :action => :wait)
  end

  def dishwasher_create_callback
    log "dishwasher_create_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] != 'ok'
      log "Error in dishwasher_create_callback"
      $sync_status = :failure_to_create
    else
      @dishwasher.update_attributes({:code => @params['body']['code']})
      $sync_status = :success
    end
    WebView.navigate(url_for :action => :show_dishwasher)
  end

  def dishwasher_service_read
    if @dishwasher.code
      Rho::AsyncHttp.get(
        :url => "#{@@server_url}/#{@dishwasher.code}",
        :callback => (url_for :action => :dishwasher_read_callback)
      )
      WebView.navigate(url_for :action => :wait)
    else
      log "No dishwasher code, cannot be synced"
      $sync_status = :failure_to_create
      WebView.navigate(url_for :action => :show_dishwasher)
    end
  end
  
  def dishwasher_read_callback
    log "dishwasher_read_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] != 'ok'
      log "Error in connection in dishwasher_read_callback"
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
      log "Remote: #{remote_update_TS}, #{local_update_TS}, #{remote_status}, #{remote_name}"
      @dishwasher.update_attributes(
        {
          :status => remote_status,
          :last_updated => remote_update_TS,
          :name => remote_name
        }
      )
    elsif blank?(@dishwasher.name)
      @dishwasher.update_attributes({:name => remote_name})  unless blank?(remote_name)
    else
      dishwasher_service_update
    end
  end

  def dishwasher_service_update
    if @dishwasher.code
      Rho::AsyncHttp.post(
        :url => "#{@@server_url}/update/#{@dishwasher.code}",
        :body => ::JSON.generate({:name => @dishwasher.name, :status => @dishwasher.status}),
        :callback => url_for(:action => :dishwasher_update_callback)
      )
      WebView.navigate(url_for :action => :wait)
    else
      $sync_status = :failure_to_create
    end
    WebView.navigate(url_for :action => :show_dishwasher)
  end
  
  def dishwasher_update_callback
    log "dishwasher_update_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] != 'ok'
      log "Error in connection in dishwasher_update_callback"
      $sync_status = :failure_to_send
    else
      $sync_status = :success
    end
    WebView.navigate(url_for :action => :show_dishwasher)
  end
  
end