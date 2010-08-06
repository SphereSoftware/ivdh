require "rubygems"

require "spec/rake/spectask"
require "rake/rdoctask"

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title = "TZInfo"
  rdoc.options << '--inline-source'
  rdoc.rdoc_files.include('lib')  
end

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*rb']
  end  
rescue LoadError
end
