require 'restforce'
require 'facets/hash/rekey'
require "#{Rails.root}/lib/faraday_custom_headers.rb"

module SalesforceService
  # encapsulate all Salesforce querying functions in one handy service
  class Base
    @retries = 1
    @headers = nil

    Faraday::Middleware.register_middleware(
      custom_headers: CustomHeaders,
    )

    def self.client
      Restforce.new
    end

    def self.oauth_client
      client = Restforce.new(
        authentication_retries: 0,
        oauth_token: oauth_token,
        instance_url: ENV['SALESFORCE_INSTANCE_URL'],
        mashify: false,
      )
      client.middleware.use :custom_headers, @headers if @headers.present?
      client
    end

    # run a Salesforce SOQL query
    def self.query(q)
      client.query(q)
    end

    def self.api_call(method = :get, endpoint, params, parse_response)
      endpoint = "/services/apexrest#{endpoint}"
      response = oauth_client.send(method, endpoint, params)
      if parse_response
        massage(flatten_response(response.body))
      else
        response.body
      end
    rescue Restforce::UnauthorizedError
      if @retries > 0
        @retries -= 1
        oauth_token(true)
        retry
      else
        p 'UH OH -- Restforce error'
        []
      end
    rescue StandardError => e
      p "UH OH -- StandardError #{e.message}"
      []
    end

    def self.api_get(endpoint, params = nil, parse_response = false)
      api_call(:get, endpoint, params, parse_response)
    end

    def self.api_post(endpoint, params = nil, parse_response = false)
      api_call(:post, endpoint, params, parse_response)
    end

    def self.oauth_token(force = false)
      Rails.cache.fetch('salesforce_oauth_token', force: force) do
        auth = client.authenticate!
        auth.access_token
      end
    end

    # move all listing attributes to the root level of the hash
    # this is partly to not have to totally refactor our JS code
    # after Salesforce changes w/ ListingDetails
    def self.flatten_response(body)
      body.collect do |listing|
        listing.merge(listing['listing'] || {}).except('listing')
      end
    end

    # recursively remove "__c" and "__r" from all keys
    def self.massage(h)
      if h.is_a?(Hash)
        hash_massage(h)
      elsif h.is_a?(Array) or h.is_a?(Restforce::Collection)
        h.map { |i| massage(i) }
      elsif h.is_a?(Symbol) or h.is_a?(String)
        string_massage(h)
      else
        h
      end
    end

    def self.hash_massage(h)
      return h['records'].map { |i| massage(i) } if h.include?('records')
      # massage each hash value
      h.each { |k, v| h[k] = massage(v) }
      # massage each hash key
      h.rekey do |key|
        massage(key)
      end
    end

    def self.string_massage(str)
      # calls .to_s so it works for symbols too
      str.to_s.gsub('__c', '').gsub('__r', '')
    end
  end
end
