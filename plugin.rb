# name: bistuoauth
# about: Authenticate with discourse via Bistu's Oauth
# version: 0.2.0
# authors: Jason Zhu

require 'auth/oauth2_authenticator'

class BistuAuthenticator < ::Auth::OAuth2Authenticator

  CLIENT_ID = 'ASDFASDF'
  CLIENT_SECRET = 'ASDF1234'

  def register_middleware(omniauth)
    omniauth.provider :bistu,
      CLIENT_ID,
      CLIENT_SECRET
  end
end

require 'omniauth-oauth2'
class OmniAuth::Strategies::BistuOauth < OmniAuth::Strategies::OAuth2

  # NOTE VM has to be able to resolve
  

  # Give your strategy a name.
  option :name, "bistu"

  # This is where you pass the options you would pass when
  # initializing your consumer from the OAuth gem.
  option :client_options, {
    :site => 'http://222.249.250.234/bistuapi/',
    :authorize_url => 'http://222.249.250.234/o/authorize/',
    :token_url => 'http://222.249.250.234/o/token/'
  }

  # These are called after authentication has succeeded. If
  # possible, you should try to set the UID without making
  # additional calls (if the user id is returned with the token
  # or as a URI parameter). This may not be possible with all
  # providers.
  uid{ raw_info['id'] }

  info do
    {
      :name => raw_info['username'],
      :user => raw_info['userid'],

     }
  end

  extra do
    {'raw_info' => raw_info}
  end

  def raw_info
    @raw_info ||= access_token.get('/bistuapi/me/').parsed
  end
end


auth_provider :title => 'with Bistu',
    :message => 'Log in via the main site (Make sure pop up blockers are not enbaled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => BistuAuthenticator.new('bistu', trusted: true)

register_css <<CSS

.btn-social.bistu {
  background: #dd4814;
}

.btn-social.bistu:before {
  font-family: Ubuntu;
  content: "B";
}

CSS
