Gem::Specification.new do |s|
  s.name          = 'logstash-input-snmp'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = "SNMP input plugin"
  s.description   = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.homepage      = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.authors       = ['Colin Surprenant']
  s.email         = 'colin.surprenant@gmail.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  s.requirements  << "jar org.snmp4j:snmp4j, 2.5.11"

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api",  ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22'
  # s.add_runtime_dependency 'jar-dependencies'
  s.add_development_dependency 'logstash-devutils', '>= 0.0.16'

end
