namespace :imagemagick do
  desc "Install the latest release of ImageMagick and the MagickWand Dev Library"
  task :install do
    on roles(:app) do
      execute "#{sudo} apt-get -y update"
      execute "#{sudo} apt-get -y install imagemagick libmagickwand-dev"
    end
  end
  # after "deploy:install", "imagemagick:install"
end