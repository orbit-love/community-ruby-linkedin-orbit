require 'linkedin'
require 'dotenv/load'

module LinkedinOrbit
    class Client
        attr_accessor :orbit_api_key, :orbit_workspace, :linkedin_token

        def initialize(params = {})
            @orbit_api_key = params.fetch(:orbit_api_key, ENV['ORBIT_API_KEY'])
            @orbit_workspace = params.fetch(:orbit_workspace, ENV['ORBIT_WORKSPACE_ID'])
            @linkedin_client_id = params.fetch(:linkedin_client_id, ENV['LINKEDIN_CLIENT_ID'])
            @linkedin_client_secret = params.fetch(:linkedin_client_secret, ENV['LINKEDIN_CLIENT_SECRET'])
            @linkedin_token = token
            @linkedin_organization = params.fetch(:linkedin_organization, ENV['LINKEDIN_ORGANIZATION'])
        end

        def token
            @token ||= begin
                return ENV['LINKEDIN_TOKEN'] if ENV['LINKEDIN_TOKEN']

                linkedin = LinkedIn::Client.new(@linkedin_client_id, @linkedin_client_secret)
                # need an accessible redirect url for linkedin to send the code parameter used to then retrieve the auth token, i.e. ngrok
                linkedin.authorize_url(:redirect_uri => 'ngrok...', :state => SecureRandom.uuid, :scope => "r_organization_social")
                # need to get the params[:code] from previous line for this method:
                # linkedin.authorize_from_request(params[:code], :redirect_uri => "ngrok...")
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