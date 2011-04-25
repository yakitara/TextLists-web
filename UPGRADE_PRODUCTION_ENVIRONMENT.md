Upgrade production environment
==============================


RVM
---
If you want to upgrade ruby, you may need to upgrade RVM to be recognized newer release of rubies.

    rvm snapshot save # It's kind of placebo
    # `rvm get latest` seems to be preferable, but it staled, can't be used
    rvm get head

If you see any error, try:

    rvm reload
    rvm get head


ruby version
------------
If you change ruby version with RVM,

1. update :rvm_ruby_string in config/deploy.rb
2. run `rvm use --default`


Passenger + Nginx
-----------------

    gem install passenger
    passenger-install-nginx-module

When you are asked wehre to install nginx, specify somewhere like this one:

    /opt/nginx/ruby-1.9.2-p180/passenger-3.0.7/nginx-1.0.0

Figure out what to modify nginx.conf by diff #{last nginx.conf} #{new nginx.conf}, then configure it.


Deploy apps to new environment
------------------------------
There are dependencies around ruby, passenger and nginx, so we should better to switch them all at once.

Prepare to modify paths to nginx in /etc/init.d/nginx.

Update code of apps served with the nginx in background while the current intact.

    cap [target task] deploy:update_code

Stop old nginx.

    sudo /etc/init.d/nginx stop

Complete modifying /etc/init.d/nginx.
Then replace current of apps.

    cap [target task] deploy:symlink

Start new nginx.

    sudo /etc/init.d/nginx start
