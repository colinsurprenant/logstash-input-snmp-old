# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/snmp/mib"

describe LogStash::SnmpMib do

  subject { LogStash::SnmpMib.new }
  let (:fixtures_dir) { File.expand_path(File.join("..", "..", "..", "fixtures/"), __FILE__) }
  let (:rfc1213_mib) { File.join(fixtures_dir, "RFC1213-MIB.dic") }
  let (:collision_mib) { File.join(fixtures_dir, "collision.dic") }

  it "should read valid mib dic file" do
    module_name, name_hash, oid_hash = subject.read_mib_dic(rfc1213_mib)
    expect(module_name).to eq("RFC1213-MIB")
    expect(name_hash.size).to eq(201)
    expect(oid_hash.size).to eq(201)
  end

  it "should produce 0 warning when first adding a mib path" do
    warnings = subject.add_mib_path(rfc1213_mib)
    expect(warnings.size).to eq(0)
  end

  it "should produce 0 warning when adding same keys and values" do
    warnings = subject.add_mib_path(rfc1213_mib)
    expect(warnings.size).to eq(0)
    warnings = subject.add_mib_path(rfc1213_mib)
    expect(warnings.size).to eq(0)
  end

  it "should produc warning when adding mib with collisions" do
    warnings = subject.add_mib_path(rfc1213_mib)
    expect(warnings.size).to eq(0)
    warnings = subject.add_mib_path(collision_mib)
    expect(warnings.size).to eq(2)
    expect(warnings[0]).to eq("warning: overwriting MIB name 'system' and OID '1.3.6.1.2.1.1' with new OID '0.0.0' from module 'RFC1213-MIB'")
    expect(warnings[1]).to eq("warning: overwriting MIB OID '1.3.6.1.2.1.1' and name 'system' with new name 'foo' from module 'RFC1213-MIB'")
  end

  it "should find existing oid and name" do
    subject.add_mib_path(rfc1213_mib)
    expect(subject.find_oid("1.3.6.1.2.1.1")).to eq("system")
    expect(subject.find_name("system")).to eq("1.3.6.1.2.1.1")
  end

  it "should not find inexisting oid and name" do
    subject.add_mib_path(rfc1213_mib)
    expect(subject.find_oid("0.0.0.0")).to be_nil
    expect(subject.find_name("foo")).to be_nil
  end

end
