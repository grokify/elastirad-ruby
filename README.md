Elastirad: A RAD Client for Elasticsearch
=========================================

[![Gem Version][gem-version-svg]][gem-version-link]
[![Build Status][build-status-svg]][build-status-link]
[![Coverage Status][coverage-status-svg]][coverage-status-link]
[![Dependency Status][dependency-status-svg]][dependency-status-link]
[![Code Climate][codeclimate-status-svg]][codeclimate-status-link]
[![Scrutinizer Code Quality][scrutinizer-status-svg]][scrutinizer-status-link]
[![Downloads][downloads-svg]][downloads-link]
[![Docs][docs-rubydoc-svg]][docs-rubydoc-link]
[![License][license-svg]][license-link]

## Synopsis

Elastirad is a custom Rapid Application Development (RAD) client for
Elasticsearch's `Elasticsearch::API` that provides a simple interface for
making Elasticsearch requests based on Elasticsearch's online documentation.

The primary goal for Elastirad is to enable use of the Elasticsearch online
curl-based documentation alone without needing to understand the syntax for
the Ruby SDK.

`Elastirad::Client` embeds the `Elasticsearch::API` and thus supports
`Elasticsearch::API` methods.

## Installation

Download and install elastirad with the following:

```
$ gem install elastirad
```

## Usage

```ruby
require 'elastirad'

# Defaults to http://localhost:9200

rad = Elastirad::Client.new

# All of the following arguments are optional
# Setting :index will enable request code to not include the index
# for greater flexibility when switching between deployments, e.g.
# dev, staging, production, etc.

rad = Elastirad::Client.new(
  scheme:   'https',
  hostname: 'localhost',
  port:     9200,
  index:    'articles'
)

# path can be a simple string. Leading slash will over ride default :index

result_hash = rad.rad_request path: '/articles/_count'

# path can also be an array

result_hash = rad.rad_request path: ['/articles/article', 1 ]

# default index can be used without leading slash

result_hash = rad.rad_request path: ['article', 1 ]

# retreive all responses for :get requests only

result_hash = rad.rad_request_all path: 'article/_search'

# optional :verb can be used for non-GET requests, :get is used by default

article = { title: 'Hello World', by: 'John Doe' }

result_hash = rad.rad_request(
  verb: 'put',
  path: ['article', 1 ],
  body: article
)

# :body can be a hash or JSON string

result_hash = rad.rad_request(
  verb: 'put',
  path: ['article', 1 ],
  body: JSON.dump( article )
)

# :put verb can automatically be added using #rad_index method

result_hash = rad.index(
  path: ['article', 1 ],
  body: article
)

# Supports Elasticsearch::API methods

p rad.cluster.health
# --> GET _cluster/health {}
# => "{"cluster_name":"elasticsearch" ... }"
```

## Documentation

This gem is 100% documented with YARD, an exceptional documentation library. To see documentation for this, and all the gems installed on your system use:

```bash
$ gem install yard
$ yard server -g
```

## Change Log

- **2014-03-24**: 0.0.3
  - Add `Elastirad::Client::rad_request_all()` method
  - Expose `Elastirad::Client::sIndex` as rw accessor
- **2014-03-15**: 0.0.2
  - Add documentation of Elasticsearch::API mixin functionality
  - Add `CHANGELOG.md` excerpt to `README.md`
  - Fix bug in #rad_index
  - Fix bug for YARD README.md formatting
- **2014-03-14**: 0.0.1
  - Initial release
  - Custom `Elasticsearch::API` mixin client

## Links

Elasticseach Reference Guide

* http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/index.html

Elasticsearch::API for Ruby

* https://github.com/elasticsearch/elasticsearch-ruby/tree/master/elasticsearch-api

## License

Elastirad is available under an MIT-style license. See [LICENSE.md](LICENSE.md) for details.

Elastirad &copy; 2014-2016 by John Wang

 [gem-version-svg]: https://badge.fury.io/rb/elastirad.svg
 [gem-version-link]: http://badge.fury.io/rb/elastirad
 [downloads-svg]: http://ruby-gem-downloads-badge.herokuapp.com/elastirad
 [downloads-link]: https://rubygems.org/gems/elastirad
 [build-status-svg]: https://api.travis-ci.org/grokify/elastirad-ruby.svg?branch=master
 [build-status-link]: https://travis-ci.org/grokify/elastirad-ruby
 [coverage-status-svg]: https://coveralls.io/repos/grokify/elastirad-ruby/badge.svg?branch=master
 [coverage-status-link]: https://coveralls.io/r/grokify/elastirad-ruby?branch=master
 [dependency-status-svg]: https://gemnasium.com/grokify/elastirad-ruby.svg
 [dependency-status-link]: https://gemnasium.com/grokify/elastirad-ruby
 [codeclimate-status-svg]: https://codeclimate.com/github/grokify/elastirad-ruby/badges/gpa.svg
 [codeclimate-status-link]: https://codeclimate.com/github/grokify/elastirad-ruby
 [scrutinizer-status-svg]: https://scrutinizer-ci.com/g/grokify/elastirad-ruby/badges/quality-score.png?b=master
 [scrutinizer-status-link]: https://scrutinizer-ci.com/g/grokify/elastirad-ruby/?branch=master
 [docs-rubydoc-svg]: https://img.shields.io/badge/docs-rubydoc-blue.svg
 [docs-rubydoc-link]: http://www.rubydoc.info/gems/elastirad/
 [license-svg]: https://img.shields.io/badge/license-MIT-blue.svg
 [license-link]: https://github.com/grokify/elastirad-ruby/blob/master/LICENSE
