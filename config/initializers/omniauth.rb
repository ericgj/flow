
keys = YAML.load_file("#{Rails.root}/config/omniauth.yml")

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,  keys['github']['client'], keys['github']['secret']
  provider OmniAuth::Strategies::UniWeb, keys['uni-web']['user'], keys['uni-web']['password'], 
                                         :authorize => [:alumnus, :staff]
end


# TODO: move
#
require 'omniauth/basic'

module OmniAuth
  module Strategies
    class UniWeb < HttpBasic
      
      def initialize(app, user, pass, options = {})
        require 'json'
        @user, @pass = user, pass
        @authorized_groups = options[:authorize] || []
        env['REQUEST_METHOD'] = 'POST'    # bypasses login form
      end
      
      def endpoint
        "http://#{@user}:#{@pass}@universityweb.rubymendicant.com/auth?github=#{request.params['uid']}"
      end

      def auth_hash
        authorize_or_fail(JSON.parse(@response.body))
      end
      
      private
      
      def authorize_or_fail(hash)
        %w{alumnus staff}.each do |grp|
          if @authorized_groups.empty? || @authorized_groups.any?(hash[grp])
            break
          else
            # rescued in HttpBasic#perform
            raise RestClient::Request::Unauthorized, 
              hash['error'] || "RbMU user is not #{@authorized_groups.join(' or ')}" 
          end
        end
        return hash
      end
      
    end
  end
end
