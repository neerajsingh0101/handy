# A Rails3 compliant gem which provides followings rake tasks#

##rake handy:db:backup##
Creates a dump of data and structure which can been safely backed up

##rake handy:db:restore file=xyz.sql.gz##
restores the data and structure from file 

##rake handy:db:db2db##
Restores the data from production database to staging database. More options can be specified.
 
##rake handy:db:dump2s3##
Creates a backup and then stores that backup on s3. s3 login information can be passed as per http://gist.github.com/619432 .

##rake handy:db:dump2s3:list##
Prints a list of all files stored on s3.

##rake handy:db:dump2s3:restore file=xxxx.sql.gz##
Restores the database with the data from s3. Sweet!! 


Copyright (c) 2010 Neeraj Singh. See LICENSE for details.
