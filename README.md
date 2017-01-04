## Setting up

    bundle install --path=vendor/bundle
    npm install -g webpack

## To run the application

    bundle exec ruby app.rb
    open "http://localhost:4567/index.html"

## Making changes to the Javascript

The Javascript code lives in the *src* directory. After making changes, run

    webpack

to build *public/bundle.js*

## Linting the Javascript

    ./node_modules/.bin/eslint src/*

## Running the ruby tests

    bundle exec rspec spec
