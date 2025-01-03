#!/usr/bin/ruby
require_relative 'apache-log-parser'

log = nil
opts = parse_argopts

if opts["marshal"]
  log = Marshal.load File.read opts["marshal"]
else
  log = Parser.parse(ARGF)
end

resource = Hash.new(0)

log = Parser.exclude_bots log
log = Parser.exclude_notok log

log.each do |i|
  resource[i.resource] += 1 if i.resource
end

keys = resource.keys.sort_by {|k| resource[k] }

keys.each do |k|
  printf("%10d %s\n", resource[k], k)
end