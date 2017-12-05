FROM ruby:latest

WORKDIR /app
ADD app.rb Gemfile ./
RUN bundle install

CMD ruby app.rb
