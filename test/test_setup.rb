require 'test/unit'
require 'elastirad'

class ElastiradTest < Test::Unit::TestCase
  def testSetup

    rad1 = Elastirad::Client.new

    assert_equal 'elastirad/objects1', rad1.instance_eval{ getPathFromEsReq({:path=>"elastirad/objects1"}) }
    assert_equal 'elastirad/objects2', rad1.instance_eval{ getPathFromEsReq({:path=>["elastirad/objects2"]}) }
    assert_equal 'elastirad/objects3', rad1.instance_eval{ getPathFromEsReq({:path=>["elastirad/","/objects3"]}) }
    assert_equal '{"query":{"match_all":{}}}', rad1.instance_eval{ getBodyFromEsReq({:body=>{:query=>{:match_all=>{}}}}) }

    rad2 = Elastirad::Client.new(:index => 'elastirad')

    assert_equal 'elastirad/objects/id', rad2.instance_eval{ getPathFromEsReq({:path=>"objects/id"}) }

  end
end