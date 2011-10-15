desc "Invokes the test suite in multiple RVM environments"
task :'test!' do
  # Override this by adding RVM_TEST_ENVS=".." in .rvmrc
  envs = ENV['RVM_TEST_ENVS'] || '1.9.2@proton,1.8.7@proton'
  puts "* Testing in the following RVM environments: #{envs.gsub(',', ', ')}"
  system "rvm #{envs} rake test" or abort
end

desc "Runs tests"
task :test do
  Dir['test/**/*_test.rb'].each { |f| load f }
end

namespace :doc do
  desc "Builds the docs in doc/."
  task :update do
    # gem install proscribe (~> 0.0.2)
    system "proscribe build"
  end

  desc "Updates the online manual."
  task :deploy => :update do
    # http://github.com/rstacruz/git-update-ghpages
    system "git update-ghpages rstacruz/proton -i doc --prefix manual"
  end
end

task :default => :test
