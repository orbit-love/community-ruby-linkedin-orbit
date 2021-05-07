# frozen_string_literal: true

require "linkedin"
require "dotenv/load"

# Create a client to log LinkedIn interactions in your Orbit workspace
# Credentials can either be passed in to the instance or be loaded
# from environment variables
#
# @example
#   client = LinkedinOrbit::Client.new
#
# @option params [String] :orbit_api_key
#   The API key for the Orbit API
#
# @option params [String] :orbit_workspace
#   The workspace ID for the Orbit workspace
#
# @option params [String] :linkedin_client_id
#   The Client ID for your LinkedIn Developers Access
#   More details on obtaining it at https://www.linkedin.com/developers/
#
# @option params [String] :linkedin_client_secret
#   The Client Secret for your LinkedIn Developers Access
#   More details on obtaining it at https://www.linkedin.com/developers/
#
# @option params [String] :linkedin_organization
#   The LinkedIn schema for the LinkedIn organization to log interactions from
#   For example, a company on LinkedIn with the web address of:
#   "https://www.linkedin.com/company/28866695"
#   The LinkedIn organization would use the last component of that web address and would be:
#   urn:li:organization:28866695
#
# @param [Hash] params
#
# @return [DevOrbit::Client]
#
module LinkedinOrbit
  class Client
    attr_accessor :orbit_api_key, :orbit_workspace, :linkedin_organization
    attr_reader :linkedin_token

    def initialize(params = {})
      @orbit_api_key = params.fetch(:orbit_api_key, ENV["ORBIT_API_KEY"])
      @orbit_workspace = params.fetch(:orbit_workspace, ENV["ORBIT_WORKSPACE_ID"])
      @linkedin_token = token
      @linkedin_organization = params.fetch(:linkedin_organization, ENV["LINKEDIN_ORGANIZATION"])
    end

    def token
      @token ||= begin
        return ENV["LINKEDIN_TOKEN"] if ENV["LINKEDIN_TOKEN"]

        linkedin = LinkedIn::Client.new(@linkedin_client_id, @linkedin_client_secret)
        linkedin.authorize_from_access(ENV["LINKEDIN_CODE"])
      end
    end

    def comments
      LinkedinOrbit::Linkedin.new(
        linkedin_token: @linkedin_token,
        linkedin_organization: @linkedin_organization,
        orbit_api_key: @orbit_api_key,
        orbit_workspace: @orbit_workspace
      ).process_comments
    end
  end
end
