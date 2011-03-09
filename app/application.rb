require 'rho/rhoapplication'

class AppApplication < Rho::RhoApplication
  def initialize

    @tabs = nil
    @@tabbar = nil
    
    @@toolbar = [{:action => :home}, {:action => :separator},{:action => :options} ]
    
    super

    # Uncomment to set sync notification callback to /app/Settings/sync_notify.
    # SyncEngine::set_objectnotify_url("/app/Settings/sync_notify")
    # SyncEngine.set_notification(-1, "/app/Settings/sync_notify", '')

    $has_dishwasher = false
    
  end
end
