class S3
    def getPublicS3()
        puts "S3 Buckets"
        puts "Bucket Name\tPermission"
        s3 = Aws::S3::Client.new()
        s3.list_buckets.buckets.each do |bucket|
            begin
                policy = s3.get_bucket_policy({
                   bucket: bucket.name.to_s
                })
                bucket_policy = JSON.parse(policy.policy.read)
                bucket_policy['Statement'].each do |statement|
                    if (statement['Principal'] == '*' || statement['Principal']['AWS'] == '*') && statement['Effect'] == 'Allow'
                        print bucket.name.to_s + "\t" + statement.inspect + "\n"
                    end
               end
            rescue
                # If there isn't a policy on a bucket an exception is thrown...
            end
            acls = s3.get_bucket_acl({
                bucket: bucket.name.to_s
           })
            acls.each do |acl|
                acl.grants.each do |grant|
                    if grant.grantee.uri.to_s == "http://acs.amazonaws.com/groups/global/AllUsers"
                        print bucket.name.to_s + "\t" + grant.grantee.uri.to_s + " " + grant.permission.to_s + "\n"
                    end
                end
            end
        end
    end
end