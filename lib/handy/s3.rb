module Handy
  class S3

    attr_accessor :bucket_name, :access_key_id, :secret_access_key
    def initialize
      config = YAML.load_file(Rails.root.join('config', 'amazon_s3.yml'))
      unless File.exists?(config)
        raise "file config/amazon_s3.yml was not found. Create a file as per http://gist.github.com/619432"
      end
      self.new(config[env]['username'], config[env]['password'], config[env]['database'])
      @bucket_name = config[env]['bucket_name']
      @access_key_id = config[env]['access_key_id']
      @secret_access_key = config[env]['secret_access_key']
    end

    def connect
      AWS::S3::Base.establish_connection!(access_key_id, secret_access_key)
      AWS::S3::Bucket.create(bucket)
    end

    def store
      connect
      AWS::S3::S3Object.store(file_name, file, bucket)
    end

    def fetch(file_name)
      connected
      AWS::S3::S3Object.find(file_name, bucket)

      file = Tempfile.new("dump")
      open(file.path, 'w') do |f|
        AWS::S3::S3Object.stream(file_name, bucket) do |chunk|
          f.write chunk
        end
      end
      file
    end

    def list
      connect
      AWS::S3::Bucket.find(bucket).objects.collect {|x| x.path }
    end

    def delete(file_name)
      if object = AWS::S3::S3Object.find(file_name, bucket)
        object.delete
      end
    end

  end

end
