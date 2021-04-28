# frozen_string_literal: true

require 'dotenv/load'
require "net/http"
require "json"

def token
    ENV['LINKEDIN_TOKEN']
end

def get_shares_ids
    ids = []
    url = URI("https://api.linkedin.com/v2/shares?q=owners&owners=#{ENV['LINKEDIN_ORGANIZATION']}")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{token}" 

    response = https.request(request)

    response = JSON.parse(response.body)

    response["elements"].each do |element|
        shares << element["activity"]    
    end

    ids
end

def get_commenter_info(id)
    url = URI("https://api.linkedin.com/v2/socialActions/#{id}/comments?projection=(elements(*(*,actor~(*,profilePicture(displayImage~:playableStreams)))))")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{token}"

    response = https.request(request)

    response = JSON.parse(response.body)
end