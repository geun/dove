Dove
=============

deployment script for rails using capistrano to amazon ec2

## Installation
Add this line to your application's Gemfile:

``` ruby 
gem 'dove', github: "geun/dove"
```

And then execute :
``` bundle install


Loadmap
=============
iteration 1. capistrano 3 deployment with recipes
             - installation using ssh
             - code update using capistrano 
             
iteration 2. capistrano 3 + masterless puppet
             - installation using role base puppet 
             - code update using capistrano 
             - infra update using puppet 
             
iteration 3. capistrano 3 + masterless puppet + packer + docker 

iteration 3. capistrano 3 + masterless puppet + packer + docker + asguard(https://github.com/Netflix/asgard) + monkeys(nefflex

            
