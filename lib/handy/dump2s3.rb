require 'aws/s3'

module Handy
  class Dump2s3
    def self.run(env, file)
      ::AWS::S3::S3Object.store(file_name, file, bucket)
    end
  end
end
