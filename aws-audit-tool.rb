require 'aws-sdk'
require 'slop'
require 'csv'
require_relative 'lib/aws/sgreview'
require_relative 'lib/aws/vpcroutereview'
require_relative 'lib/aws/systeminventory'
require_relative 'lib/aws/iam'
require_relative 'lib/aws/s3'

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
when 'systeminventory'
    SystemInventory.new()
when 'iam-credentialreport'
    iam = IAM.new()
    iam.credentialreport
when 'public-s3'
    s3 = S3.new()
    s3.getPublicS3
end
