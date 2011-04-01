require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize

    @tabs = nil
    @@tabbar = nil
    
    @@toolbar = [
      {:action => :home},
      {:action => :separator},
      {:action => :home, :icon => "/public/images/resync.png"},
      {:action => :separator},
      {:action => :options}
    ]
    
    super

    $current_controller = nil
    $rholog = RhoLog.new
  end

  def on_activate_app
    $rholog.info("APP","on_activate_app")
    if $current_controller
      $current_controller.sync_dishwasher
    end
  end
  
  def on_deactivate_app
    $rholog.info("APP","on_deactivate_app")
    if $current_controller
      $current_controller.sync_dishwasher if $sync_status == :failure_to_send
    end
    $sync_status = :deactivated
  end

end
