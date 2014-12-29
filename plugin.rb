# name: Bistu login
# about: Authenticate with discourse with bistu.
# version: 0.1.0
# author: Jason Zhu

gem 'omniauth-bistu',:git => 'https://github.com/fmyzjs/omniauth-bistu.git'

class BistuAuthenticator < ::Auth::Authenticator

  def name
    'bistu'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    data = auth_token[:info]
    raw_info = auth_token[:extra][:raw_info]
    bistu_uid = data["userName"]

    current_info = ::PluginStore.get('bistu', "bistu_uid_#{bistu_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = data["realName"]
    result.username = data["userName"]
    result.email = data["email"]
    result.extra_data = { bistu_uid: bistu_uid, raw_info: raw_info }

    result
  end

  def after_create_account(user, auth)
    bistu_uid = auth[:extra_data][:uid]
    ::PluginStore.set('bistu', "bistu_uid_#{bistu_uid}", {user_id: user.id})
  end

  def register_middleware(omniauth)
    omniauth.provider :bistu, :setup => lambda { |env|
      strategy = env['omniauth.strategy']
      strategy.options[:client_id] = SiteSetting.bistu_client_id
      strategy.options[:client_secret] = SiteSetting.bistu_client_secret
    }
  end
end

auth_provider :frame_width => 920,
              :frame_height => 800,
              :authenticator => BistuAuthenticator.new,
              :background_color => 'rgb(230, 22, 45)'

register_css <<CSS

.btn-social.bistu:before {
  font-family: Ubuntu;
  content: "信";
}


CSS