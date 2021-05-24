# frozen_string_literal: true

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
        OrbitActivities::Request.new(
          api_key: @orbit_api_key,
          workspace_id: @orbit_workspace,
          user_agent: "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}",
          action: "new_activity",
          body: construct_body.to_json
        )
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
