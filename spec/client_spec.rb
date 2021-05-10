# frozen_string_literal: true

require "spec_helper"

RSpec.describe LinkedinOrbit::Client do
  let(:subject) do
    LinkedinOrbit::Client.new(
      orbit_api_key: "12345",
      orbit_workspace: "test",
      linkedin_organization: "urn:li:organization:123456789",
      linkedin_code: "QA123456789"
    )
  end

  it "initializes with arguments passed in directly" do
    expect(subject).to be_truthy
  end

  it "initializes with credentials from environment variables" do
    allow(ENV).to receive(:[]).with("ORBIT_API_KEY").and_return("12345")
    allow(ENV).to receive(:[]).with("ORBIT_WORKSPACE").and_return("test")
    allow(ENV).to receive(:[]).with("LINKEDIN_ORGANIZATION").and_return("urn:li:organization:123456789")
    allow(ENV).to receive(:[]).with("LINKEDIN_CODE").and_return("QA123456789")

    expect(LinkedinOrbit::Client).to be_truthy
  end
end