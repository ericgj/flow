
keys = YAML.load_file("#{Rails.root}/config/omniauth.yml")

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,  keys['github']['client'], keys['github']['secret']
  provider OmniAuth::Strategies::UniWeb, keys['uni-web']['user'], keys['uni-web']['password']
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
        env['REQUEST_METHOD'] = 'POST'    # bypasses login form
        super(app, :universityweb, nil)
      end
      
      def endpoint
        "http://#{@user}:#{@pass}@universityweb.rubymendicant.com/auth?github=#{request.params['uid']}"
      end

      def auth_hash
        raw = JSON.parse(@response.body)
        OmniAuth::Utils.deep_merge(super, {
          :uid => raw.delete('github'),
          :user_info => raw
        })
      end
            
    end
  end
end
