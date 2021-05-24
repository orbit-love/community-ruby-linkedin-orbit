# frozen_string_literal: true

require "zeitwerk"
require "orbit_activities"
require_relative "linkedin_orbit/version"

module LinkedinOrbit
  loader = Zeitwerk::Loader.new
  loader.tag = File.basename(__FILE__, ".rb")
  loader.push_dir(__dir__)
  loader.setup
end
