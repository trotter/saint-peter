require 'json'
require 'cgi'

module Rack
  class SaintPeter
    # saint_peter_host:: The host for the SaintPeter server
    # block:: Extract the requested resource and user and return
    #         as a two element hash { :user, :resource }
    def initialize(app, saint_peter_host, &block) # :yields: env
      @app = app
      @saint_peter_host = saint_peter_host
      @extract_user_and_resource = block
    end

    def call(env)
      user, resource = @extract_user_and_resource.call(env).
                         values_at(:user, :resource).
                         map { |v| CGI.escape(v || "") }
      authorized = 
        begin
          resp = Net::HTTP.get(@saint_peter_host, 
                               "/users/#{user}/authorizations?resource=#{resource}",
                               3333)
          authorized = JSON.parse(resp)["authorized"]
        rescue
          false
        end

      if authorized
        @app.call(env)
      else
        [401, {'Content-Type' => 'text/html'}, "Unauthorized\n"]
      end

    rescue => e
      [500, {'Content-Type' => 'text/html'}, "Unable to authorize: #{e.message}\n"]
    end
  end
end
