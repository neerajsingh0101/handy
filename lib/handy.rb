require 'aws'

require 'handy/util'
require 'handy/backup'
require 'handy/restore'
require 'handy/s3'
require 'handy/db2db'
require 'handy/dump2s3'

if defined? Rails
  require 'handy/railtie'
end
