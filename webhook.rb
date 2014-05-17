require 'rubygems'
require 'ipaddr'
require 'json'
require 'open3'
require 'sinatra'

set :port, 8060
set :environment, :production
set :dump_errors, false

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

folder = File.dirname(__FILE__)

require "#{folder}/config.rb" if File.exist? "#{folder}/config.rb"

allowed_ranges = allowed_ranges().map { |subnet| IPAddr.new subnet }

not_found do
  "Go away."
end

error do
  'Error: '  + env['sinatra.error'].message
end

post '/' do
  if not allowed_ranges.any? { |block| block.include?(request.ip) }
    raise Exception, "IP not allowed: #{request.ip}"
  end
  if not params[:payload]
    raise Exception, "Missing payload."
  end

  push = JSON.parse(params[:payload])

  before_id = push['before']
  after_id = push['after']
  ref = push['ref']
  repo = push['repository']
  repo_name = repo['name']

  pre_exec(push)

  cmd  = "#{folder}/change-notify.sh #{repo_name} #{before_id} #{after_id} #{ref} #{notifier()}"
  stdout, stderr, status = Open3.capture3(cmd)

  post_exec(stdout, stderr, status)

  'Success!'
end
