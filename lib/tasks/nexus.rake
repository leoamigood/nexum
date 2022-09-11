# frozen_string_literal: true

namespace :nexum do
  desc 'Discover and surface github users and followers'
  task :surf, [:username] => [:environment] do |_task, args|
    UserSurferJob.perform_async(args.first[1])
  end
end
