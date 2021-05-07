# frozen_string_literal: true

module LinkedinOrbit
  class Orbit
    def self.call(type:, data:, orbit_workspace:, orbit_api_key:)
      if type == "comments"
        LinkedinOrbit::Interactions::Comment.new(
          title: data[:title].gsub("\n", " "),
          comment: data[:comment],
          orbit_workspace: orbit_workspace,
          orbit_api_key: orbit_api_key
        )
      end
    end
  end
end
