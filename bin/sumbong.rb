#!/usr/bin/env ruby

require 'optparse'
require 'sumbongero'

@options = {}
options_parser = OptionParser.new do |opts|
  opts.on("-c CLIENT") do |client|
    @options[:client] = client
  end

  opts.on("-u USER") do |user|
    @options[:user] = user
  end

  opts.on("-p PASSWORD") do |password|
    @options[:password] = password
  end

  opts.on("-f FOLDERS", Array) do |folders|
    @options[:folders] = folders
  end
end

options_parser.parse!

case @options[:client].downcase
  when "gmail"
    @c = Sumbongero::Clients::GMail.new(@options[:user], @options[:password], @options[:folders])
  when "outlook"
    load 'sumbongero/clients/outlook.rb'
    @c = Sumbongero::Clients::Outlook.new(@options[:folders])
end
# puts @options
@r = Sumbongero::Reporters::Reporter.new(@c)
@r.report
