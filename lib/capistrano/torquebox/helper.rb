
module Capistarno
  module Torquebox
    module Helpers
      def create_deployment_descriptor(root_path)
        config = {
            'application' => {
                'root' => "#{root_path.respond_to?(:force_encoding) ? root_path.force_encoding('UTF-8') : root_path}",
            },
        }

        if fetch(:app_host)
          config['web'] ||= {}
          config['web']['host'] = fetch(:app_host)
        end

        if  fetch(:app_context)
          config['web'] ||= {}
          config['web']['context'] = fetch(:app_context)
        end

        if  fetch(:app_ruby_version)
          config['ruby'] ||= {}
          config['ruby']['version'] = fetch(:app_ruby_version)
        end

        if  fetch(:app_environment)
          config['environment'] = fetch(:app_environment)
        end

        if  fetch(:rails_env)
          config['environment'] ||= {}
          config['environment']['RACK_ENV'] = fetch(:rails_env).to_s
        end

        if fetch(:stomp_host)
          config['stomp'] ||= {}
          config['stomp']['host'] = fetch(:stomp_host)
        end

        filename = fetch(:knob_yml_extensions)
        if filename
          config_ext = YAML.load_file(filename)
          config.merge! config_ext
        end

        config
      end

    end
  end
end