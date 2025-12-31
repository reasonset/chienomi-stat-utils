#!/usr/bin/ruby
require_relative 'apache-log-parser'

log = nil
opts = parse_argopts

if opts["marshal"]
  log = Marshal.load File.read opts["marshal"]
else
  log = Parser.parse(ARGF)
end

classified = Hash.new(0)

STDERR.puts "...LOGS TOTAL #{log.size}"

log = Parser.exclude_bots log
STDERR.puts "...LOGS WITHOUT BOT #{log.size}"

log = Parser.exclude_notok log
STDERR.puts "...LOGS WITHOUT NON-OK #{log.size}"

log.reject! do |i|
  !i.resource.include?("/articles/") && !i.resource.include?("/archives/")
end
STDERR.puts "...LOGS WITHOUT NON-ARTICLE #{log.size}"

log.each do |i|
  classified[i.time.strftime("%Y-%m")] += 1
end

keys = classified.keys.sort

keys.each do |k|
  printf("%s %d \n", k, classified[k])
end
