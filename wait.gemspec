require "rake"
require File.expand_path("../lib/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name     = "wait"
  spec.version  = Wait::VERSION
  spec.date     = '2014-05-24'
  spec.summary  = "Executes a block until there's a valid result."
  spec.authors  = ["Todd Mazierski"]
  spec.email    = ['todd@generalassemb.ly']
  spec.files    = FileList["lib/**/*.rb"]
  spec.homepage = "http://github.com/toddmazierski/wait"
end
