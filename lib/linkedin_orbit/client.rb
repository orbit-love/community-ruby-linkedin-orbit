# frozen_string_literal: true

require "linkedin"
require "dotenv/load"
require "net/http"
require "json"

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
# @option params [String] :linkedin_token
#   The token obtained after authenticating with LinkedIn
#   Required if value not provided for LINKEDIN_TOKEN environment variable
#
# @option params [String] :linkedin_organization
#   The LinkedIn schema for the LinkedIn organization to log interactions from
#   For example, a company on LinkedIn with the web address of:
#   "https://www.linkedin.com/company/28866695"
#   The LinkedIn organization would use the last component of that web address and would be:
#   urn:li:organization:28866695
#
# @option params [Boolean] :historical_import
#   Whether to do an import of all LinkedIn interactions ignoring latest
#   activity already in the Orbit workspace.
#   Default is false.
#
# @param [Hash] params
#
# @return [DevOrbit::Client]
#
module LinkedinOrbit
  class Client
    attr_accessor :orbit_api_key, :orbit_workspace, :linkedin_organization, :historical_import
    attr_reader :linkedin_token

    def initialize(params = {})
      @orbit_api_key = params.fetch(:orbit_api_key, ENV["ORBIT_API_KEY"])
      @orbit_workspace = params.fetch(:orbit_workspace, ENV["ORBIT_WORKSPACE_ID"])
      @linkedin_token = token
      @linkedin_organization = params.fetch(:linkedin_organization, ENV["LINKEDIN_ORGANIZATION"])
      @historical_import = params.fetch(:historical_import, false)
    end

    def token
      @token ||= ENV["LINKEDIN_TOKEN"]
    end

    def comments
      LinkedinOrbit::Linkedin.new(
        linkedin_token: @linkedin_token,
        linkedin_organization: @linkedin_organization,
        orbit_api_key: @orbit_api_key,
        orbit_workspace: @orbit_workspace,
        historical_import: @historical_import
      ).process_comments
    end
  end
end
