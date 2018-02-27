# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"
require "stud/interval"
require "socket" # for Socket.gethostname
require_relative "snmp/client"

# Generate a repeating message.
#
# This plugin is intented only as an example.

class LogStash::Inputs::Snmp < LogStash::Inputs::Base
  config_name "snmp"


  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  config :oids_get,:validate => :array # [".1.3.6.1.2.1.1.1.0"]

  config :oids_walk,:validate => :array # [".1.3.6.1.2.1.1.1.0"]

  config :hosts, :validate => :array  #[ {"host" => "udp:127.0.0.1/161", "community" => "public"} ]

  # config :retries, :validate => :integer, :default => 2
  #
  # config :timeout, :validate => :integer, :default => 1000

  # Set polling interval
  #
  # The default, `1`, means poll each host every second.
  config :interval, :validate => :number, :default => 1

  public
  def register

    # @host = Socket.gethostname
    validate_oids!
    validate_hosts!

    @client_definitions = []
    hosts.each do |host|
      host_name = host["host"]
      community = host["community"] || "public"
      version = host["version"] || "2c"
      retries = host["retries"] || 2
      timeout = host["timeout"] || 1000

      definition = {
        :client => LogStash::SnmpClient.new(host_name, community, version, retries, timeout),
        :get => Array(oids_get),
        :walk => Array(oids_walk),
      }
      @client_definitions << definition
    end
  end

  def run(queue)
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

  def validate_oids!
    puts("oids_get=#{oids_get.inspect}")
    puts("oids_walk=#{oids_walk.inspect}")
    # all good
  end

  def validate_hosts!
    puts("hosts=#{hosts.inspect}")
    # all good

    # raise(LogStash::ConfigurationError,  I18n.t(:plugin => "input", :type => "snmp", :error => "Configuration option 'hosts' is required"))
  end
end
