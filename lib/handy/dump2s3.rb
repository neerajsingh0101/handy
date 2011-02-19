module Handy
  class S3

    attr_accessor :bucket_name, :access_key_id, :secret_access_key, :bucket_instance

    # This module relies on following things to be present:
    #
    # AppConfig.s3_bucket_name
    # AppConfig.s3_secret_access_key_id
    # AppConfig.s3_secret_secret_access_key
    #
    def initialize(env)
      @bucket_name = AppConfig.s3_bucket_name
      @access_key_id = AppConfig.s3_access_key_id
      @secret_access_key = AppConfig.s3_secret_access_key
      @s3_instance = Aws::S3.new(access_key_id, secret_access_key)

      if @bucket_name.nil? || @access_key_id.nil? || @secret_access_key.nil?
        raise "looks like aws/s3 credentials are not set properly"
      end

      @bucket_instance = Aws::S3::Bucket.create(@s3_instance, bucket_name)
      begin
        @bucket_instance.keys
      rescue
        @bucket_instance = Aws::S3::Bucket.create(@s3_instance, bucket_name, true)
      end
    end

    def store(file_name, file_data)
      @bucket_instance.put(file_name, file_data)
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


    def delete(file_name)
      if object = AWS::S3::S3Object.find(file_name, bucket)
        object.delete
      end
    end

  end

end


module Handy
  class Dump2s3

    def self.run(env, file_name)
      s3 = Handy::S3.new(Rails.env)
      s3.store(file_name, open(Rails.root.join('tmp', file_name)))
      Handy::Util.pretty_msg("#{file_name} has been backedup at s3.")
    end

    def self.list(env)
      s3 = Handy::S3.new(Rails.env)
      Handy::Util.pretty_msg("List of files on s3 for bucket #{s3.bucket_name}")
      s3.bucket_instance.keys.each {|e| puts e}
    end

    def self.restore(env, file_name)
      s3 = Handy::S3.new(Rails.env)
      keyinfo = s3.bucket_instance.key(file_name)
      raise "no file named #{file_name} was found on s3. Please check the file list on s3" if keyinfo.blank?
      data = s3.bucket_instance.get(file_name)
      storage_dir = Rails.root.join('tmp', file_name)
      open(storage_dir, 'w') do |f|
        f.write data
      end
      Handy::Util.pretty_msg("file #{file_name} has been downloaded to #{storage_dir.expand_path}")
    end

  end

end
