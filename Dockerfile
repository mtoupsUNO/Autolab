# Dockerfile from
#
#     https://intercityup.com/blog/how-i-build-a-docker-image-for-my-rails-app.html
#
# See more documentation at the passenger-docker GitHub repo:
#
#     https://github.com/phusion/passenger-docker
#
#
FROM phusion/passenger-ruby24

MAINTAINER Autolab Development Team "autolab-dev@andrew.cmu.edu"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down
# Remove the default site
RUN rm /etc/nginx/sites-enabled/default
# Add the nginx info
ADD docker/nginx.conf /etc/nginx/sites-enabled/webapp.conf

# Prepare folders
RUN mkdir /home/app/webapp

# Run Bundle in a cache efficient way
WORKDIR /tmp
ADD Gemfile /tmp/
ADD Gemfile.lock /tmp/
RUN bundle install

# Add the rails app
ADD . /home/app/webapp

RUN mkdir -p /home/app/webapp/courses \
    /home/app/webapp/assessmentConfig \
    /home/app/webapp/courseConfig \
    /home/app/webapp/gradebooks \
    /home/app/webapp/tmp/cache

RUN chown -R app:app /home/app/webapp
# let's try the broad chown above -mt

# Move the database configuration into place
ADD config/database.docker.yml /home/app/webapp/config/database.yml

# some more useful config stuff -mt
#COPY ./config/school.yml /home/app/webapp/config/school.yml
#COPY ./config/autogradeConfig.rb /home/app/webapp/config/autogradeConfig.rb
#COPY ./config/initializers/devise.template.rb /home/app/webapp/config/initializers/devise.rb

# Create the log files
RUN mkdir -p /home/app/webapp/log && \
  touch /home/app/webapp/log/production.log && \
  chown -R app:app /home/app/webapp/log && \
  chmod 0664 /home/app/webapp/log/production.log

# precompile the Rails assets
WORKDIR /home/app/webapp
RUN RAILS_ENV=production bundle exec rake assets:precompile

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

