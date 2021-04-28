# frozen_string_literal: true

require 'dotenv/load'
require "net/http"
require "json"

def token
    ENV['LINKEDIN_TOKEN']
end

def get_linkedin_activities
    activities = []
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
        activities << {
            "id" => element["activity"],
            "message_highlight" => element["text"]["text"][0, 40]
        }    
    end

    activities
end

def comments(activities)
    activities.each do |activity|
        comments = get_commenters(activity["id"])

        process_comments(comments["elements"], activity["message_highlight"]) unless comments["elements"].nil? || comments["elements"].empty?
    end
end

def get_commenters(id)
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

def process_comments(comments, message_highlight)
    comments.each do |comment|
        activity_params = construct_activity(comment, message_highlight)
        send_to_orbit(activity_params)
    end
end

def send_to_orbit(activity_params)
    url = URI("https://app.orbit.love/api/v1/#{ENV['ORBIT_WORKSPACE_ID']}/activities")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(url)
    req["Accept"] = "application/json"
    req["Content-Type"] = "application/json"
    req["Authorization"] = "Bearer #{ENV['ORBIT_API_KEY']}"

    req.body = activity_params.to_json

    response = http.request(req)

    JSON.parse(response.body)
end

def construct_activity(comment, message_highlight)
    {
        "activity": {
            "activity_type": "linkedin:comment",
            "title": "New comment on LinkedIn Post: #{message_highlight}",
            "description": comment["message"]["text"],
            "occurred_at": Time.at(comment["created"]["time"] / 1000),
            "member": {
                "name": "#{comment["actor~"]["localizedFirstName"]} #{comment["actor~"]["localizedLastName"]}"
            }
        },
        "identity": {
            "source": "linkedin",
            "name": "#{comment["actor~"]["localizedFirstName"]} #{comment["actor~"]["localizedLastName"]}",
            "uid": comment["actor"]
        }
    }
end

def call
    activities = get_linkedin_activities
    comments(activities)
end

call