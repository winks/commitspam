require 'rubygems'
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

      if request.ip =~ /192\.30\.252\.\d+/ or request.ip =~ /204\.232\.175\.\d+/
        system("/opt/commitspam/change-notify.sh #{repo} #{before_id} #{after_id} #{ref}")
      else
        puts "IP not allowed #{request.ip}"
      end
    end
  end
end
