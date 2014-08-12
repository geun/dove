# module Capistrano
#   module Static
#     module Helper
#
#
#
#       def create
#       def
#       run_locally "cd ngapp/ChattingCatAdmin; grunt"
#       ln_management
#       run_locally "cd ngapp/ChattingCatAdmin; cp -r dist management"
#       run_locally "cd ngapp/ChattingCatAdmin; tar -zcvf management.tar.gz management"
#       top.upload "ngapp/ChattingCatAdmin/management.tar.gz", "#{shared_path}", :via => :scp
#       run "cd #{shared_path}; tar -zxvf management.tar.gz"
#       run "rm #{shared_path}/management.tar.gz"
#       run_locally "rm ngapp/ChattingCatAdmin/management.tar.gz"
#       run_locally "rm -rf ngapp/ChattingCatAdmin/management"
#
#
#     end
#   end
# end