class SGReview
    def initialize()
        self.getAllSG()
    end
    def getAllSG()
        ec2 = Aws::EC2::Resource.new()
        rds = Aws::RDS::Resource.new()
        rds_vpc_group = {}
        rds = Aws::RDS::Resource.new()
        rds.db_instances().each do |instance|
            #puts instance.db_instance_identifier
            instance.vpc_security_groups.each do |group|
                #puts group.vpc_security_group_id
                (rds_vpc_group[group.vpc_security_group_id] ||= []) << instance.db_instance_identifier
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
                    print instance.instance_id + "\n"
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
            #ip_permissions_egress
        end

    end
    
    def test()
        puts 'Hello World!'
    end
end
