require 'dispatcher'
require 'redmine'

#require_dependency 'successful_login_hook'
#require_dependency 'iphone_user_patch'
#require_dependency 'iphone_projects_controller_patch'
 
Dispatcher.to_prepare do
#    require_dependency 'principal'
 #   Principal.send(:include, IphoneUserPatch)
  #  require_dependency 'application_controller'
   # require_dependency 'projects_controller'

   # ProjectsController.send(:include, IphoneProjectsControllerPatch)
end

Redmine::Plugin.register :redmine_iphone do
  name 'Redmine Iphone plugin'
  author '0x7a69 Inc'
  description 'This is a plugin for Redmine to facilitate communications with the Redmine.app iPhone application'
  version '2.0.0'
end
