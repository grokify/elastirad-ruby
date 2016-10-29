lib = 'elastirad'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1

Gem::Specification.new do |s|
  s.name        = lib
  s.version     = version
  s.date        = '2016-10-29'
  s.summary     = 'Elastirad - a RAD Elasticsearch client supporting minimal reading of documentation'
  s.description = 'A RAD (Rapid Application Development) Elasticsearch client'
  s.authors     = ['John Wang']
  s.email       = 'john@johnwang.com'
  s.files       = [
    'CHANGELOG.md',
    'LICENSE.md',
    'README.md',
    'Rakefile',
    'lib/elastirad.rb',
    'lib/elastirad/client.rb',
    'test/test_setup.rb'
  ]
  s.homepage    = 'http://johnwang.com/'
  s.license     = 'MIT'
  s.add_dependency 'elasticsearch', '~> 2.0', '>= 2.0.0'
  s.add_dependency 'faraday', '~> 0.9', '>= 0.9'
  s.add_dependency 'multi_json', '~> 1.10', '>= 1.10.1'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'rake', '~> 11'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'test-unit', '~> 3'
end