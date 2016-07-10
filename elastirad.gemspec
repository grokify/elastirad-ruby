lib = 'elastirad'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1

Gem::Specification.new do |s|
  s.name        = 'elastirad'
  s.version     = version
  s.date        = '2014-03-15'
  s.summary     = 'Elastirad - a RAD Elasticsearch client supporting minimal reading of documentation'
  s.description = 'A RAD (Rapid Application Development) Elasticsearch client'
  s.authors     = ['John Wang']
  s.email       = 'john@johnwang.com'
  s.files       = [
    'CHANGELOG.md',
    'LICENSE',
    'README.md',
    'Rakefile',
    'VERSION',
    'lib/elastirad.rb',
    'lib/elastirad/client.rb',
    'test/test_setup.rb'
  ]
  s.homepage    = 'http://johnwang.com/'
  s.license     = 'MIT'
  s.add_dependency 'elasticsearch', '~> 1.0', '>= 1.0.1'
  s.add_dependency 'faraday', '~> 0', '>= 0'
  s.add_dependency 'multi_json', '~> 1.10', '>= 1.10.1'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'test-unit'
end