#!/usr/bin/env pwsh

# Copy this file to "ade.personal.ps1" and update the below arguments to use as a cli-based script
deploy `
    -alias 'abcdef' `
    -email 'abcdef@website.com' `
    -resourceUserName 'abcdef' `
    -rootDomainName "website.com" `
    -resourcePassword 'SampleP@ssword123!' `
    -certificatePassword 'SampleP@ssword123!' `
    -localNetworkRange '192.168.0.0/24' `
    -skipConfirmation `
    -overwriteParameterFiles