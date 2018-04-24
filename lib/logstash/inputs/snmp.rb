# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require_relative "snmp/client"
require_relative "snmp/mib"

# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Snmp < LogStash::Inputs::Base
  config_name "snmp"

  # List of OIDs for which we want to retrieve the scalar value
  config :get,:validate => :array # [".1.3.6.1.2.1.1.1.0"]

  # List of OIDs for which we want to retrieve the subtree of information
  config :walk,:validate => :array # [".1.3.6.1.2.1.1.1.0"]

  # List of hosts to query the configured `get` and `walk` options.
  #
  # Each host definition is a hash and must define the `host` key and value.
  #  `host` must use the format {tcp|udp}:{ip address}/{port}
  #  for example `host => "udp:127.0.0.1/161"`
  # Each host definition can optionally include the following keys and values:
  #  `community` with a default value of `public`
  #  `version` with a default value of `2c`
  #  `retries` with a detault value of `2`
  #  `timeout` in milliseconds with a default value of `1000`
  config :hosts, :validate => :array  #[ {"host" => "udp:127.0.0.1/161", "community" => "public"} ]

  # List of paths of MIB .dic files of dirs. If a dir path is specified, all files with .dic extension will be loaded.
  #
  # ATTENTION: a MIB .dic file must be generated using the libsmi library `smidump` command line utility
  # like this for example. Here the `RFC1213-MIB.txt` file is an ASN.1 MIB file.
  #
  # `$ smidump -k -f python RFC1213-MIB.txt > RFC1213-MIB.dic`
  #
  # The OSS libsmi library https://www.ibr.cs.tu-bs.de/projects/libsmi/ is available & installable
  # on most OS.
  config :mib_paths, :validate => :array # ["path/to/mib.dic", "path/to/mib/dir"]

  # Set polling interval in seconds
  #
  # The default, `30`, means poll each host every 30second.
  config :interval, :validate => :number, :default => 30

  def register
    validate_oids!
    validate_hosts!

    mib = LogStash::SnmpMib.new
    Array(@mib_paths).each do |path|
      # TODO handle errors
      mib.add_mib_path(path)
    end

    @client_definitions = []
    @hosts.each do |host|
      host_name = host["host"]
      community = host["community"] || "public"
      version = host["version"] || "2c"
      retries = host["retries"] || 2
      timeout = host["timeout"] || 1000

      definition = {
        :client => LogStash::SnmpClient.new(host_name, community, version, retries, timeout, mib),
        :get => Array(get),
        :walk => Array(walk),
      }
      @client_definitions << definition
    end
  end

  def run(queue)
    # for now a naive single threaded poller which sleeps for the given interval between
    # each run. each run polls all the defined hosts for the get and walk options.
    while !stop?
      @client_definitions.each do |definition|
        result = {}
        if !definition[:get].empty?
          result = result.merge(definition[:client].get(definition[:get]))
        end
        if  !definition[:walk].empty?
          definition[:walk].each do |oid|
            result = result.merge(definition[:client].walk(oid))
          end
        end

        event = LogStash::Event.new(result)
        decorate(event)
        queue << event
      end

      Stud.stoppable_sleep(@interval) { stop? }
    end
  end

  def stop
  end

  private

  # TODO: implement
  def validate_oids!
    # raise LogStash::ConfigurationError if any errors
  end

  # TODO: implement
  def validate_hosts!
    # raise LogStash::ConfigurationError if any errors
  end
end
