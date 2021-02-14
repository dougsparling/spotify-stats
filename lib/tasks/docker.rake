namespace :docker do
  desc "Publishes the latest code to a docker registry"
  task :publish do
    registry = ENV['REGISTRY'] || '192.168.0.3:32000'
    `docker build . -t spotify-stats`
    `docker tag spotify-stats:latest #{registry}/spotify-stats:latest`
    `docker push #{registry}/spotify-stats:latest`
  end
end