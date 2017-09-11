class VPCRouteReview
    def initialize()
        ec2 = Aws::EC2::Client.new()
        
        ec2.describe_vpcs().vpcs.each do |vpc|
            print "VPC: " + vpc.vpc_id + " CIDR Block: " + vpc.cidr_block
            vpc.tags.each do |tag|
                if tag.key == 'Name'
                    print " (" + tag.value + ")"
                end
            end
            print "\n"
           
            ec2.describe_subnets({
                filters: [
                    {
                        name: "vpc-id",
                        values: [vpc.vpc_id],
                    },
                ],
            }).subnets.each do |subnet|
                puts "\t" + subnet.subnet_id + " " + subnet.cidr_block
                ec2.describe_route_tables({
                    filters: [
                      {
                        name: "vpc-id",
                        values: [vpc.vpc_id],
                      },
                      {
                        name: "association.subnet-id",
                        values: [subnet.subnet_id],
                      },
                    ],
                }).route_tables.each do |route|
                    route.routes.each do |n_route|
                        print "\t\t"
                        print n_route
                        print "\n"
                    end
                end
            end
            
            
            exit

            ec2.describe_vpc_peering_connections({
                filters: [
                  {
                    name: "accepter-vpc-info.vpc-id",
                    values: [vpc.vpc_id],
                  },
                ],
            }).vpc_peering_connections.each do |peer|
                print "\t"
                print "VPC " + peer.accepter_vpc_info.owner_id + "/" + peer.accepter_vpc_info.vpc_id + " is peered to " + peer.requester_vpc_info.owner_id + "/" + peer.requester_vpc_info.vpc_id + " as peering connection " + peer.vpc_peering_connection_id
                peer.tags.each do |tag|
                    if tag.key == 'Name'
                        print " (" + tag.value + ")"
                    end
                end
                print "\n"
            end
            ec2.describe_vpc_peering_connections({
                filters: [
                  {
                    name: "requester-vpc-info.vpc-id",
                    values: [vpc.vpc_id],
                  },
                ],
            }).vpc_peering_connections.each do |peer|
                print "\t"
                print "VPC " + peer.accepter_vpc_info.owner_id + "/" + peer.accepter_vpc_info.vpc_id + " is peered to " + peer.requester_vpc_info.owner_id + "/" + peer.requester_vpc_info.vpc_id + " as peering connection " + peer.vpc_peering_connection_id
                peer.tags.each do |tag|
                    if tag.key == 'Name'
                        print " (" + tag.value + ")"
                    end
                end
                print "\n"
                
            end
        end
        exit
        
        
        
        
        
    end

end
