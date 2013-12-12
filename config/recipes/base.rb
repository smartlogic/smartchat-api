def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  namespace :pending do
    desc "Displays the `diff' stat since the last deploy."
    task :stat, :except => { :no_release => true } do
      system("git diff --stat  #{current_revision}")
    end
  end
end
