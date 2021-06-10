# frozen_string_literal: true

require "spec_helper"

RSpec.describe LinkedinOrbit::Linkedin do
  let(:subject) do
    LinkedinOrbit::Linkedin.new(
      linkedin_organization: "org",
      linkedin_token: "abc123",
      orbit_api_key: "12345",
      orbit_workspace: "1234"
    )
  end

  describe "#get_posts" do
    context "with no posts to process" do
      it "returns a string message" do
        stub_request(:get, "https://api.linkedin.com/v2/shares?owners=org&q=owners").
        with(
          headers: {
          'Accept'=>'application/json',
          'Authorization'=>'Bearer abc123',
          'Content-Type'=>'application/json',
          }).
        to_return(status: 200, body: "{\"elements\": []}", headers: {})

        expect(subject.get_posts).to eql("No new posts to process from your LinkedIn organization.\nIf you suspect this is incorrect, verify your LinkedIn organization schema is correct in your credentials.\n")
      end
    end

    context "with posts to process" do
      it "returns them in the right formatting at the end of the method" do
        stub_request(:get, "https://api.linkedin.com/v2/shares?owners=org&q=owners").
        with(
          headers: {
          'Accept'=>'application/json',
          'Authorization'=>'Bearer abc123',
          'Content-Type'=>'application/json',
          }).
        to_return(status: 200, body: "{\"elements\": [{\"owner\": \"org\", \"activity\": \"activity-123\", \"text\": {\"text\": \"LinkedIn Post Body\"}}]}", headers: {})
        
        expect(subject.get_posts).to eql(
          [
            {
              "id" => "activity-123",
              "message_highlight" => "LinkedIn Post Body"
            }
          ]
        )
      end
    end
  end
end