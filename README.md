# handy provides follwing tools

##rake handy:db:backup##
Creates a dump of data and structure which can been safely backed up

##rake handy:db:restore file=xyz.sql.gz##
restores the data and structure from file 

##rake handy:db:db2db##
restores the data from production database to staging database
 
##rake handy:db:dump2s3##
Creates a backup and then stores that backup on s3

##rake handy:db:dump2s3:list##
Prints a list of all files stored on s3

##rake handy:db:dump2s3:restore file=xxxx.sql.gz##
Restores the database with the data from s3. 


Copyright (c) 2010 Neeraj Singh. See LICENSE for details.
