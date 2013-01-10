require "rake"
require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name     = "wait"
  spec.version  = Wait::VERSION
  spec.date     = "2013-01-09"
  spec.summary  = "Executes a block until there's a valid result."
  spec.authors  = ["Todd Mazierski"]
  spec.email    = "todd@paperlesspost.com"
  spec.files    = FileList["lib/**/*.rb"]
  spec.homepage = "http://github.com/paperlesspost/wait"
end
