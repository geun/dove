namespace :imagemagick do
  desc "Install the latest release of ImageMagick and the MagickWand Dev Library"
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install imagemagick libmagickwand-dev"
  end
  after "deploy:install", "imagemagick:install"
end