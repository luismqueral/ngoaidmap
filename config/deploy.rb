lock '3.4.1'
set :application, 'ngo-v2'
set :repo_url, 'git@github.com:InterActionNGO/ngoaidmap.git'
set :branch, ENV['BRANCH'] || "master"
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/ubuntu/www/ngo-v2'

# Default value for :scm is :git
# set :scm, :git
set :rvm_type, :system

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{.env config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/app/vendor}

set :whenever_identifier, ->{ "update_sites" }

# Default value for default_env is {}
# set :default_env, { path: "/usr/local/rvm/gems/ruby-2.2.1@ngo-api/bin/bundler" }
# set :default_env, { rvm_bin_path: '/usr/local/rvm/bin/rvm' }
# Default value for keep_releases is 5
# set :keep_releases, 5

# set the locations that we will look for changed assets to determine whether to precompile
set :assets_dependencies, %w(app/assets lib/asset/usr/local/rvm/bin/rvm's vendor/assets Gemfile.lock config/routes.rb)

set :bower_bin, '/usr/bin/bower'

desc 'Restart application'
after :deploy, :restart do
  on roles(:app), in: :sequence, wait: 5 do
    execute :touch, release_path.join('tmp/restart.txt')
  end
end

after :restart, :clear_cache do
  on roles(:web), in: :groups, wait: 5 do
    within current_path do
      with rails_env: fetch(:rails_env) do
        execute :rails, "runner", '"puts Redis::Namespace.new(\'ngo_aidmap\', redis: Redis.new).flushall"'
      end
    end
  end
end

 # after :failed, :rollback

