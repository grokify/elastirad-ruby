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
      @scheme   = opts.key?(:protocol) && opts[:protocol] \
                ? opts[:protocol] : ES_DEFAULT_SCHEME
      @hostname = opts.key?(:hostname) && opts[:hostname] \
                ? opts[:hostname] : ES_DEFAULT_HOST
      @port     = opts.key?(:port) && opts[:port] \
                ? opts[:port].to_i : ES_DEFAULT_PORT
      @index    = opts.key?(:index) && opts[:index] \
                ? opts[:index].strip : nil
      @url      = build_url
      @http     = Faraday::Connection.new url: @url || ES_DEFAULT_URL
      @verbs    = {put:1, get:1, post:1, delete:1}
    end

    def index(req = {})
      req[:verb] = :put
      self.request req
    end

    def request(req = {})
      res = self.perform_request \
        get_verb_for_es_req(req),
        get_path_for_es_req(req),
        get_body_for_es_req(req)

      res.body ? MultiJson.decode(res.body, symbolize_keys: true) : nil
    end

    def perform_request(method, path, body)
      @http.run_request \
        method.downcase.to_sym,
        path,
        body,
        {'Content-Type' => 'application/json'}
    end

    def request_all(es_req = {})
      if es_req.key?(:body) && es_req[:body].is_a?(String)
        es_req[:body] = MultiJson.decode dEsResBody, symbolize_keys: true
      else
        es_req[:body] = {}
      end
      es_req[:body][:from] = 0
      es_res1 = self.rad_request es_req
      es_res  = es_res1
      if !es_req.key?(:verb) || es_req[:verb] == :get || es_req[:verb].downcase == 'get'
        if es_res1.key?(:hits) && es_res1[:hits].key?(:total)
          hits_total = es_res1[:hits][:total].to_i
          hits_this = es_res1[:hits][:hits].length.to_i
          if hits_total > hits_this
            es_req[:body][:size] = hits_total
            es_res2 = self.rad_request es_req
            es_res = es_res2
          end
        end
      end
      return es_res
    end

    private

    def build_url
      "#{@scheme}://#{@hostname}:#{@port}".sub(/\s*\/+\s*$/,'')
    end

    def get_verb_for_es_req(es_req = {})
      verb = es_req.key?(:verb) ? es_req[:verb] : :get
      verb = verb.downcase.to_sym

      unless @verbs.key?( verb )
        raise ArgumentError, 'E_BAD_VERB'
      end
      return verb
    end

    def get_path_for_es_req(es_req = {})
      parts = []
      has_index = false

      if es_req.key? :path
        es_req[:path].is_a?(Array) \
          ? parts.push(*es_req[:path]) \
          : parts.push("#{es_req[:path]}")
      else
        if es_req.key? :index
          parts.push "#{es_req[:index]}"
          has_index = true
        end
        parts.push("#{es_req[:type]}") if es_req.key?(:type)
        parts.push("#{es_req[:id]}") if es_req.key?(:id)
      end

      path = parts.join('/').strip.gsub(/\/+/,'/')

      if (path.index('/')!=0 || !has_index) && ( @index.is_a?(String) && @index.length>0 )
        path = "#{@index}/#{path}"
      end
      return path
    end

    def get_body_for_es_req(es_req = {})
      return nil unless es_req.key? :body

      json = es_req[:body].is_a?(Hash)    \
        ? MultiJson.encode(es_req[:body]) \
        : "#{es_req[:body]}".strip

      return json == '{}' || json.length < 1 \
        ? nil : json
    end

    alias_method :rad_index, :index
    alias_method :rad_request, :request
    alias_method :rad_request_all, :request_all
  end
end