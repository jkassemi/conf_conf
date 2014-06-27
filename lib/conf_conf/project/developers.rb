module ConfConf
  class Project
    class Developers < Struct.new(:project)
      class << self
        def load(project)
          developers      = Developers.new(project)

          if File.exists?(Developers.path)
            developers_json   = File.read(Developers.path)
            developers_keys   = MultiJson.load(developers_json)
            developers.keys   = developers_keys
          end

          developers
        end

        def path
          File.join('config', 'conf_conf', 'developers.json')
        end
      end

      def add(developer)
        keys.add(developer.pretty_public_key).to_a
      end

      def remove(developer)
        keys.delete(developer.pretty_public_key).to_a
      end

      def keys=(keys)
        @keys = Set.new(keys)
      end

      def keys
        @keys ||= Set.new
      end

      def to_a
        keys.collect { |key| Developer.new(key) }
      end

      def save
        developers_json = MultiJson.dump(keys.to_a)
        File.write(Developers.path, developers_json)
      end
    end
  end
end
