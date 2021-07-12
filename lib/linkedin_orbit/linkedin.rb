# frozen_string_literal: true

module LinkedinOrbit
  class Linkedin
    def initialize(params = {})
      @linkedin_organization = params.fetch(:linkedin_organization)
      @linkedin_token = params.fetch(:linkedin_token)
      @orbit_api_key = params.fetch(:orbit_api_key)
      @orbit_workspace = params.fetch(:orbit_workspace)
      @historical_import = params.fetch(:historical_import, false)
    end

    def process_comments
      posts = get_posts

      return posts unless posts.is_a?(Array)

      orbit_timestamp = last_orbit_activity_timestamp
      
      posts.each do |post|
        times = 0

        comments = get_post_comments(post["id"])

        comments.reject! { |comment| comment["actor~"]["id"] == "private" }

        next if comments.nil? || comments.empty?

        comments.each do |comment|
          unless @historical_import && orbit_timestamp
            next if Time.at(comment["created"]["time"] / 1000).utc.to_s < orbit_timestamp unless orbit_timestamp.nil?
          end

          if orbit_timestamp && @historical_import == false
            next if Time.at(comment["created"]["time"] / 1000).utc.to_s < orbit_timestamp
          end

          times += 1

          LinkedinOrbit::Orbit.call(
            type: "comments",
            data: {
              comment: comment,
              title: post["message_highlight"]
            },
            orbit_workspace: @orbit_workspace,
            orbit_api_key: @orbit_api_key
          )
        end

        output = "Sent #{times} new comments to your Orbit workspace"

        puts output
        return output
      end
    end

    def get_posts
      posts = []
      page = 0
      count = 100
      looped_at_least_once = false

      while page >= 0
        url = URI("https://api.linkedin.com/v2/shares?q=owners&owners=#{@linkedin_organization}&start=#{page}&count=#{count}")
        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true

        request = Net::HTTP::Get.new(url)
        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{@linkedin_token}"

        response = https.request(request)

        response = JSON.parse(response.body)

        return response["message"] if response["serviceErrorCode"]

        if response["elements"].nil? || response["elements"].empty?
          return <<~HEREDOC
            No new posts to process from your LinkedIn organization.
            If you suspect this is incorrect, verify your LinkedIn organization schema is correct in your credentials.
          HEREDOC
        end

        response["elements"].each do |element|
          posts << {
            "id" => element["activity"],
            "message_highlight" => element["text"]["text"][0, 40]
          }
        end

        break if response["elements"].count < count

        looped_at_least_once = true
        page += 1 if looped_at_least_once
      end

      posts
    end

    def get_post_comments(id)
      url = URI("https://api.linkedin.com/v2/socialActions/#{id}/comments?projection=(elements(*(*,actor~(*,profilePicture(displayImage~:playableStreams)))))")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@linkedin_token}"

      response = https.request(request)

      response = JSON.parse(response.body)

      response["elements"]
    end

    def last_orbit_activity_timestamp
      @last_orbit_activity_timestamp ||= begin
        OrbitActivities::Request.new(
          api_key: @orbit_api_key,
          workspace_id: @orbit_workspace,
          user_agent: "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}",
          action: "latest_activity_timestamp",
          filters: { activity_type: "custom:linkedin:comment" }
        ).response
      end
    end
  end
end
