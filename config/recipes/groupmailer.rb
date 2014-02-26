def run_rake(task, options={}, &block)
  #command = "cd #{latest_release} && rbenv exec rake #{task}"
  #run(command, options, &block)
  run "cd #{current_path} && rbenv exec #{rake} #{task}"
end

namespace :email do
  namespace :migration do
    task :testmail, roles: :groupmailer do
      run_rake "email:migration:testmail"
    end
    namespace :student do

      task :eng, roles: :groupmailer do
        run_rake "email:migration:student:eng"
      end

      task :kor, roles: :groupmailer do
        run_rake "email:migration:student:kor"
      end
    end
    namespace :tutor do
      task :eng, roles: :groupmailer do
        run_rake "email:migration:tutor:eng"
      end
    end
  end
end