desc "Update. Make sure to build it there first"
task :build do
  require 'fileutils'

  app_path = ENV['PROTON_PATH'] || '../app'
  proton   = File.expand_path("#{app_path}/bin/proton")

  # Build our files
  system "#{proton} build"

  # Copy it here (reset first)
  FileUtils.rm_rf "./_public/manual"
  FileUtils.cp_r "#{app_path}/doc", "./_public/manual"
end

desc "Deploy"
task :deploy do
  Dir.chdir("./_public") do
    system "git add ."
    system "git add -u ."
    system "git commit -m ."
    system "git push origin gh-pages"
  end
end
