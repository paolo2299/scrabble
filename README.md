TO SET UP

bundle install --path=vendor/bundle
npm install -g webpack

TO RUN

bundle exec ruby app.rb
open "http://localhost:4567/index.html"

TO MAKE CHANGES TO THE JAVASCRIPT

webpack

TO LINT THE JAVASCRIPT

./node_modules/.bin/eslint src/*

TO RUN THE RUBY TESTS

bundle exec rspec spec
