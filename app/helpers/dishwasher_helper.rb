module DishwasherHelper
  def change_status
    @dishwasher = Dishwasher.find(@params['id'])
    status = @dishwasher.status
    new_status =
        case status
        when 'clean'
          'dirty'
        when 'dirty'
          'clean'
        end
    @dishwasher.update_attributes({:status => new_status})
    render :action => :show
  end

  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    $has_dishwasher = true
    $dishwasher = @dishwasher
    WebView.navigate Rho::RhoConfig.start_path
  end
  
end