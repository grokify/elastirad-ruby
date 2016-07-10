require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

module  Elastirad
  class Client
    include Elasticsearch::API
    attr_accessor :sIndex

    def initialize(opts={})
      @sProtocol = opts.has_key?(:protocol) && opts[:protocol] \
                 ? opts[:protocol] : 'http'
      @sHostname = opts.has_key?(:hostname) && opts[:hostname] \
                 ? opts[:hostname] : 'localhost'
      @iPort     = opts.has_key?(:port) && opts[:port] \
                 ? opts[:port].to_i : 9200
      @sIndex    = opts.has_key?(:index) && opts[:index] \
                 ? opts[:index].strip : nil
      @sUrl      = make_url @sProtocol, @sHostname, @iPort
      @oFaraday  = Faraday::Connection.new url: @sUrl || 'http://localhost:9200'
      @dVerbs    = {put:1, get:1, post:1, delete:1}
    end

    def rad_index(req={})
      req[:verb] = :put
      return self.rad_request req
    end

    def rad_request(req={})
      res = self.perform_request \
        get_verb_for_es_req(req),
        get_path_for_es_req(req),
        nil,
        get_body_for_es_req(req)

      return res.body \
        ? MultiJson.decode( res.body, symbolize_keys: true ) : nil
    end

    def perform_request(method, path, params, body)
      @oFaraday.run_request \
        method.downcase.to_sym,
        path,
        body,
        {'Content-Type' => 'application/json'}
    end

    def rad_request_all(dEsReq={})
      if dEsReq.has_key?(:body)
        if dEsReq[:body].is_a?(String)
          dEsReqBody = dEsReq[:body] \
            ? MultiJson.decode( dEsResBody, symbolize_keys: true ) : {}
          dEsReq[:body] = dEsReqBody
        end
      else
        dEsReq[:body] = {}
      end
      dEsReq[:body][:from] = 0
      dEsRes1 = self.rad_request( dEsReq )
      dEsRes  = dEsRes1
      if !dEsReq.has_key?(:verb) || dEsReq[:verb] == :get || dEsReq[:verb].downcase == 'get'
        if dEsRes1.has_key?(:hits) && dEsRes1[:hits].has_key?(:total)
          iHitsTotal = dEsRes1[:hits][:total].to_i
          iHitsSize  = dEsRes1[:hits][:hits].length.to_i
          if iHitsTotal > iHitsSize
            dEsReq[:body][:size] = iHitsTotal
            dEsRes2  = self.rad_request( dEsReq )
            dEsRes   = dEsRes2
          end
        end
      end
      return dEsRes
    end

    private

    def make_url(sProtocol='http', sHostname='localhost', iPort=9200)
      if sHostname.nil?
        sHostname = 'localhost'
      elsif sHostname.is_a?(String)
        sHostname.strip!
        if sHostname.length < 1
          sHostname = 'localhost'
        end
      else
        raise ArgumentError, 'E_HOSTNAME_IS_NOT_A_STRING'
      end
      if iPort.nil?
        iPort = 9200
      elsif iPort.is_a?(String) && iPort =~ /^[0-9]+$/
        iPort = iPort.to_i
      elsif ! iPort.kind_of?(Integer)
        raise ArgumentError, 'E_PORT_IS_NOT_AN_INTEGER'
      end
      sBaseUrl   = "#{sProtocol}://#{sHostname}"
      sBaseUrl.sub!(/\/+\s*$/,'')
      sBaseUrl  += ':' + iPort.to_s if iPort != 80
      return sBaseUrl
    end

    def get_verb_for_es_req(dEsReq={})
      sVerb = dEsReq.has_key?(:verb) ? dEsReq[:verb] : :get
      yVerb = sVerb.downcase.to_sym
      unless @dVerbs.has_key?( yVerb )
        raise ArgumentError, 'E_BAD_VERB'
      end
      return yVerb
    end

    def get_path_for_es_req(dEsReq={})
      aPath     = []
      bHasIndex = false

      if dEsReq.has_key?(:path)
        if dEsReq[:path].is_a?(Array)
          aPath.push(*dEsReq[:path])
        elsif dEsReq[:path].is_a?(String)
          aPath.push(dEsReq[:path])
        end
      else
        if dEsReq.has_key?(:index) && dEsReq[:index].is_a?(String)
          aPath.push(dEsReq[:index])
          bHasIndex = true
        end
        if dEsReq.has_key?(:type) && dEsReq[:type].is_a?(String)
          aPath.push(dEsReq[:type])
        end
        if dEsReq.has_key?(:id) && dEsReq[:id].is_a?(String)
          aPath.push(dEsReq[:id])
        end
      end
      sPath = aPath.join('/')
      sPath.strip!
      sPath.gsub!(/\/+/,'/')
      if (sPath.index('/')!=0 || !bHasIndex) && ( @sIndex.is_a?(String) && @sIndex.length>0 )
        sPath = "#{@sIndex}/#{sPath}"
      end
      return sPath
    end

    def get_body_for_es_req(dEsReq={})
      json = nil
      if dEsReq.has_key?(:body)
        if dEsReq[:body].is_a?(Hash)
          json = MultiJson.encode(dEsReq[:body])
        elsif dEsReq[:body].is_a?(String) && dEsReq[:body].length > 0
          json = dEsReq[:body]
        end
        json = nil if json == '{}' || json.length < 1
      end
      return json
    end

    alias_method :index, :rad_index
    alias_method :request, :rad_request
    alias_method :request_all, :rad_request_all
  end
end