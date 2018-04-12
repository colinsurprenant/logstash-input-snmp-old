# encoding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, "..", "..", "lib")))

require "pp"
require "logstash/inputs/snmp/mib"

mib = LogStash::SnmpMib.new
module_name, names, oids = mib.read_mib_dic("tmp/RFC1213-MIB.dic")
puts(module_name)
pp(names)
pp(oids)