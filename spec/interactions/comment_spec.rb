# frozen_string_literal: true

require "spec_helper"

RSpec.describe LinkedinOrbit::Interactions::Comment do
  let(:subject) do
    LinkedinOrbit::Interactions::Comment.new(
      title: "Sample Title",
      comment: {
        "id" => "12345",
        "created" => {
          "time" => 1456959600000
        },
        "actor" => "1234567",
        "actor~" => {
          "localizedFirstName" => "John",
          "localizedLastName" => "Smith"
        },
        "message" => {
          "text" => "Sample Text"
        },
        "object" => "urn:li:activity:6793941564394651648"
      },
      orbit_workspace: "1234",
      orbit_api_key: "12345"
    )
  end

  describe "#call" do
    context "when the type is a comment" do
      it "returns a Comment Object" do
        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            headers: { 'Authorization' => "Bearer 12345", 'Content-Type' => 'application/json' },
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"Sample Title...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Sample Text\\\"\\n\",\"occurred_at\":\"2016-03-02 23:00:00 UTC\",\"key\":\"12345\",\"link\":\"https://www.linkedin.com/feed/update/urn:li:activity:6793941564394651648\",\"member\":{\"name\":\"John Smith\"}},\"identity\":{\"source\":\"linkedin\",\"name\":\"John Smith\",\"uid\":\"1234567\"}}"
          )
          .to_return(
            status: 200,
            body: {
              response: {
                code: 'SUCCESS'
              }
            }.to_json.to_s
          )

        content = subject.construct_body

        expect(content[:activity][:key]).to eql("12345")
      end
    end
  end
end