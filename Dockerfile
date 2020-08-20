# Dockerfile from
#
#     https://intercityup.com/blog/how-i-build-a-docker-image-for-my-rails-app.html
#
# See more documentation at the passenger-docker GitHub repo:
#
#     https://github.com/phusion/passenger-docker
#
#
FROM phusion/passenger-ruby25

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
RUN bundle update 
# try just update above /  sprockets-rails
RUN bundle install --full-index

# Add the rails app
ADD . /home/app/webapp

# Move the database configuration into place
ADD config/database.docker.yml /home/app/webapp/config/database.yml

# Create the log files
RUN mkdir -p /home/app/webapp/log && \
  touch /home/app/webapp/log/production.log && \
  chown -R app:app /home/app/webapp/log && \
  chmod 0664 /home/app/webapp/log/production.log

# precompile the Rails assets
WORKDIR /home/app/webapp
RUN RAILS_ENV=production bundle exec rake assets:precompile
RUN chown -R app:app /home/app/webapp

# get a few things
RUN apt-get update --fix-missing
RUN apt-get install -y rsync vim iputils-ping
# we will need pip3 --mtoups
RUN apt-get install -y python3-pip
RUN pip3 install cryptography certbot certbot-nginx

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

