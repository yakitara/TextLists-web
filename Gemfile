# -*-ruby-*-
# http://gembundler.com/man/gemfile.5.html
source 'http://rubygems.org'

gem 'bundler'
gem 'rails'
gem 'pg'
gem 'jquery-rails'
gem 'uuidtools'
gem 'hoptoad_notifier'

group :production do
  gem 'passenger'
end

group :tasks do
  gem 'ar_fixtures'
  gem 'yaml_waml'
end

gem 'twitter_oauth'
gem 'will_paginate'

group :development, :test do
  gem 'silent-postgres'
  gem 'rspec-rails' #, '>= 2.3.0' #, '>= 2.0.0.beta.17'
  # NOTE: Capybara 0.4.1.2 has bug around :js => true
  # gem 'capybara' , '> 0.4.1.2', :git => 'git://github.com/jnicklas/capybara.git'
  # TODO: 2011-04-27: soom capybara 1.0 will be released
  gem 'capybara' , :git => 'git://github.com/jnicklas/capybara.git'
  #gem 'akephalos'
  #gem 'akephalos', :path => "../akephalos"
  gem 'akephalos', :git => 'git://github.com/hiroshi/akephalos.git', :branch => "capybara_0.4.0_or_newer"
  #gem 'akephalos', :git => 'git://github.com/thoughtbot/akephalos.git'
  gem 'launchy'
  gem 'ruby-debug19'
#  gem 'database_cleaner'
  gem 'timecop'
end
# https://capistrano.lighthouseapp.com/projects/8716/tickets/187-gemspec-for-2520-declares-dependencies-twice
gem 'capistrano', :git => 'git://github.com/capistrano/capistrano.git'
