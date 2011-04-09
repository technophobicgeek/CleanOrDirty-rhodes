require 'json'
require 'time'


module DishwasherHelper
  
  @@server_url='http://192.168.15.9:3000/api/v1/dishwashers'
  #@@server_url='http://cleanordirty.heroku.com/api/v1/dishwashers'
  
  def log(msg)
    $rholog.info("APP",msg)
  end

  # Sync:
  def synchronize
    log "synchronize: #{@dishwasher}"
    url_suffix = (@dishwasher.code ? "/update/#{@dishwasher.code}" : "")
    if $sync_status != :invalid_code
      Rho::AsyncHttp.post(
        :url => "#{@@server_url}#{url_suffix}",
        :body =>
          ::JSON.generate(
            {
              :name => @dishwasher.name,
              :status => @dishwasher.status,
              :last_updated => @dishwasher.last_updated.to_i
            }
          ),
        :callback => url_for(:action => :synchronize_callback)
      )
      @response["headers"]["Wait-Page"] = "true"
      render :action => :wait
    else
      WebView.navigate(url_for :action => :show_dishwasher)
    end
  end
  
  def synchronize_callback
    log "synchronize_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] == 'ok'
      @dishwasher.update_attributes(@params['body'])
      $sync_status = :success
      $err_msg = "Synced :-)"
      WebView.navigate(url_for :action => :show_dishwasher)
    else
      $sync_status = (@dishwasher.code ? (:failure_to_send) : (:failure_to_create))
      err_code = @params['http_error']
      $err_msg = "Not Synced - Connection issues :-("
      if err_code == "404"
        Alert.show_popup ({
          :message => 'Invalid code. Would you like to try again?',
          :title => 'Error',
          :icon => :alert,
          :buttons => ["Yes", "No"],
          :callback => url_for(:action => :invalid_code_popup)
        })
      else
        WebView.navigate(url_for :action => :show_dishwasher)
      end
    end
  end

  def invalid_code_popup
    @dishwasher = Dishwasher.find(:first)
    id = @params["button_id"]
    if id == "Yes"
      log "Yes popup button"
      $sync_status = :unsynced
      $err_msg = ""
      Rhom::Rhom.database_full_reset
      WebView.navigate(url_for :action => :existing)
    else
      log "No popup button"
      if @dishwasher
        $err_msg = "Not Synced - Can't find a dishwasher with the code you've entered :-(" unless @dishwasher.owner
      end
      $sync_status = :invalid_code
      WebView.navigate(url_for :action => :show_dishwasher)
    end
  end  
end