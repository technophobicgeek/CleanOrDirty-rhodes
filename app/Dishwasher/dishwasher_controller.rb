require 'rho/rhocontroller'
require 'helpers/browser_helper'
require 'helpers/dishwasher_helper'
require 'helpers/application_helper'


# TODO: Default status should be "Dirty"

class DishwasherController < Rho::RhoController
  include ApplicationHelper
  include BrowserHelper
  include DishwasherHelper


# Creating information
  
  def new
    @dishwasher = Dishwasher.new
    render :action => :new
  end
  
  def create_dishwasher
    @dishwasher = Dishwasher.create(@params['dishwasher'])
    @dishwasher.last_updated = Time.now.utc.to_i
    @dishwasher.save
    dishwasher_service_create
  end
  
  def existing
    @dishwasher = Dishwasher.new
    render :action => :existing
  end
  
  def existing_dishwasher
    @dishwasher = Dishwasher.create( @params['dishwasher'])
    @dishwasher.last_updated = 0
    @dishwasher.save
    dishwasher_service_read   # create dishwasher object, but update
  end

# Showing information
  
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
    @dishwasher = Dishwasher.find(:first)
    render :action => :show
  end

# Updating information

  def edit_dishwasher
    @dishwasher = Dishwasher.find(:first)
    render :action => :edit
  end
  
  def change_status
    find_and_update (@params['id']) do |d|
      {:status => (d.status  == 'dirty' ? 'clean' : 'dirty')}
    end
  end

  def update_dishwasher
    find_and_update (@params['id']) do |d|
      @params['dishwasher']
    end
  end

  private
  
    def find_and_update(id)
      log "find_and_update #{id}"
      @dishwasher = Dishwasher.find(id)
      new_values = yield @dishwasher
      log "New values: #{new_values}"
      @dishwasher.update_attributes(new_values) if @dishwasher
      dishwasher_service_update
    end

end
