require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize

    @tabs = nil
    @@tabbar = nil
    
    @@toolbar = [{:action => :home}, {:action => :separator},{:action => :options} ]
    
    super

    $current_controller = nil
  end


  def on_deactivate_app
    puts "on_deactivate_app"
    if $current_controller
      $current_controller.sync_dishwasher if $sync_status == :failure_to_send
    end
    $sync_status = :deactivated
  end

end
