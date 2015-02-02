namespace :load do
  task :defaults do
    set :static_deploy_to, fetch(:static_deploy_to, "/home/#{fetch(:user)}/apps")
  end
end

namespace :static do
  namespace :middleman do
    task :local_build, [:path, :app_name, :stage] do |t, args|
      app_name = args[:app_name]
      root_path = args[:path]
      stage = args[:stage]
      filename = "#{app_name}.tar.gz"
      run_locally do
        within root_path do
          execute :rm, "-rf #{filename}" if test("[ -e #{root_path}/#{filename} ]")
          execute :rm, "-rf #{app_name}" if test("[ -d #{root_path}/#{app_name} ]")
          execute :bundle, "exec middleman build --verbose"
          execute :cp, "-r build #{app_name}"
          execute :tar, "-zcvf #{filename} #{app_name}"
        end
      end
    end

    task :deploy, [:path, :app_name, :stage] do |t, args|
      app_name = args[:app_name]
      root_path = args[:path]
      stage = args[:stage]
      invoke "static:middleman:local_build", root_path, app_name, stage
      invoke "static:middleman:clear", app_name
      invoke "static:middleman:upload", root_path, app_name
    end

    task :upload, [:path, :app_name] do |t, args|
      app_name = args[:app_name]
      root_path = args[:path]
      filename = "#{app_name}.tar.gz"
      target_path = "#{root_path}/#{filename}"
      deploy_path = fetch(:static_deploy_to)
      cap_info "upload #{target_path} to #{deploy_path}"
      on roles(:web), in: :parallel do |host|
        execute :rm, "#{deploy_path}/#{filename}" if test("[ -e #{deploy_path}/#{filename} ]")
        upload! target_path, deploy_path
        execute "tar -zxvf #{deploy_path}/#{filename}"
      end
    end

    task :symlink do

    end

    task :clear, [:app_name] do |t, args|
      app_name = args[:app_name]
      root_path = "#{fetch(:static_deploy_to)}/#{app_name}"
      on roles(:web), in: :parallel do |host|
        execute :rm, "-rf #{root_path}" if test("[ -d #{root_path} ]")
      end
    end
  end

  namespace :yeoman do
    task :local_build, [:path, :app_name, :stage] do |t, args|
      app_name = args[:app_name]
      root_path = args[:path]
      stage = args[:stage]
      filename = "#{app_name}.tar.gz"
      run_locally do
        within root_path do
          execute :rm, "-rf #{filename}" if test("[ -e #{root_path}/#{filename} ]")
          execute :rm, "-rf #{app_name}" if test("[ -d #{root_path}/#{app_name} ]")
          execute :grunt, stage
          execute :grunt, "build"
          execute :cp, "-r dist #{app_name}"
          execute :tar, "-zcvf #{filename} #{app_name}"
        end
      end
    end

    task :deploy, [:path, :app_name, :stage] do |t, args|
      app_name = args[:app_name]
      root_path = args[:path]
      stage = args[:stage]
      invoke "static:yeoman:local_build", root_path, app_name, stage
      invoke "static:yeoman:clear", app_name
      invoke "static:yeoman:upload", root_path, app_name
    end

    task :upload, [:path, :app_name] do |t, args|
      app_name = args[:app_name]
      root_path = args[:path]
      filename = "#{app_name}.tar.gz"
      target_path = "#{root_path}/#{filename}"
      deploy_path = fetch(:static_deploy_to)
      cap_info "upload #{target_path} to #{deploy_path}"
      on roles(:web), in: :parallel do |host|
        execute :rm, "#{deploy_path}/#{filename}" if test("[ -e #{deploy_path}/#{filename} ]")
        upload! target_path, deploy_path
        execute "tar -zxvf #{deploy_path}/#{filename}"
      end
    end

    task :symlink do

    end

    task :clear, [:app_name] do |t, args|
      app_name = args[:app_name]
      root_path = "#{fetch(:static_deploy_to)}/#{app_name}"
      on roles(:web), in: :parallel do |host|
        execute :rm, "-rf #{root_path}" if test("[ -d #{root_path} ]")
      end
    end

    # task :ln_management do
    #   run <<-CMD
    # rm -rf #{latest_release}/public/management &&
    # rm -rf #{shared_path}/management &&
    # mkdir -p #{shared_path}/management &&
    # ln -s #{shared_path}/management #{latest_release}/public/management
    #   CMD
    # end
    #
    # task :admin,:roles => :web, :except => { :no_release => true } do
    #
    #   #run "cd #{current_path} && echo $RAILS_ENV"
    #   #run_locally
    #   puts 'start recompile locally'
    #   #run_locally "cd public; tar -zcvf assets.tar.gz assets"
    #   #run_locally "cd public; tar -zcvf assets.tar.gz assets"
    #   run_locally "cd ngapp/ChattingCatAdmin; grunt"
    #   ln_management
    #   run_locally "cd ngapp/ChattingCatAdmin; cp -r dist management"
    #   run_locally "cd ngapp/ChattingCatAdmin; tar -zcvf management.tar.gz management"
    #   top.upload "ngapp/ChattingCatAdmin/management.tar.gz", "#{shared_path}", :via => :scp
    #   run "cd #{shared_path}; tar -zxvf management.tar.gz"
    #   run "rm #{shared_path}/management.tar.gz"
    #   run_locally "rm ngapp/ChattingCatAdmin/management.tar.gz"
    #   run_locally "rm -rf ngapp/ChattingCatAdmin/management"
    # end
  end
end
