# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: page_magic 1.0.2 ruby lib

Gem::Specification.new do |s|
  s.name = "page_magic"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Leon Davis"]
  s.date = "2015-11-16"
  s.description = "Framework for modeling and interacting with webpages which wraps capybara"
  s.email = "info@lad-tech.com"
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".codeclimate.yml",
    ".pullreview.yml",
    ".rspec",
    ".rubocop.yml",
    ".simplecov",
    ".yardopts",
    "Gemfile",
    "Gemfile.lock",
    "README.md",
    "Rakefile",
    "VERSION",
    "circle.yml",
    "lib/page_magic.rb",
    "lib/page_magic/class_methods.rb",
    "lib/page_magic/driver.rb",
    "lib/page_magic/drivers.rb",
    "lib/page_magic/drivers/poltergeist.rb",
    "lib/page_magic/drivers/rack_test.rb",
    "lib/page_magic/drivers/selenium.rb",
    "lib/page_magic/element.rb",
    "lib/page_magic/element/locators.rb",
    "lib/page_magic/element/query.rb",
    "lib/page_magic/element/selector.rb",
    "lib/page_magic/element/selector_methods.rb",
    "lib/page_magic/element_context.rb",
    "lib/page_magic/element_definition_builder.rb",
    "lib/page_magic/elements.rb",
    "lib/page_magic/exceptions.rb",
    "lib/page_magic/instance_methods.rb",
    "lib/page_magic/session.rb",
    "lib/page_magic/session_methods.rb",
    "lib/page_magic/wait_methods.rb",
    "lib/page_magic/watcher.rb",
    "lib/page_magic/watchers.rb",
    "page_magic.gemspec",
    "spec/element_spec.rb",
    "spec/page_magic/class_methods_spec.rb",
    "spec/page_magic/driver_spec.rb",
    "spec/page_magic/drivers/poltergeist_spec.rb",
    "spec/page_magic/drivers/rack_test_spec.rb",
    "spec/page_magic/drivers/selenium_spec.rb",
    "spec/page_magic/drivers_spec.rb",
    "spec/page_magic/element/locators_spec.rb",
    "spec/page_magic/element/query_spec.rb",
    "spec/page_magic/element/selector_spec.rb",
    "spec/page_magic/element_context_spec.rb",
    "spec/page_magic/element_definition_builder_spec.rb",
    "spec/page_magic/elements_spec.rb",
    "spec/page_magic/instance_methods_spec.rb",
    "spec/page_magic/session_methods_spec.rb",
    "spec/page_magic/session_spec.rb",
    "spec/page_magic/wait_methods_spec.rb",
    "spec/page_magic/watchers_spec.rb",
    "spec/page_magic_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/shared_contexts.rb",
    "spec/support/shared_contexts/files_context.rb",
    "spec/support/shared_contexts/nested_elements_html_context.rb",
    "spec/support/shared_contexts/rack_application_context.rb",
    "spec/support/shared_contexts/webapp_fixture_context.rb",
    "spec/support/shared_examples.rb",
    "spec/watcher_spec.rb"
  ]
  s.homepage = "https://github.com/ladtech/page_magic"
  s.licenses = ["ruby"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.1")
  s.rubygems_version = "2.2.2"
  s.summary = "Framework for modeling and interacting with webpages"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capybara>, [">= 2.5"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 4"])
      s.add_runtime_dependency(%q<wait>, ["~> 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<rubocop>, ["~> 0.34"])
      s.add_development_dependency(%q<yard>, ["~> 0.8"])
      s.add_development_dependency(%q<redcarpet>, ["~> 3.3"])
      s.add_development_dependency(%q<github-markup>, ["~> 1.4"])
    else
      s.add_dependency(%q<capybara>, [">= 2.5"])
      s.add_dependency(%q<activesupport>, ["~> 4"])
      s.add_dependency(%q<wait>, ["~> 0"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<rubocop>, ["~> 0.34"])
      s.add_dependency(%q<yard>, ["~> 0.8"])
      s.add_dependency(%q<redcarpet>, ["~> 3.3"])
      s.add_dependency(%q<github-markup>, ["~> 1.4"])
    end
  else
    s.add_dependency(%q<capybara>, [">= 2.5"])
    s.add_dependency(%q<activesupport>, ["~> 4"])
    s.add_dependency(%q<wait>, ["~> 0"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<rubocop>, ["~> 0.34"])
    s.add_dependency(%q<yard>, ["~> 0.8"])
    s.add_dependency(%q<redcarpet>, ["~> 3.3"])
    s.add_dependency(%q<github-markup>, ["~> 1.4"])
  end
end

