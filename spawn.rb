#!/usr/bin/env ruby

require 'webrick'
require 'json'

req = WEBrick::HTTPRequest.new(WEBrick::Config::HTTP)
req.parse(STDIN)

allowed = %w{
127.0.0.1/8
204.232.175.64/27
192.30.252.0/22
}.map { |subnet| IPAddr.new subnet }

if not allowed.any? { |block| block.include?(req.remote_ip) }
  exit 23
end

json_payload = JSON.parse(req.query['payload'])
ref          = json_payload['ref']
before_id    = json_payload['before']
after_id     = json_payload['after']
repo         = json_payload['repository']['name']

pid = fork
if pid.nil? then
  STDIN.reopen "/dev/null"
  STDOUT.reopen "/dev/null", "a"
  STDERR.reopen "/dev/null", "a"

  exec('/opt/commitspam/change-notify.sh', repo, before_id, after_id, ref)
end

Process.detach(pid)