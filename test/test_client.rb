# encoding: utf-8
$LOAD_PATH.unshift(File.expand_path(File.join(__FILE__, "..", "..", "lib")))

require "pp"
require "logstash/inputs/snmp/client"

client = LogStash::SnmpClient.new("udp:127.0.0.1/161", "public", "2c", 2, 1000)
pp client.get(".1.3.6.1.2.1.1")

pp client.walk(".1.3.6.1.2.1.1")



    # input {
    #   snmp {
    #     oids => [{oids => [".1.3.6.1.2.1.1.1.0", ".1.3.6.1.2.1.1.3.0", ".1.3.6.1.2.1.1"]}]
    #     hosts => [{address => "udp:127.0.0.1/161" community => "public"}]
    #   }
    # }