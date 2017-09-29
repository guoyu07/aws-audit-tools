class SystemInventory
    def initialize() 
        puts "AWS System Inventory as of " + Time.now.to_s
        
        ec2 = self.getEC2()
        rds = self.getRDS()
        s3 = self.getS3()
        elb = self.getELB()
    end
    def getEC2()
        ec2 = Aws::EC2::Client.new()
        puts "EC2 Instances"
        puts "Instance ID\tInstance Name\tImage ID\tState\tPrivate IP\tPublic IP\tVPC ID\tSubnet ID\tSecurity Groups\tTags"
        ec2.describe_instances().reservations.each do |instances|
            instances.instances.each do |instance|
                name = ''
                instance.tags.each do |tag|
                    if tag.key == "Name"
                        name = tag.value
                    end
                end
                print instance.instance_id.to_s + "\t" + name.to_s + "\t" + instance.image_id.to_s + "\t" + instance.state.name + "\t" + instance.private_ip_address.to_s + "\t" + instance.public_ip_address.to_s + "\t" + instance.vpc_id.to_s + "\t" + instance.subnet_id.to_s + "\t"
                instance.security_groups.each do |sg|
                    print sg.group_id + " "
                end
                print "\t"
                instance.tags.each do |tag|
                    print tag.key + ":" + tag.value + " "
                end 
                print "\n"
            end
        end
    end
    def getRDS()
        puts "RDS Instances"
        puts "Instance Identifier\tDB Engine\tAddress\tPort\tVPC Security Groups\t"
        rds = Aws::RDS::Client.new()
        rds.describe_db_instances.db_instances.each do |instance|
            print instance.db_instance_identifier.to_s + "\t" + instance.engine.to_s + "\t" + instance.endpoint.address.to_s + "\t" + instance.endpoint.port.to_s + "\t"
            instance.vpc_security_groups.each do |sg|
                print sg.vpc_security_group_id.to_s + " "
            end
            print "\n"
        end
    end
    def getS3()
        puts "S3 Buckets"
        puts "Bucket Name\tOwner\tACL\tPolicy"
        s3 = Aws::S3::Client.new()
        s3.list_buckets.buckets.each do |bucket|
            print bucket.name.to_s + "\t"
            acls = s3.get_bucket_acl({
                bucket: bucket.name.to_s
            })
            begin
                policy = s3.get_bucket_policy({
                   bucket: bucket.name.to_s
                })
            rescue
                # If there isn't a policy on a bucket an exception is thrown...
            end
            acls.each do |acl|
                print acl.owner.display_name.to_s + "\t"
                acl.grants.each do |grant|
                    if grant.grantee.type == "CanonicalUser"
                        print "(Grantee: " + grant.grantee.display_name.to_s + " Permission: " + grant.permission.to_s + ") "
                    elsif grant.grantee.type == "Group"
                        print "(Grantee: " + grant.grantee.uri.to_s + " Permission: " + grant.permission.to_s + ") "
                    end
                end
            end

            print "\t"
            if policy
                print policy.policy.read
            end
            print "\n"
        end
    end
    def getELB()
        puts "Elastic Load Balancers"
        puts "Load Balancer Name\tDNS Name\tType\tSecurity Groups"
        elb = Aws::ElasticLoadBalancingV2::Client.new()
        if elb.describe_load_balancers.load_balancers.count > 0
            elb.describe_load_balancers.load_balancers.each do |lb|
                print lb.load_balancer_name + "\t" + lb.dns_name + "\t" + lb.type + "\t"
                lb.security_groups.each do |sg|
                    print sg + " "
                end
                print "\n"
            end
        else
            print "No Load Balancers\n"
        end
    end
end