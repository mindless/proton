# gem build *.gemspec
# gem push *.gem
#
require "./lib/proton/version"
Gem::Specification.new do |s|
  s.name = "proton"
  s.version = Proton.version
  s.summary = "Prototyping tool / static site generator."
  s.description = "Proton lets you create static websites from a bunch of files written in HAML, Textile, Sass, or any other templating language."
  s.authors = ["Rico Sta. Cruz"]
  s.email = ["rico@sinefunc.com"]
  s.homepage = "http://github.com/sinefunc/proton"
  s.files = Dir["{bin,lib,test,data}/**/*", "*.md", "Rakefile", "AUTHORS"]
  s.executables = ["proton"]

  s.add_dependency "shake", "~> 0.1"
  s.add_dependency "tilt", "~> 1.3.2"
  s.add_dependency "cuba", "~> 2.0.0"
  s.add_dependency "hashie", "~> 1.0.0"
  s.add_dependency "haml", "~> 4.0.7"
  s.add_dependency "sass", "~> 3.4.13"
  s.add_dependency "compass", "~> 1.0.1"
  s.add_dependency "maruku", "~> 0.7.2"

  s.add_development_dependency "RedCloth"
  s.add_development_dependency "less"

end
