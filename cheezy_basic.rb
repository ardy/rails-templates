
test_gems = <<-END

config.gem "rspec", :version => ">=1.2.2"
config.gem "rspec-rails", :version => ">=1.2.2"
config.gem "cucumber", :version => ">=0.2.3"
config.gem "webrat", :version => ">=0.4.4"
END
run "echo '#{test_gems}' \>\> config/environments/test.rb"

rake "gems:install"

generate :rspec
generate :cucumber

plugin "database_cleaner", :git => "git://github.com/bmabey/database_cleaner.git"

git :init

file ".gitignore", <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
END

run "mkdir features/plain"
run "mkdir features/enhanced"

cucumber_yml = <<-END
default: -r features/support/env.rb -r features/support/plain.rb -r features/step_definitions features/plain
selenium: -r features/support/env.rb -r features/support/enhanced.rb -r features/step_definitions features/enhanced features/plain
END
run "echo '#{cucumber_yml}' > cucumber.yml"

cucumber_env = <<-END
ENV["RAILS_ENV"] ||= "test"
require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require "cucumber/rails/world"
require "cucumber/formatter/unicode"
require "cucumber/rails/rspec"
require "webrat"
require "webrat/rails"
require "webrat/core/matchers"

Cucumber::Rails.bypass_rescue 
END
run "echo '#{cucumber_env}' > features/support/env.rb"

plain_env = <<-END
Cucumber::Rails.use_transactional_fixtures

Webrat.configure do |config|
  config.mode = :rails
end
END
run "echo '#{plain_env}' > features/support/plain.rb"

enhanced_env = <<-END
Webrat.configure do |config|
  config.mode = :selenium
  config.application_environment = :test
end

require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.clean
end
END
run "echo '#{enhanced_env}' > features/support/enhanced.rb"

git :add => "."
git :commit => "-m 'initial commit'"
