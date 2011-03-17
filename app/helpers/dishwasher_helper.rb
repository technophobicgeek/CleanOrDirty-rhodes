require 'json'

module DishwasherHelper

  @@server_url='http://192.168.15.7:3000/api/vi/dishwashers'
  
  def change_status
    @dishwasher = Dishwasher.find(@params['id'])
    status = @dishwasher.status
    new_status =
        case status # TODO use ternary here?
        when 'clean'
          'dirty'
        when 'dirty'
          'clean'
        end
    @dishwasher.update_attributes({:status => new_status})
    
    # Sync:
    #   update dishwasher on server
    #   don't bother with response?
    
    render :action => :show
  end

  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    # Sync: create dishwasher on server
    dishwasher_service_create()    
    WebView.navigate Rho::RhoConfig.start_path
  end

  def show_or_create_dishwasher
    @dishwasher = Dishwasher.find(:first)
    if @dishwasher
      render :action => :show
    else
      new
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
    @dishwasher.update_attributes(@params['dishwasher']) if @dishwasher
    render :action => :show
  end

  private
  
    # Sync:
    #   create dishwasher on server
    #   extract code from response
    #   update code in local db
    def dishwasher_service_create()
      Rho::AsyncHttp.post(
        :url => "#{@@server_url}",
        :body => ::JSON:generate({:name => @dishwasher.name}),
        :callback => url_for(:action => :dishwasher_create_callback),
        :callback_param => "post=complete"
      )
    end

    def dishwasher_service_read()
    end
    
    def dishwasher_service_update()
      Rho::AsyncHttp.post(
        :url => "#{@@server_url}/update/#{@dishwasher.code}",
        :body => ::JSON:generate({:status => @dishwasher.status}),
        :callback => url_for(:action => :dishwasher_update_callback),
        :callback_param => "post=complete"
      )
    end
    
    def dishwasher_service_delete()
      Rho::AsyncHttp.post(
        :url => "#{@@server_url}/delete/#{@dishwasher.code}",
        :body => ::JSON:generate({:status => @dishwasher.status}),
        :callback => url_for(:action => :dishwasher_delete_callback),
        :callback_param => "post=complete"
      )
    end
    
end