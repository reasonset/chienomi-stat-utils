#!/usr/bin/ruby
require_relative 'apache-log-parser'

log = Parser.parse(ARGF)

puts "***** BOT CHECK *****"
Parser.exclude_bots_check log

puts
puts "***** NOT OK *****"
Parser.exclude_notok_check log
