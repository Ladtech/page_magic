Bundler.require :test, :development

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do
  ENV['coverage'] = 'true'
end

Jeweler::Tasks.new do |gem|
  gem.name = 'page_magic'
  gem.homepage = 'https://github.com/ladtech/page_magic'
  gem.license = 'ruby'
  gem.summary = 'Framework for modeling and interacting with webpages'
  gem.description = 'Framework for modeling and interacting with webpages which wraps capybara'
  gem.email = 'info@lad-tech.com'
  gem.authors = ['Leon Davis']
  gem.required_ruby_version = '>= 2.1'
end

Jeweler::RubygemsDotOrgTasks.new

task default: [:spec, 'rubocop:auto_correct']
