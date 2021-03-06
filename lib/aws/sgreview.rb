class SGReview
    def initialize()
        self.getAllSG()
    end
    def getAllSG()
        ec2 = Aws::EC2::Resource.new()
        rds = Aws::RDS::Resource.new()
        efs = Aws::EFS::Client.new()
        ec = Aws::ElastiCache::Client.new()
        elb = Aws::ElasticLoadBalancing::Client.new()
        elb2 = Aws::ElasticLoadBalancingV2::Client.new()
        redshift = Aws::Redshift::Client.new()

        rds_vpc_group = {}
        rds.db_instances().each do |instance|
            instance.vpc_security_groups.each do |group|
                (rds_vpc_group[group.vpc_security_group_id] ||= []) << instance.db_instance_identifier
            end
        end

        efs_vpc_group = {}
        efs.describe_file_systems().each do |fs|
            fs.file_systems.each do |fs1|
                efs.describe_mount_targets({file_system_id: fs1.file_system_id,}).each do |mt|
                    mt.mount_targets.each do |mt1|
                        efs.describe_mount_target_security_groups({mount_target_id: mt1.mount_target_id}).each do |mt_sg|
                            mt_sg.security_groups.each do |mt_sg_1|
                                (efs_vpc_group[mt_sg_1] ||= []) << fs1.file_system_id
                            end
                        end
                    end
                end
            end
        end
        
        ec_vpc_group = {}
        ec.describe_cache_clusters().each do |clus|
            clus.cache_clusters.each do |clu|
                clu.security_groups.each do |ec_sg|
                    (ec_vpc_group[ec_sg.security_group_id] ||= []) << clu.cache_cluster_id
                end
            end
        end

        elb_vpc_group = {}
        elb.describe_load_balancers().load_balancer_descriptions.each do |elbs|
            elbs.security_groups.each do |elb_sg|
                (elb_vpc_group[elb_sg] ||= []) << elbs.load_balancer_name
            end
        end
        elb2.describe_load_balancers().load_balancers.each do |elb2s|
            elb2s.security_groups.each do |elb2_sg|
                (elb_vpc_group[elb2_sg] ||= []) << elb2s.load_balancer_name
            end

        end

        redshift_vpc_group = {}
        redshift.describe_clusters().clusters.each do |rs|
            rs.vpc_security_groups.each do |rs_sg|
                (redshift_vpc_group[rs_sg.vpc_security_group_id] ||= []) << rs.cluster_identifier
            end
        end

        ec2.security_groups().each do |sg|
            print "\n"
            puts sg.id + " - " + sg.description + " - " + sg.group_name
            puts "\nEC2 Instances in Security Group"
            instances = ec2.instances({
                filters: [
                  {
                    name: "network-interface.group-id",
                    values: [sg.id],
                  },
                ],
            })
            if instances.count > 0
                instances.each do |instance|
                    print instance.instance_id
                    instance.tags.each do |tag|
                        if tag.key == "Name"
                            print " (" + tag.value + ")\n"
                        end
                    end
                end
            else
                puts "No instances in group"
            end

            puts "\nELB Instanced assigned in Security Group"

            if elb_vpc_group[sg.id]
                puts elb_vpc_group[sg.id]
            else
                puts "No ELB instances in group"
            end
            
            puts "\nRDS Instances assigned in Security Group"
            
            if rds_vpc_group[sg.id]
                puts rds_vpc_group[sg.id]
            else
                puts "No RDS instances in group"
            end

            print "\n"
            
            puts "\Redshift Instances assigned in Security Group"
            
            if redshift_vpc_group[sg.id]
                puts redshift_vpc_group[sg.id]
            else
                puts "No Redshift instances in group"
            end

            puts "\nElastic Files Systems in Security Group"

            if efs_vpc_group[sg.id]
                puts efs_vpc_group[sg.id]
            else
                puts "No EFS in group"
            end

            puts "\nElastiCache Clusters in Security Group"
            
            if ec_vpc_group[sg.id]
                puts ec_vpc_group[sg.id]
            else
                puts "No ElastiCache clusters in group"
            end

            puts "\nInbound Rules\n"
            if sg.ip_permissions.count > 0
                sg.ip_permissions.each do |rule|
                    print "Source: "
                    rule.ip_ranges.each do |range|
                        print range.cidr_ip + ", "
                    end
                    rule.user_id_group_pairs.each do |group|
                        if group.peering_status 
                            print group.user_id + "/"
                        end
                        print group.group_id + ", "
                    end
                    if rule.ip_protocol == "-1"
                        rule.ip_protocol = "ALL"
                    end
                    if rule.from_port == nil && rule.to_port == nil
                        port_range = "ALL"
                    else
                        port_range = rule.from_port.to_s + "-" + rule.to_port.to_s
                    end

                    if rule.ip_protocol == "icmp"
                        port_range = "n/a"
                    end

                    puts "Destination Port Range: " + port_range + " IP Protocol: " + rule.ip_protocol

                end
            else
                puts "No rules"
            end
            puts "Outbound Rules\n"
            if sg.ip_permissions_egress.count > 0
                sg.ip_permissions_egress.each do |rule|
                    print "Source: "
                    rule.ip_ranges.each do |range|
                        print range.cidr_ip + ", "
                    end
                    rule.user_id_group_pairs.each do |group|
                        if group.peering_status 
                            print group.user_id + "/"
                        end
                        print group.group_id + ", "
                    end
                    if rule.ip_protocol == "-1"
                        rule.ip_protocol = "ALL"
                    end
                    if rule.from_port == nil && rule.to_port == nil
                        port_range = "ALL"
                    else
                        port_range = rule.from_port.to_s + "-" + rule.to_port.to_s
                    end

                    if rule.ip_protocol == "icmp"
                        port_range = "n/a"
                    end


                    puts "Destination Port Range: " + port_range + " IP Protocol: " + rule.ip_protocol

                end
            else
                puts "No rules"
            end
        end

    end
    
    def test()
        puts 'Hello World!'
    end
end
