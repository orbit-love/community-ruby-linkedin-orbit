OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true
OmniAuth.config.on_failure = Proc.new do |env|
    SessionsController.action(:code).call(env)
  end

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :linkedin, ENV['LINKEDIN_CLIENT_ID'], ENV['LINKEDIN_CLIENT_SECRET'], :scope => 'r_organization_social'
  end