require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Twitchtv < OmniAuth::Strategies::OAuth2
      option :name, 'twitchtv'

      option :client_options, {
        :site => 'https://api.twitch.tv',
        :authorize_url => 'https://api.twitch.tv/kraken/oauth2/authorize',
        :token_url => 'https://api.twitch.tv/kraken/oauth2/token'
      }


      option :authorize_params, {}
      option :authorize_options, [:scope, :response_type]
      option :response_type, 'code'

      uid do
        raw_info['_id']
      end

      info do
        {
          name: raw_info['name'],
          email: raw_info['email'],
          nickname: raw_info['display_name'],
          image: raw_info['logo'],
          urls: {
            channel: raw_info['_links']['self']
          }
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get(info_url, params: { oauth_token: access_token.token }).parsed
      end


      def info_url
        if self.options.scope.present? && self.options.scope.index("user_read")
          "https://api.twitch.tv/kraken/user"
        else
      # In case scope does not contain allowance to read user info,
      # obtain it from kraken and read public profile
          response = access_token.get("https://api.twitch.tv/kraken/", params: { oauth_token: access_token.token }).parsed
          response['_links']['users']
        end
      end
    end
  end
end
OmniAuth.config.add_camelization 'twitchtv', 'Twitchtv'
