module ConfConf
  class Project
    class Environments < Struct.new(:project)
      def length
        Dir["config/conf_conf/environments/*.json"].length
      end

      def remove(name)
        FileUtils.rm_f("config/conf_conf/environments/#{name}.json")
      end

      def to_a
        Dir["config/conf_conf/environments/*.json"].collect do |path|
          environment_name = File.basename(path, File.extname(path))
          self[environment_name]
        end
      end

      def [](name)
        Environment.load(project, name)
      end
    end
  end
end
