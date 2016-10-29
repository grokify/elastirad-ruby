require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

module  Elastirad
  class Client
    include Elasticsearch::API
    attr_accessor :index

    ES_DEFAULT_SCHEME = 'http'
    ES_DEFAULT_HOST = 'localhost'
    ES_DEFAULT_PORT = 9200
    ES_DEFAULT_URL = 'http://localhost:9200'

    def initialize(opts={})
      @scheme   = opts.has_key?(:protocol) && opts[:protocol] \
                ? opts[:protocol] : ES_DEFAULT_SCHEME
      @hostname = opts.has_key?(:hostname) && opts[:hostname] \
                ? opts[:hostname] : ES_DEFAULT_HOST
      @port     = opts.has_key?(:port) && opts[:port] \
                ? opts[:port].to_i : ES_DEFAULT_PORT
      @index    = opts.has_key?(:index) && opts[:index] \
                ? opts[:index].strip : nil
      @url      = make_url @scheme, @hostname, @port
      @http     = Faraday::Connection.new url: @url || ES_DEFAULT_URL
      @verbs    = {put:1, get:1, post:1, delete:1}
    end

    def index(req = {})
      req[:verb] = :put
      self.rad_request req
    end

    def rad_request(req = {})
      res = self.perform_request \
        get_verb_for_es_req(req),
        get_path_for_es_req(req),
        nil,
        get_body_for_es_req(req)

      res.body ? MultiJson.decode(res.body, symbolize_keys: true) : nil
    end

    def perform_request(method, path, params, body)
      @http.run_request \
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

    def make_url(scheme = ES_DEFAULT_SCHEME, hostname = ES_DEFAULT_PORT, port = ES_DEFAULT_PORT)
      if hostname.nil?
        hostname = 'localhost'
      elsif hostname.is_a?(String)
        hostname.strip!
        if hostname.length < 1
          hostname = 'localhost'
        end
      else
        raise ArgumentError, 'E_HOSTNAME_IS_NOT_A_STRING'
      end
      if port.nil?
        port = 9200
      elsif port.is_a?(String) && port =~ /^[0-9]+$/
        port = port.to_i
      elsif ! port.kind_of?(Integer)
        raise ArgumentError, 'E_PORT_IS_NOT_AN_INTEGER'
      end
      url = "#{scheme}://#{hostname}"
      url.sub!(/\/+\s*$/,'')
      url += ':' + port.to_s if port != 80
      return url
    end

    def get_verb_for_es_req(es_req = {})
      verb = es_req.has_key?(:verb) ? es_req[:verb] : :get
      verb = verb.downcase.to_sym
      unless @verbs.has_key?( verb )
        raise ArgumentError, 'E_BAD_VERB'
      end
      return verb
    end

    def get_path_for_es_req(dEsReq={})
      aPath     = []
      has_index = false

      if dEsReq.has_key?(:path)
        if dEsReq[:path].is_a?(Array)
          aPath.push(*dEsReq[:path])
        elsif dEsReq[:path].is_a?(String)
          aPath.push(dEsReq[:path])
        end
      else
        if dEsReq.has_key?(:index) && dEsReq[:index].is_a?(String)
          aPath.push(dEsReq[:index])
          has_index = true
        end
        if dEsReq.has_key?(:type) && dEsReq[:type].is_a?(String)
          aPath.push(dEsReq[:type])
        end
        if dEsReq.has_key?(:id) && dEsReq[:id].is_a?(String)
          aPath.push(dEsReq[:id])
        end
      end
      path = aPath.join('/').strip.gsub(/\/+/,'/')
      if (path.index('/')!=0 || !has_index) && ( @index.is_a?(String) && @index.length>0 )
        path = "#{@index}/#{path}"
      end
      return path
    end

    def get_body_for_es_req(es_req = {})
      json = nil
      if es_req.has_key?(:body)
        if es_req[:body].is_a?(Hash)
          json = MultiJson.encode(es_req[:body])
        elsif es_req[:body].is_a?(String) && es_req[:body].length > 0
          json = es_req[:body]
        end
        json = nil if json == '{}' || json.length < 1
      end
      return json
    end

    alias_method :rad_index, :index
    alias_method :request, :rad_request
    alias_method :request_all, :rad_request_all
  end
end