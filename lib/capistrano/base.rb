#def template(from, to)
#  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
#  put ERB.new(erb).result(binding), to
#end
#
#def set_default(name, *args, &block)
#  set(name, *args, &block) unless exists?(name)
#end
#
#def press_yes(ch, stream, data)
#
#  if data =~ /Do.you.want.to.continue./
#    ch.send_data("y\n")
#  else
#    Capistrano::Configuration.default_io_proc.call( ch, stream, data)
#  end
#end
#
#def press_enter( ch, stream, data)
#  if data =~ /Press.\[ENTER\].to.continue/
#    # prompt, and then send the response to the remote process
#    ch.send_data( "\n")
#  else
#    # use the default handler for all other text
#    Capistrano::Configuration.default_io_proc.call( ch, stream, data)
#  end
#end


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

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    on roles(:all) do
      execute :sudo, "apt-get -y update"
      execute :sudo, "apt-get -y install software-properties-common"
      execute :sudo, "apt-get -y install python-software-properties"
    end

  end
end
