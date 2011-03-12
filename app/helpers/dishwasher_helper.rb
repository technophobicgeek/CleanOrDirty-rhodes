module DishwasherHelper
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
    render :action => :show
  end

  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
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
  
end