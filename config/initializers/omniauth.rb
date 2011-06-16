
keys = YAML.load_file("#{Rails.root}/config/omniauth.yml")

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github,  keys['github']['client'], keys['github']['secret']
  provider OmniAuth::Strategies::UniWeb, keys['uni-web']['user'], keys['uni-web']['pass']
end


# TODO
#
require 'omniauth/core'

module OmniAuth
  module Strategies
    class UniWeb
      include OmniAuth::Strategy
      
    end
  end
end