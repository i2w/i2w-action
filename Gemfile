source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in i2w-action.gemspec.
gemspec

group :development do
  # TODO move to gemspec when published as gems
  gem 'i2w-result', github: 'i2w/i2w-result', branch: 'main'
  gem 'i2w-human', github: 'i2w/i2w-human', branch: 'main'

  # this is a dev dependency
  # gem 'i2w-repo', github: 'i2w/i2w-repo', branch: 'main'
  gem 'i2w-repo', path: '../i2w-repo'
end

# To use a debugger
# gem 'byebug', group: [:development, :test]
