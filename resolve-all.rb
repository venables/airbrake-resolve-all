#!/usr/bin/env ruby
# http://github.com/mattv/airbrake-resolve-all

API_KEY = 'abc123abc123abc123'
SUBDOMAIN = 'my-app'

require 'rubygems'
require 'rest_client'
require 'crack'

class AirbrakeResolver
  def initialize(key, site)
    @key, @site = key, site
  end
  
  def url(error_id=nil)
    url = "http://#{@site}.airbrake.io/errors"
    url += "/#{error_id}" unless error_id.nil?
    url += "?auth_token=#{@key}"
  end
        
  def clean        
    errors = self.get_errors
    return if errors.nil? || errors.empty?
            
    errors.each { |error| self.resolve error }
    self.clean
  end
  
  def get_errors
    data = RestClient.get(url) || ''
    parsed_data = Crack::XML.parse(data) || {}
    parsed_data['groups']
  end
  
  def resolve(error)
    puts "Resolving #{error['id']}: #{error['error_message']}"
    RestClient.put(url(error['id']), :group => { :resolved => true }, :auth_token => @key)
  end
  
end

resolver = AirbrakeResolver.new(API_KEY, SUBDOMAIN)
resolver.clean
