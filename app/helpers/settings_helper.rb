module SettingsHelper
  def do_remove_dishwasher
    Rhom::Rhom.database_full_reset
    SyncEngine.dosync
    WebView.navigate Rho::RhoConfig.start_path
  end  
end