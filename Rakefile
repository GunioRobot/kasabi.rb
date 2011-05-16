require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rake/clean'

NAME = "kasabi"
VER = "0.0.2"

RDOC_OPTS = ['--quiet', '--title', 'Kasabi Ruby Client Documentation']

PKG_FILES = %w( README.md Rakefile CHANGES ) + 
  Dir.glob("{bin,tests,etc,lib}/**/*")

CLEAN.include ['*.gem', 'pkg']  
SPEC =
  Gem::Specification.new do |s|
    s.name = NAME
    s.version = VER
    s.platform = Gem::Platform::RUBY
    s.required_ruby_version = ">= 1.8.5"    
    s.has_rdoc = true
    s.extra_rdoc_files = ["CHANGES"]
    s.rdoc_options = RDOC_OPTS
    s.summary = "Ruby Client for Kasabi"
    s.description = s.summary
    s.author = "Leigh Dodds"
    s.email = 'leigh@kasabi.com'
    s.homepage = 'http://github.com/kasabi/kasabi.rb'
    s.rubyforge_project = 'kasabi'
    s.files = PKG_FILES
    s.require_path = "lib" 
    s.bindir = "bin"
    #s.executables = ["..."]
    s.test_file = "tests/ts_kasabi.rb"
    s.add_dependency("httpclient", ">= 2.1.3.1")
    s.add_dependency("json", ">= 1.1.3")
    s.add_dependency("mocha", ">= 0.9.5")
    s.add_dependency("mime-types", ">= 1.16")
    #FIXME versions
    s.add_dependency("linkeddata")
  end
      
Rake::GemPackageTask.new(SPEC) do |pkg|
    pkg.need_tar = true
end

Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options += RDOC_OPTS
    rdoc.rdoc_files.include("CHANGES", "lib/**/*.rb")
    #rdoc.main = "README"    
end

#desc "Publish rdoc output to rubyforge"
#task "publish-docs" => ["rdoc"] do 
#  rubyforge_path = "/var/www/gforge-projects/#{NAME}/" 
#  sh "scp -r doc/* " + 
#    "#{ENV["RUBYFORGE_USER"]}@rubyforge.org:#{rubyforge_path}", 
#    :verbose => true 
#end 

Rake::TestTask.new do |test|
  test.test_files = FileList['tests/*/tc_*.rb']
end

desc "Install from a locally built copy of the gem"
task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VER}}
end

desc "Uninstall the gem"
task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end
