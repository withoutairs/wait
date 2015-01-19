require 'bundler/setup'
Bundler.require

require_relative 'lib/credentials'
require_relative 'lib/mint'

credentials = Credentials.new
credentials.validate!

mint = Mint.new(credentials)
mint.authenticate
File.open("mint-transactions.csv", 'w') { |file| file.write(mint.csv_with_bug_6_workaround) }
