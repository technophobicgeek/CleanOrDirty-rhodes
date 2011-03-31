require 'rho'
require 'rho/rhocontroller'
require 'rho/rhoerror'
require 'helpers/browser_helper'
require 'helpers/settings_helper'

class SettingsController < Rho::RhoController
  include BrowserHelper
  include SettingsHelper
  
  def index
    @msg = @params['msg']
    render
  end

  def do_reset
    Rhom::Rhom.database_full_reset
    SyncEngine.dosync
    @msg = "Database has been reset."
    redirect :action => :index, :query => {:msg => @msg}
  end
  

end
