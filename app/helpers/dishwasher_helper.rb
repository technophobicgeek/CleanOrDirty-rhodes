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
    WebView.navigate(url_for :action => :wait)
  end
  
  def synchronize_callback
    log "synchronize_callback: #{@params}"
    @dishwasher = Dishwasher.find(:first)
    if @params['status'] != 'ok'
      log "Error in connection in synchronize_callback"
      $sync_status = (@dishwasher.code ? (:failure_to_send) : (:failure_to_create))
    else
      @dishwasher.update_attributes(@params['body'])      
      $sync_status = :success
    end
    WebView.navigate(url_for :action => :show_dishwasher)
  end
  
end