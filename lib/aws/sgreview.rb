class SGReview
    def initialize()
        self.getAllSG()
    end
    def getAllSG()
        ec2 = Aws::EC2::Resource.new()
        rds = Aws::RDS::Resource.new()
        efs = Aws::EFS::Client.new()
        
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
                puts "\nNo instances in group"
            end

            puts "\nRDS Instances assigned in Security Group"
            
            if rds_vpc_group[sg.id]
                puts rds_vpc_group[sg.id]
            else
                puts "No RDS instances in group"
            end

            print "\n"

            puts "\nElastic Files Systems in Security Group"

            if efs_vpc_group[sg.id]
                puts efs_vpc_group[sg.id]
            else
                puts "No EFS in group"
            end

            puts "\nInbound Rules\n"
            if sg.ip_permissions.count > 0
                sg.ip_permissions.each do |rule|
                    print "Source: "
                    rule.ip_ranges.each do |range|
                        print range.cidr_ip + ", "
                    end
                    rule.user_id_group_pairs.each do |group|
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


                    print "Destination Port Range: " + port_range + " IP Protocol: " + rule.ip_protocol

                    print "\n"
                end
            else
                puts "\nNo rules"
            end
            puts "Outbound Rules\n"
            if sg.ip_permissions_egress.count > 0
                sg.ip_permissions_egress.each do |rule|
                    print "Source: "
                    rule.ip_ranges.each do |range|
                        print range.cidr_ip + ", "
                    end
                    rule.user_id_group_pairs.each do |group|
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


                    print "Destination Port Range: " + port_range + " IP Protocol: " + rule.ip_protocol

                    print "\n"
                end
            else
                puts "\nNo rules"
            end
        end

    end
    
    def test()
        puts 'Hello World!'
    end
end
