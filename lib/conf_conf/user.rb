require 'base64'
require 'rbnacl/libsodium'
require 'conf_conf/config'

module ConfConf
  class User < Struct.new(:public_key, :private_key)
    class << self
      def current
        config = Config.load
        User.new(config.public_key, config.private_key)
      end
    end

    class Config < ConfConf::Config
      def self.path
        File.join(File.expand_path('~'), '.conf_conf.json')
      end

      config_attr :public_key, default: :new_public_key
      config_attr :private_key, default: :new_private_key

      private
      def new_public_key
        generate_keys! and @public_key
      end

      def new_private_key
        generate_keys! and @private_key
      end

      def generate_keys!
        @key ||= RbNaCl::PrivateKey.generate
        @private_key = Base64.strict_encode64(@key.to_s)
        @public_key = Base64.strict_encode64(@key.public_key.to_s)
      end
    end
  end
end
