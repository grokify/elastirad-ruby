lib = 'elastirad'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1

Gem::Specification.new do |s|
  s.name        = lib
  s.version     = version
  s.date        = '2016-11-13'
  s.summary     = 'Elastirad - A Ruby SDK Wrapper for Elasticsearch using the online cURL documentation'
  s.description = 'A Ruby SDK Wrapper for Elasticsearch that provides and interface to use the online cURL documentation'
  s.authors     = ['John Wang']
  s.email       = 'johncwang@gmail.com'
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
  s.required_ruby_version = '>= 2.0.0'
  s.add_dependency 'elasticsearch', '~> 5.0', '>= 5.0.0'
  s.add_dependency 'faraday', '~> 0.9', '>= 0.9'
  s.add_dependency 'multi_json', '~> 1.10', '>= 1.10.1'
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'rake', '~> 11'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'test-unit', '~> 3'
end