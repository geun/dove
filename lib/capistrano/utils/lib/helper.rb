require 'colorize'
require 'erb'

module Dove
  module Utils

    module Colorize
      # color output
      def cap_info message
        puts " INFO #{message}".colorize(:cyan)
      end

      def cap_warn message
        puts " WARN #{message}".colorize(:yellow)
      end

      def cap_error message
        puts " ERROR #{message}".colorize(:red)
      end
    end

    module Template
      def smart_template(from, to)
        #full_to_path = "#{shared_path}/config/#{to}"
        if from_erb_path = template_file(from)
          from_erb = StringIO.new(ERB.new(File.read(from_erb_path)).result(binding))
          upload! from_erb, to
          info "copying: #{from_erb} to: #{to}"
        else
          error "error #{from} not found"
        end
      end

      def template_file(name)
        if File.exist?((file = "config/deploy/#{fetch(:full_app_name)}/#{name}.erb"))
          return file
        elsif File.exist?((file = "config/deploy/templates/#{name}"))
          return file
        end
        return nil
      end

      def local_copy_template(name)
        root = capture(:pwd)
        template_path = "#{root}/lib/capistrano/templates"
        target_path = "#{root}/config/deploy/templates/"
        unless test("[ -e #{target_path} ]")
          execute :mkdir, "#{root}/config/deploy/templates/"
        end
        execute :cp, "#{template_path}/#{name}", target_path
      end

      # Renders a template
      def render_template(template, output, scope)
        tmpl = File.read(template)
        erb = ERB.new(tmpl, 0, "<>")
        File.open(output, 'w') do |f|
          f.puts erb.result(scope)
        end
      end

      # Upload and Move
      def upload_and_move source, destination
        if File.exists?(source)
          file = File.basename(source)
          upload! source, './'
          sudo "mv ./#{file} #{destination}"
        end
      end
    end
  end
end

include Dove::Utils::Template
include Dove::Utils::Colorize

