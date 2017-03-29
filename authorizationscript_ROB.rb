require "digest/sha2"
require "base64"
require "cgi"
require 'net/http'
require 'uri'
require 'rubygems'
require 'json'
require 'pp'

PLAYER_HOST = "http://player.ooyala.com"
SAS_HOST = "http://sas.ooyala.com"
API_KEY = "xxkdkd"
SECRET = "xxkdkd"
PCODE = "xxkdkd"
ACCOUNT_ID = "40a52ba5-1e32-4a34-954f-83cc4604e591"
EMBED_CODE = "VkNXJveTpLgwTVBKPpLfbaXnBt93c_Mw"
# EMBED_CODE ="VkNXJveTpLgwTVBKPpLfbaXnBt93c_Mw"
SUPPORTED_FORMATS = "ALL"
# expires 1 year from now
t = Time.now
EXPIRES = Time.local(t.year + 1, t.mon, t.day, t.hour).to_i

def generate_signature(secret, http_method, request_path, query_string_params, request_body)
  string_to_sign = secret + http_method + request_path
  sorted_query_string = query_string_params.sort { |pair1, pair2| pair1[0] <=> pair2[0] }
  puts "request_path"
  puts request_path
  puts "query param"
  pp query_string_params
  string_to_sign += sorted_query_string.map { |key, value| "#{key}=#{value}"}.join
  string_to_sign += request_body.to_s

  signature = Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42].chomp("=")
  return signature
end


def generate_embed_token
  path = "/sas/embed_token/#{PCODE}/#{EMBED_CODE}"
  params = { "api_key" => API_KEY, "expires" => EXPIRES, "return_json" => "1" }
  signature = generate_signature(SECRET, "GET", path, params, nil)
  params_string = params.map { |key, value| "#{key}=#{value}"}.join("&")
  params_string += "&signature=#{CGI::escape(signature)}"
  "#{PLAYER_HOST}#{path}?#{params_string}"
end

def generate_authorization(embed_token)
  path = "/sas/player_api/v1/authorization/embed_code/#{PCODE}/#{EMBED_CODE}"
  params = { "domain" => "test.com", "supported_formats" => SUPPORTED_FORMATS, "embedToken" =>
      CGI.escape(embed_token)}
  params_string = params.map { |key, value| "#{key}=#{value}" }.join("&")
  "#{SAS_HOST}#{path}?#{params_string}"
end

# get the embed token/opt 
puts "\nEMBED TOKEN/OPT"
embed_token = generate_embed_token
puts embed_token

# use the embed token/opt to make an authorization request 
puts "\nAUTHORIZATION REQUEST"
auth_url = generate_authorization(embed_token)
puts auth_url
puts "\nAUTHORIZATION RESPONSE"
auth_result = JSON.parse(Net::HTTP.get(URI.parse(auth_url)))
pp auth_result
