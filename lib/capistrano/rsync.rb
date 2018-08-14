require "capistrano/scm/plugin"

module Capistrano
  class  SCM
    class Rsync < ::Capistrano::SCM::Plugin
      def set_defaults
        set :rsync_exclude, %w[.git*]
        set :rsync_include, %w[    ]
        set :rsync_options, %w[--archive --recursive --delete --delete-excluded]
        set :copy_command,  "rsync --archive --acls --xattrs"
        set :local_cache,   ".rsync_#{fetch(:stage)}"
        set :remote_cache,  "shared/rsync"
        set :repo_url,      File.expand_path(".")
      end

      def register_hooks
        after "deploy:new_release_path", "rsync:create_release"
        before "deploy:set_current_revision", "rsync:set_current_revision"

      end

      def define_tasks
        remote_cache = lambda do
          cache = fetch(:remote_cache)
          cache = deploy_to + "/" + cache if cache && cache !~ /^\//
          cache
        end

        namespace "rsync" do
          task :create_cache do
            next if File.directory?(File.expand_path(fetch(:local_cache)))  # TODO: check if it's actually our repo instead of assuming
            run_locally do
              execute :git, 'clone', fetch(:repo_url), fetch(:local_cache)
            end
          end

          desc "stage the repository in a local directory"
          task :stage => [ :create_cache ] do
            run_locally do
              within fetch(:local_cache) do
                execute :git, "fetch", "--quiet", "--all", "--prune"
                execute :git, "reset", "--hard", "origin/#{fetch(:branch)}"
              end
            end
          end

          desc "stage and rsync to the server"
          task :sync => [ :stage ] do
            release_roles(:all).each do |role|

              user = role.user || fetch(:user)
              user = user + "@" unless user.nil?

              rsync_args = []
              rsync_args.concat fetch(:rsync_options)
              rsync_args.concat fetch(:rsync_include, []).map{|e| "--include #{e}"}
              rsync_args.concat fetch(:rsync_exclude, []).map{|e| "--exclude #{e}"}
              rsync_args << fetch(:local_cache) + "/"
              rsync_args << "#{user}#{role.hostname}:#{remote_cache.call}"

              run_locally do
                execute :rsync, *rsync_args
              end
            end
          end

          desc "stage, rsync to the server, and copy the code to the releases directory"
          task :release => [ :sync ] do
            copy = %(#{fetch(:copy_command)} "#{remote_cache.call}/" "#{release_path}/")
            on release_roles(:all) do
              execute copy
            end
          end

          task :create_release => [ :release ] do
            on release_roles :all do
              execute :mkdir, "-p", release_path
            end
          end

          task :set_current_revision do
            run_locally do
              set :current_revision, capture(:git, 'rev-parse', fetch(:branch))
            end
          end
        end
      end
    end
  end
end
