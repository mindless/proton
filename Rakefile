desc "Build"
task :build do
  system "proton build"
end

desc "Deploy"
task :deploy => :build do
  # github.com/rstacruz/git-update-ghpages
  system "git update-ghpages rstacruz/proton -b gh-pages -i _public"
end
