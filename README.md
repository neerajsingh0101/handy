# A Rails3 compliant gem which provides followings rake tasks#

##rake handy:db:backup##
Creates a dump of data and structure which can been safely backed up.
file is backuped at <tt>tmp</tt> directory like this <tt>tmp/2011-02-10-22-05-40.sql.gz</tt>

##rake handy:db:restore file=xyz.sql.gz##
restores the data and structure from file

##rake handy:db:db2db##
Restores the data from production database to staging database. More options can be specified.

##rake handy:db:dump2s3##
Creates a backup and then stores that backup on s3.

s3 login information can be passed as per [http://gist.github.com/619432](http://gist.github.com/619432) .


##rake handy:db:dump2s3:list##
Prints a list of all files stored on s3.


##rake handy:db:dump2s3:restore file=xxxx.sql.gz##
Restores the database with the data from s3.


##rake handy:web:ping site=www.eventsinindia.com##
Pings a site.

##Capistrano goodies##

At the bottom of <tt>config/deploy.rb</tt> add following lines:

###restarting server###

    require "handy/capistrano/restart"

Above line ensures that server is restarted when <tt>cap production deploy</tt> is executed

###executing remote tasks###

    require "handy/capistrano/remote_tasks"

After adding above line you can do things like

    cap production remote 'tail -f log/production.log'
    cap production rake 'db:prod2staging'

##refresh local database with data from remote machine###

      require "handy/capistrano/restore_local"

After adding above line you can do <tt>cap production db:restore_local</tt>. This will restore local database with the data from production machine.

###user confirmation###

    require "handy/capistrano/user_confirmation"

After adding above line you will be prompted for a confirmation every single time you do <tt>cap production deploy</tt>. This is to avoid performing any production operation by mistake.

Copyright (c) 2010 Neeraj Singh. See LICENSE for details.
