require 'rubygems'
require 'ipaddr'
require 'json'
require 'sinatra'

set :port, 8060

class WebHook < Sinatra::Base
  post '/' do
    if params[:payload]
      push = JSON.parse(params[:payload])

      repo = push['repository']['name']
      before_id = push['before']
      after_id = push['after']
      ref = push['ref']

      allowed = %w{
      127.0.0.1/8
      192.30.252.0/22
      }.map { |subnet| IPAddr.new subnet }

      if not allowed.any? { |block| block.include?(request.ip) }
        puts "IP not allowed #{request.ip}"
      else
        system("/opt/commitspam/change-notify.sh #{repo} #{before_id} #{after_id} #{ref}")
      end
    end
  end
end
