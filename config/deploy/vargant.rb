set :stage, :ec2
set :branch, "master"

# used in case we're deploying multiple versions of the same
# app side by side. Also provides quick sanity checks when looking
# at filepaths
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
#role :app, %w{deploy@chattingcat.com}
#role :web, %w{deploy@chattingcat.com}
#role :db,  %w{deploy@chattingcat.com}
#role :monitor, %w{deploy@chattingcat.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
server 'ec2-54-199-146-176.ap-northeast-1.compute.amazonaws.com', user: 'ubuntu', roles: %w{app web db}, my_property: :my_value
server 'ec2-54-199-222-155.ap-northeast-1.compute.amazonaws.com', user: 'ubuntu', roles: %w{app web}, my_property: :my_value

set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"

# dont try and infer something as important as environment from
# stage name.
#set :rails_env, :production

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally

set :ssh_options, {

    keys: %w(~/.ssh/chattingcat_aws.pem),
    forward_agent: true,
    auth_methods: %w(publickey password)
}
# and/or per server
# server 'chattingcat.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options



#for vagrant


