require "digest/sha2"
require "base64"
require "cgi"
require 'net/http'
require 'uri'
require 'rubygems'
require "httparty"
require 'json'
require 'pp'

USER_HOST = "http://sas.ooyala.com"
API_KEY = "xxkdkd"
SECRET = "xxkdkd"
PCODE = "xxkdkd"
# expires 1 year from now
t = Time.now
EXPIRES = Time.local(t.year + 1, t.mon, t.day, t.hour).to_i
ADMIN_HOST = "http://rl.ooyala.com"
ACCOUNT_ID = "faxs6"

def generate_signature(secret, http_method, request_path, query_string_params, request_body)
  string_to_sign = secret + http_method + request_path
  sorted_query_string = query_string_params.sort { |pair1, pair2| pair1[0] <=> pair2[0] }
  string_to_sign += sorted_query_string.map { |key, value| "#{key}=#{value}"}.join
  string_to_sign += request_body.to_s
  signature = Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42].chomp("=")
  return signature
end

def api(type, action, resource, body=nil, public_device_id=nil)
  puts "\n**********#{type} apis: #{action} #{resource} request*********"
  if type == "user"
    path = "/v2/entitlements/providers/#{PCODE}/accounts/#{ACCOUNT_ID}/#{resource}"
    host = USER_HOST
  else
    path = "/v2/entitlements/providers/#{PCODE}/accounts/#{ACCOUNT_ID}/#{resource}"
    host = ADMIN_HOST
  end
  path += "/#{public_device_id}" if public_device_id
  params = { "api_key" => API_KEY, "expires" => EXPIRES }
  signature = generate_signature(SECRET, action, path, params, body)
  params_string = params.map { |key, value| "#{key}=#{value}"}.join("&")
  params_string += "&signature=#{CGI::escape(signature)}"
  url = "#{host}#{path}?#{params_string}"
  puts url
  puts "\n*********#{type} apis: #{action} #{resource} response*********"
  if action == "GET"
    result = HTTParty.get(url)
  elsif action == "PUT"
    result = HTTParty.put(url, :body => body)
  elsif action == "PATCH"
    result = HTTParty.patch(url, :body => body)
  elsif action == "POST"
    result = HTTParty.post(url, :body => body)
elsif action == "DELETE"
    result = HTTParty.delete(url, :body => body)
  end
  begin
    pp JSON.parse(result)
    return JSON.parse(result)
  rescue
    puts result
    return result
  end
end


#entitle user
api("admin", "POST", "content", {
  "assets" => [    {
    "end_time" => "2013-11-17T08:16:43+00:00",
    "start_time" => "2013-08-14T08:16:43+00:00",
    "updated_at" => "2013-08-14T08:16:46+00:00",
    "content_id" => "c4Zmc4ZDqgR5if3wPBJ_FgHW_wlgbJui",
    "publishing_rule_id" => "ecbcea7024c445de902eee52dfc3b8a7",
    "external_product_id" => "default"
   }   ]
}.to_json )
