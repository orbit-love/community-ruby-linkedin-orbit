# frozen_string_literal: true

require 'dotenv/load'
require "net/http"
require "json"

require "byebug"

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
            "message_highlight" => element["text"]["text"][0, 20]
        }    
    end

    activities
end

def comments(activities)
    activities.each do |activity|
        comments = get_commenters(activity["id"])

        next if comments.nil? || comments.empty?

        process_comments(comments, activity["message_highlight"])
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
        activity = construct_activity(comment, message_highlight)
    end
end

def construct_activity(comment, message_highlight)
    {
        "activity": {
            "activity_type": "linkedin:comment",
            "title": "New comment on LinkedIn Post: #{message_highlight}",
            "description": comment["elements"][0]["message"]["text"],
            "occurred_at": Time.at(comment["elements"][0]["created"]["time"] / 1000)
        },
        "identity": {
            "source": "linkedin",
            "name": "#{comment["elements"][0]["actor"]["localizedFirstName"]} #{comment["elements"][0]["actor"]["localizedLastName"]}",
            "uid": comment["elements"][0]["actor"]["actor"]
        }
    }
end

def call
    activities = get_linkedin_activities
    comments(activities)
end

call