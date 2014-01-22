namespace :clean_up do
  desc "Clean up Media Store"
  task :media_store => [:environment] do
    CleanUpTask.perform(AppContainer)
  end
end
