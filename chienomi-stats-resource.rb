#!/usr/bin/ruby
require_relative 'apache-log-parser'
require 'cgi'

log = nil
opts = parse_argopts

indexes = {}
published = {}

Dir.glob("**/.indexes.rbm").each do |filepath|
  index = Marshal.load File.read filepath
  index.each do |k,v|
    path = CGI.unescape(v["page_url_encoded"]).sub(%r!https?://[^/]+!, "")
    indexes[path] = v["title"]
    published[path] = String === v["date"] ? v["date"][0,4] : v["date"]&.year
  end
end

log = Parser.parse(ARGF)
resource = Hash.new(0)

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
  resource[i.resource.sub(/[?#].*/, "").sub(%r!^https?://[^/]+!, "")] += 1 if i.resource
end

keys = resource.keys.sort_by {|k| resource[k] }

keys.reverse_each do |k|
  if indexes[k]
    printf("|%s|%d|%d|\n", indexes[k], published[k], resource[k])
  else
    printf("|%s||%d|\n", k, resource[k])
  end
end