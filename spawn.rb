#!/usr/bin/env ruby

require 'ipaddr'
require 'json'
require 'open3'
require 'webrick'

def pre_exec
end
def post_exec
end

def allowed_ranges
  %w{
127.0.0.1/8
192.30.252.0/22
}
end

def notifier
  "git-commit-notifier"
end

require '/opt/commitspam/config.rb' if File.exist? '/opt/commitspam/config.rb'

allowed_ranges = allowed_ranges().map { |subnet| IPAddr.new subnet }

req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
req.parse(STDIN)

socket = Socket.for_fd(STDIN.fileno)
remote_ip = socket.remote_address.ip_address

resp = WEBrick::HTTPResponse.new(WEBrick::Config::HTTP)

if not allowed_ranges.any? { |block| block.include?(remote_ip) }
  resp.status = 401
  puts resp.to_s
  exit 23
end

unless req.query.include? 'payload'
  resp.status = 403
  puts resp.to_s
  exit 24
end

json_payload = JSON.parse(req.query['payload'])
ref          = json_payload['ref']
before_id    = json_payload['before']
after_id     = json_payload['after']
repo         = json_payload['repository']
repo_name    = repo['name']

child_pid = fork do
  STDIN.reopen "/dev/null"
  STDOUT.reopen "/dev/null", "a"
  STDERR.reopen "/dev/null", "a"

  pre_exec(json_payload)

  cmd  = "/opt/commitspam/change-notify.sh #{repo_name} #{before_id} #{after_id} #{ref} #{notifier()}"
  stdout, stderr, status = Open3.capture3(cmd)

  post_exec(stdout, stderr, status)
  exit 0
end


Process.detach(child_pid)

puts resp.to_s
exit 0
