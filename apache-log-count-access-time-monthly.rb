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

log = Parser.exclude_bots log
log = Parser.exclude_notok log

log.each do |i|
  classified[i.time.strftime("%Y-%m")] += 1
end

keys = classified.keys.sort

keys.each do |k|
  printf("%s %d \n", k, classified[k])
end