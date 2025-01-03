#!/usr/bin/ruby
require 'time'
require 'optparse'

LogRecord = Struct.new(
  :host,
  :identity,
  :user,
  :time,
  :method,
  :resource,
  :version,
  :status,
  :bytes,
  :referer,
  :ua
)

module Parser
  def self.parse log
    records = []

    log.each do |line|
      if %r#(?<host>\S+)\s+(?<identity>\S+)\s+(?<user>\S+)\s+\[(?<time>.*?)\]\s+"(?:(?<method>\S+)\s+)?(?<resource>.*?)?(?:\s+(?<version>HTTP/[\d.]+)?)?"\s+(?<status>\d+)\s+(?<bytes>\d+)\s+"(?<referer>.*?)"\s+"(?<ua>.*)"# =~ line
        records.push LogRecord.new(
          host, identity, user, Time.strptime(time, '%d/%b/%Y:%H:%M:%S %z'), method, resource, version, status.to_i, bytes.to_i, referer, ua
        )

        if records.length % 100000 == 0
          STDERR.puts records.length
        end
      elsif /^\s+$/ =~ line
        next
      else
        abort "Unable to parse line: #{line}"
      end
    end

    records
  end

  def self.exclude_bots logs
    logs.reject do |i|
      /\bBot$/ =~ i.ua or
      /bot\b/i =~ i.ua or
      ["+http://", "+https://"].any? {|ptn| i.ua.include?(ptn) }
    end
  end

  def self.exclude_bots_check logs
    logs.each do |i|
      if /\bBot$/ =~ i.ua or
      /bot\b/i =~ i.ua or
      ["+http://", "+https://"].any? {|ptn| i.ua.include?(ptn) }
        puts i.ua
      end
    end
  end

  def self.exclude_notok logs
    logs.reject do |i|
      not (200..299).include? i.status
    end
  end

  def self.exclude_notok_check logs
    logs.each do |i|
      if !i or not (200..299).include? i.status
        puts i
      end
    end
  end
end

def parse_argopts
  opts = ARGV.getopts(":m:marshal:")

  opts
end