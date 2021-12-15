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

  describe "#process_comments" do
    context "with historical import set to false and no newer items than the latest activity for the type in LinkedIn" do
      it "posts no new comments to the Orbit workspace from LinkedIn" do
        stub_request(:get, "https://app.orbit.love/api/v1/1234/activities?activity_type=custom:linkedin:comment&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-07-01T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(subject).to receive(:get_posts).and_return(post_stub)
        allow(subject).to receive(:get_post_comments).and_return(comment_stub)

        expect(subject.process_comments).to eql("Sent 0 new comments to your Orbit workspace")
      end
    end

    context "with historical import set to false and newer items than the latest activity for the type in Orbit" do
      it "posts the newer items to the Orbit workspace from LinkedIn" do
        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"A highlight...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Some text\\\"\\n\",\"occurred_at\":\"2021-06-28 16:43:34 UTC\",\"key\":\"12345\",\"link\":\"https://www.linkedin.com/feed/update/\",\"member\":{\"name\":\" \"}},\"identity\":{\"source\":\"linkedin\",\"name\":\" \",\"uid\":null}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"Another highlight...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Some text\\\"\\n\",\"occurred_at\":\"2021-06-28 16:43:34 UTC\",\"key\":\"12345\",\"link\":\"https://www.linkedin.com/feed/update/\",\"member\":{\"name\":\" \"}},\"identity\":{\"source\":\"linkedin\",\"name\":\" \",\"uid\":null}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:get, "https://app.orbit.love/api/v1/1234/activities?activity_type=custom:linkedin:comment&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-26T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(subject).to receive(:get_posts).and_return(post_stub)
        allow(subject).to receive(:get_post_comments).and_return(comment_stub)

        expect(subject.process_comments).to eql("Sent 1 new comments to your Orbit workspace")
      end
    end

    context "with historical import set to true" do
      it "posts all items to the Orbit workspace from LinkedIn" do
        client = LinkedinOrbit::Linkedin.new(
          linkedin_organization: "org",
          linkedin_token: "abc123",
          orbit_api_key: "12345",
          orbit_workspace: "1234",
          historical_import: true
        )

        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"A highlight...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Some text\\\"\\n\",\"occurred_at\":\"2021-06-28 16:43:34 UTC\",\"key\":\"12345\",\"link\":\"https://www.linkedin.com/feed/update/\",\"member\":{\"name\":\" \"}},\"identity\":{\"source\":\"linkedin\",\"name\":\" \",\"uid\":null}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})
        
        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"A highlight...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Some more text\\\"\\n\",\"occurred_at\":\"2021-06-17 02:56:54 UTC\",\"key\":\"456789\",\"link\":\"https://www.linkedin.com/feed/update/\",\"member\":{\"name\":\" \"}},\"identity\":{\"source\":\"linkedin\",\"name\":\" \",\"uid\":null}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"Another highlight...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Some text\\\"\\n\",\"occurred_at\":\"2021-06-28 16:43:34 UTC\",\"key\":\"12345\",\"link\":\"https://www.linkedin.com/feed/update/\",\"member\":{\"name\":\" \"}},\"identity\":{\"source\":\"linkedin\",\"name\":\" \",\"uid\":null}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:post, "https://app.orbit.love/api/v1/1234/activities")
          .with(
            body: "{\"activity\":{\"activity_type\":\"linkedin:comment\",\"tags\":[\"channel:linkedin\"],\"title\":\"Commented on LinkedIn Post\",\"description\":\"LinkedIn post: \\\"Another highlight...\\\"\\n\\n\\nComment:\\n\\n\\n\\\"Some more text\\\"\\n\",\"occurred_at\":\"2021-06-17 02:56:54 UTC\",\"key\":\"456789\",\"link\":\"https://www.linkedin.com/feed/update/\",\"member\":{\"name\":\" \"}},\"identity\":{\"source\":\"linkedin\",\"name\":\" \",\"uid\":null}}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "Content-Type" => "application/json",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          ).to_return(status: 200, body: {
            response: {
              code: "SUCCESS"
            }
          }.to_json.to_s, headers: {})

        stub_request(:get, "https://app.orbit.love/api/v1/1234/activities?activity_type=custom:linkedin:comment&direction=DESC&items=10")
          .with(
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer 12345",
              "User-Agent" => "community-ruby-linkedin-orbit/#{LinkedinOrbit::VERSION}"
            }
          )
          .to_return(
            status: 200,
            body: {
              data: [
                {
                  id: "6",
                  type: "spec_activity",
                  attributes: {
                    action: "spec_action",
                    created_at: "2021-06-26T16:03:02.052Z",
                    key: "spec_activity_key#1",
                    occurred_at: "2021-04-01T16:03:02.050Z",
                    type: "SpecActivity",
                    tags: "[\"spec-tag-1\"]",
                    orbit_url: "https://localhost:3000/test/activities/6",
                    weight: "1.0"
                  },
                  relationships: {
                    activity_type: {
                      data: {
                        id: "20",
                        type: "activity_type"
                      }
                    }
                  },
                  member: {
                    data: {
                      id: "3",
                      type: "member"
                    }
                  }
                }
              ]
            }.to_json.to_s,
            headers: {}
          )

        allow(client).to receive(:get_posts).and_return(posts_stub)
        allow(client).to receive(:get_post_comments).and_return(comments_stub)

        expect(client.process_comments).to eql("Sent 4 new comments to your Orbit workspace")
      end
    end
  end

  describe "#get_posts" do
    context "with no posts to process" do
      it "returns a string message" do
        stub_request(:get, "https://api.linkedin.com/v2/ugcPosts?authors=List(org)&count=100&q=authors&sortBy=LAST_MODIFIED&start=0")
          .with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer abc123',
              'Content-Type'=>'application/json',
              'Host'=>'api.linkedin.com',
              'User-Agent'=>'Ruby',
              'X-Restli-Protocol-Version'=>'2.0.0'
            }
          )
          .to_return(status: 200, body: "{\"paging\":{\"start\":0,\"count\":100,\"links\":[{\"type\":\"application/json\",\"rel\":\"prev\",\"href\":\"/v2/ugcPosts?q=authors&start=0&count=100&sortBy=LAST_MODIFIED&authors=List(org)\"}],\"total\":0},\"elements\": []}", headers: {})

        expect(subject.get_posts).to eql("No new posts to process from your LinkedIn organization.\nIf you suspect this is incorrect, verify your LinkedIn organization schema is correct in your credentials.\n")
      end
    end

    context "with posts to process" do
      it "returns them in the right formatting at the end of the method" do
        stub_request(:get, "https://api.linkedin.com/v2/ugcPosts?authors=List(org)&count=100&q=authors&sortBy=LAST_MODIFIED&start=0")
          .with(
            headers: {
              'Accept'=>'application/json',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer abc123',
              'Content-Type'=>'application/json',
              'Host'=>'api.linkedin.com',
              'User-Agent'=>'Ruby',
              'X-Restli-Protocol-Version'=>'2.0.0'
            }
          )
          .to_return(status: 200, body: "{\"paging\":{\"start\":0,\"count\":100,\"links\":[{\"type\":\"application/json\",\"rel\":\"prev\",\"href\":\"/v2/ugcPosts?q=authors&start=0&count=100&sortBy=LAST_MODIFIED&authors=List(org)\"}],\"total\":1},\"elements\": [{\"owner\": \"org\", \"id\": \"activity-123\", \"specificContent\": { \"com.linkedin.ugc.ShareContent\" : { \"shareCommentary\" : {\"text\": \"LinkedIn Post Body\"}}}}]}", headers: {})

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

  def post_stub
    [
      {
        "id" => "123abcd",
        "message_highlight" => "A highlight"
      }
    ]
  end

  def posts_stub
    [
      {
        "id" => "123abcd",
        "message_highlight" => "A highlight"
      },
      {
        "id" => "1234zerbfd",
        "message_highlight" => "Another highlight"
      }
    ]
  end

  def comment_stub
    [
      {
        "id" => "12345",
        "actor~" => {
          "id" => "abc1234"
        },
        "created" => {
          "time" => 1_624_898_614_231
        },
        "message" => {
          "text" => "Some text"
        }
      }
    ]
  end

  def comments_stub
    [
      {
        "id" => "12345",
        "actor~" => {
          "id" => "abc1234"
        },
        "created" => {
          "time" => 1_624_898_614_231
        },
        "message" => {
          "text" => "Some text"
        }
      },
      {
        "id" => "456789",
        "actor~" => {
          "id" => "abcd5678"
        },
        "created" => {
          "time" => 1_623_898_614_232
        },
        "message" => {
          "text" => "Some more text"
        }
      }
    ]
  end
end
