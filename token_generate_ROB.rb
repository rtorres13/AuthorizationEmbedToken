#!/usr/bin/env ruby

# This is a tool used to generate embed token signature given the provider api_key, secret, pcode,
# list of embed codes, a	nd expiration

require "base64"
require "digest/sha2"
require 'digest/md5'
require "cgi"
require "open-uri"
require "optparse"
require "rubygems"
require "json"

def generate_signature(secret, pcode, embedCodes, api_key, expires, signature_hashing_method="SHA256", return_json=1)
  $epoch = (Time.now + expires.to_i).to_i
  string_to_sign = "#{secret}GET/sas/embed_token/#{pcode}/#{embedCodes}api_key=#{api_key}expires=#{$epoch}"
  string_to_sign += "return_json=#{return_json}" if return_json
  puts "Using #{signature_hashing_method} to sign: #{string_to_sign}"	

  if signature_hashing_method == "MD5"
    p "Signing with MD5...."
    return Base64::encode64(Digest::MD5.digest(string_to_sign))[0..42]
  else
    p "Signing with SHA256...."
    #digest = Digest::SHA256.digest(string_to_sign)
    #signature = Base64::encode64(digest).chomp.gsub(/=+$/, '')
    #signature = CGI.escape(signature)
    #return signature
    return Base64::encode64(Digest::SHA256.digest(string_to_sign))[0..42]
  end
end

def image_request(server, pcode, embedCodes,api_key, signature, return_json)
  url = "http://#{server}/embed_token/#{pcode}/#{embedCodes}?api_key=#{api_key}&expires=#{$epoch}&signature=#{signature}"
  url += "&return_json=#{return_json}" if return_json
  return url
end

options = {}
ARGV.options do |opts|
    opts.on("-e", "--embed embed", String) do |embedCode|
      options[:embed_code] = embedCode
    end
    	
    opts.on("-p", "--pcode pcode", String) do |pcode|
      options[:pcode] = pcode
    end
    
    opts.on("-a", "--api_key key", String) do |api_key|
      options[:api_key] = api_key
    end
    
    opts.on("-s", "--secret secret", String) do |api_secret|
      options[:secret] = api_secret
    end

    opts.on("-h", "--signature_hashing_method signature_hashing_method", String) do |signature_hashing_method|
      options[:signature_hashing_method] = signature_hashing_method
    end

    opts.on("-i", "--expires expires", String) do |expires|
      options[:expires] = expires
    end

    opts.on("-j", "--json auth token", String) do |return_json|
      options[:return_json] = return_json
    end

    opts.parse!
end

api_key = options[:api_key] || "xxkdkd"
embed_code = options[:embed_code] || "xxkdkd"
pcode = options[:pcode] || "xxkdkd"
api_secret = options[:secret] || "xxkdkd"
expires = options[:expires] || "1340637529" # in seconds
signature_hashing_method = options[:signature_hashing_method] || "SHA256"
return_json = options[:return_json]
UUID = "40a52ba5-1e32-4a34-954f-83cc4604e591"

sig = generate_signature(api_secret, pcode, embed_code, api_key, expires, signature_hashing_method, return_json)
embed_url = image_request("player.ooyala.com/sas", pcode, embed_code, api_key, sig, return_json)
puts "embedToken Url is : \n#{embed_url}"

