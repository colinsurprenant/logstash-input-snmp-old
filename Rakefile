require "logstash/devutils/rake"

require 'jar_installer'

desc 'setup jar dependencies and generates <gemname>_jars.rb'

require 'jars/installer'
task :install_jars do
  Jars::Installer.vendor_jars!
end