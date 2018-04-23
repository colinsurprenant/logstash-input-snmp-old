# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/snmp"

describe LogStash::Inputs::Snmp do

  it_behaves_like "an interruptible input plugin" do
    let(:config) {{
        "get" => [".1.3.6.1.2.1.1.1.0", ".1.3.6.1.2.1.1.3.0", ".1.3.6.1.2.1.1"],
        "walk" => [".1.3.6.1.2.1.1"],
        "hosts" => [{"host" => "udp:127.0.0.1/161", "community" => "public"}]
    }}
  end

end
