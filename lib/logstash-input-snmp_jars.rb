# this is a generated file, to avoid over-writing it just delete this comment
begin
  require 'jar_dependencies'
rescue LoadError
  require 'log4j/log4j/1.2.14/log4j-1.2.14.jar'
  require 'org/snmp4j/snmp4j/2.5.11/snmp4j-2.5.11.jar'
end

if defined? Jars
  require_jar( 'log4j', 'log4j', '1.2.14' )
  require_jar( 'org.snmp4j', 'snmp4j', '2.5.11' )
end
