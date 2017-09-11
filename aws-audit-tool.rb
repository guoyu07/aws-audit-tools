require 'aws-sdk'
require 'slop'
require_relative 'lib/aws/sgreview'
require_relative 'lib/aws/vpcroutereview'

$options = Slop.parse do |o|
	o.banner = "aws-audit-tool.rb Usage: "
    o.string '-p', '--profile', 'AWS profile'
    o.string '-r', '--region', 'AWS region'
    o.string '-o', '--operation', 'Audit operation'
end

if $options[:region]
    Aws.config.update(region: $options[:region])
end

if $options[:profile]
    Aws.config.update(profile: $options[:profile])
end

case $options[:operation]
when 'sgreview'
    SGReview.new()
when 'vpcroutereview'
    VPCRouteReview.new()
when 'test'
    puts "Hello World!"
end
