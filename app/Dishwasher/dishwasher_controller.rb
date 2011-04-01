require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dishwasher_helper'
require 'helpers/application_helper'


# TODO: Default status should be "Dirty"

class DishwasherController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper
  include DishwasherHelper


  # GET /Dishwasher/new
  def new
    @dishwasher = Dishwasher.new
    render :action => :new
  end
  
  def change_status
    @dishwasher = Dishwasher.find(@params['id'])
    new_status = ( @dishwasher.status == 'dirty' ? 'clean' : 'dirty')
    @dishwasher.update_attributes({:status => new_status})
    dishwasher_service_update
  end
  
  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    @dishwasher.last_updated = 0
    dishwasher_service_create
  end
  
  def existing
    @dishwasher = Dishwasher.new
    render :action => :existing
  end
  
  def existing_dishwasher
    d_hash = @params['dishwasher']
    d_hash["last_updated"] = 0
    @dishwasher = Dishwasher.create(d_hash)
    log "Existing dishwasher created: #{d_hash}, #{@dishwasher.last_updated}"
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
    log "DishwasherHelper sync_dishwasher"
    @dishwasher = Dishwasher.find(:first)
    if @dishwasher
      if ($sync_status != :success)
        log "syncing"
        dishwasher_service_read
      else
        log "showing"
      end
      @dishwasher
    end
  end
  
  def show_dishwasher
    log "In show_dishwasher"
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
    log @params['id']
    @dishwasher.update_attributes(@params['dishwasher']) if @dishwasher
    dishwasher_service_update
    #render :action => :show
  end
end
