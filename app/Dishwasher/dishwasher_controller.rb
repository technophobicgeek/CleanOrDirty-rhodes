require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dishwasher_helper'
require 'helpers/application_helper'


# TODO: Default status should be "Dirty"

class DishwasherController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper
  include DishwasherHelper
  
  #GET /Dishwasher
  def index
    @dishwashers = Dishwasher.find(:all)
    render
  end

  # GET /Dishwasher/{1}
  def show
    @dishwasher = Dishwasher.find(@params['id'])
    if @dishwasher
      render :action => :show
    else
      redirect :action => :index
    end
  end

  # GET /Dishwasher/new
  def new
    @dishwasher = Dishwasher.new
    render :action => :new
  end

  # GET /Dishwasher/{1}/edit
  def edit
    @dishwasher = Dishwasher.find(@params['id'])
    if @dishwasher
      render :action => :edit
    else
      redirect :action => :index
    end
  end

  # POST /Dishwasher/create
  def create
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    redirect :action => :index
  end

  # POST /Dishwasher/{1}/update
  def update
    @dishwasher = Dishwasher.find(@params['id'])
    @dishwasher.update_attributes(@params['dishwasher']) if @dishwasher
    redirect :action => :index
  end

  # POST /Dishwasher/{1}/delete
  def delete
    @dishwasher = Dishwasher.find(@params['id'])
    @dishwasher.destroy if @dishwasher
    redirect :action => :index
  end
  
end
