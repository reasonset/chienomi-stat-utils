#!/usr/bin/ruby
require_relative 'apache-log-parser'

log = nil
log = Parser.parse(ARGF)

Marshal.dump log, STDOUT