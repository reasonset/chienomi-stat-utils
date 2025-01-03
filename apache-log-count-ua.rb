#!/usr/bin/ruby
require_relative 'apache-log-parser'

log = nil
opts = parse_argopts

if opts["marshal"]
  log = Marshal.load File.read opts["marshal"]
else
  log = Parser.parse(ARGF)
end

ua = Hash.new(0)

log = Parser.exclude_bots log
log = Parser.exclude_notok log

log.each do |i|
  ua[i.ua.gsub(/\/[\d.]+/, "")] += 1 if i.ua
end

keys = ua.keys.sort_by {|k| ua[k] }

keys.each do |k|
  printf("%10d %s\n", ua[k], k)
end