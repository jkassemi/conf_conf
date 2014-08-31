require 'rbnacl/libsodium'
require 'base64'

module ConfConf
  class Project
    class Developer < Struct.new(:pretty_public_key, :pretty_private_key)
      def self.current
        user_config_path = File.join(File.expand_path('~'), '.conf_conf.json')

        if File.exists?(user_config_path)
          user_config = MultiJson.load(File.read(user_config_path))

        else
          private_key        = RbNaCl::PrivateKey.generate
          pretty_private_key = Base64.strict_encode64(private_key.to_s)
          pretty_public_key  = Base64.strict_encode64(private_key.public_key.to_s)

          user_config = {
            'public_key'  => pretty_public_key,
            'private_key' => pretty_private_key
          }

          File.write(user_config_path, MultiJson.dump(user_config))
        end

        Developer.new(user_config['public_key'], user_config['private_key'])
      end

      def private_key
        Base64.decode64(pretty_private_key)
      end

      def public_key
        Base64.decode64(pretty_public_key)
      end
    end
  end
end
