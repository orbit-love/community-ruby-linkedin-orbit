# frozen_string_literal: true

require "net/http"
require "json"

module LinkedinOrbit
  module Interactions
    class Comment
      def initialize(title:, comment:, orbit_workspace:, orbit_api_key:)
        @title = title
        @comment = comment
        @orbit_workspace = orbit_workspace
        @orbit_api_key = orbit_api_key

        after_initialize!
      end

      def after_initialize!
        url = URI("https://app.orbit.love/api/v1/#{@orbit_workspace}/activities")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(url)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{@orbit_api_key}"

        request.body = construct_body.to_json

        response = http.request(request)

        JSON.parse(response.body)
      end

      def construct_body
        {
          activity: {
            activity_type: "linkedin:comment",
            tags: ["channel:linkedin"],
            title: "Commented on LinkedIn Post",
            description: construct_description,
            occurred_at: Time.at(@comment["created"]["time"] / 1000).utc,
            key: @comment["id"],
            link: "https://www.linkedin.com/feed/update/#{@comment["object"]}",
            member: {
              name: name
            }
          },
          identity: {
            source: "linkedin",
            name: name,
            uid: @comment["actor"]
          }
        }
      end

      def name
        @name ||= begin
          return @comment["actor~"]["localizedName"] if @comment["actor~"]["localizedName"]

          "#{@comment["actor~"]["localizedFirstName"]} #{@comment["actor~"]["localizedLastName"]}"
        end
      end

      def construct_description
        <<~HEREDOC
          LinkedIn post: "#{@title}..."
          \n
          Comment:
          \n
          "#{@comment["message"]["text"]}"
        HEREDOC
      end
    end
  end
end
