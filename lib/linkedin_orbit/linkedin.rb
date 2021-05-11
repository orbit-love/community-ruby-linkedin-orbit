# frozen_string_literal: true

module LinkedinOrbit
  class Linkedin
    def initialize(params = {})
      @linkedin_organization = params.fetch(:linkedin_organization)
      @linkedin_token = params.fetch(:linkedin_token)
      @orbit_api_key = params.fetch(:orbit_api_key)
      @orbit_workspace = params.fetch(:orbit_workspace)
    end

    def process_comments
      posts = get_posts

      posts.each do |post|
        comments = get_post_comments(post["id"])

        comments.reject! { |comment| comment["actor~"]["id"] == "private" }

        next if comments.nil? || comments.empty?

        comments.each do |comment|
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
      end
    end

    def get_posts
      posts = []
      url = URI("https://api.linkedin.com/v2/shares?q=owners&owners=#{@linkedin_organization}")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{@linkedin_token}"

      response = https.request(request)

      response = JSON.parse(response.body)
      
      response["elements"].each do |element|
        posts << {
          "id" => element["activity"],
          "message_highlight" => element["text"]["text"][0, 40]
        }
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
  end
end
