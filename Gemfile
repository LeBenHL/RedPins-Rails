source 'https://rubygems.org'

gem 'rails', '3.2.9'
gem 'json'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :production, :staging do
  gem "pg"
end

group :development, :test do
  gem "sqlite3"
end

gem "paperclip", "~> 3.0"
gem 'simplecov', :require => false, :group => :test
gem 'multi_json', "~> 1.6.1"
gem 'geocoder',   '~> 1.1.4'
gem 'sunspot_rails', '~> 2.0.0'
gem 'sunspot_solr'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# Used for Validation of emails
gem 'valid_email'

# Used to annotate models with their fields and data types
gem 'annotate', ">=2.5.0"

group :test, :development do
  gem "rspec-rails", "~> 2.0"
end


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
