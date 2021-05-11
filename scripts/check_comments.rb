#!/usr/bin/env ruby
# frozen_string_literal: true

require "linkedin_orbit"
require "thor"

module LinkedinOrbit
  module Scripts
    class CheckComments < Thor
      desc "render", "check for new LinkedIn post comments and push them to Orbit"
      def render
        client = LinkedinOrbit::Client.new
        client.comments
      end
    end
  end
end