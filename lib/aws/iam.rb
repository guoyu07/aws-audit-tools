class IAM
    def initialize()
        @iam = Aws::IAM::Client.new()
    end
    def credentialreport()
        state = ''
        while state != "COMPLETE"
            state = @iam.generate_credential_report().state
        end
        report = @iam.get_credential_report().content
        puts CSV.parse(report, headers: true)
    end
end

