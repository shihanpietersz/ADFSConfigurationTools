Function Update-SPADFSWebApplicationProxyURL {
    # .ExternalHelp  .\Update-SPADFSWebApplicationProxyURL.xml
    param(
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$NewFederatedDomainURL,
          [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$CurrentFederatedDomainURL,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$WebApplicationProxyHostName,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$DomainUsername,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$DomainPassword,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$CertificateThumbprint,
        [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [ValidateScript( {Test-Path $_ -PathType Container})]
        [string]$LogFilePath
    )

    BEGIN{
        try{
            
            $DomainCred = New-MsolSecurePassword  -UserName $DomainUsername -KeyFile "$LogFilePath\Domainkeyfile.txt" -PlainTextPassword $DomainPassword -PasswordFile "$LogFilePath\DomainSecurePass.txt" -Byte 32 -ErrorAction Stop
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Opening: Powershell Session to $($WebApplicationProxyHostName)"
            $ADFSPSSession = New-PSSession -ComputerName $WebApplicationProxyHostName -ErrorAction Stop
        }
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }
    }#BEGIN_END

    PROCESS{
        try{
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Installing: New WebApplication proxy settings"
            $URL1 = "netsh http delete sslcert hostnameport=$($CurrentFederatedDomainURL):443"
            $URL2 = "netsh http delete sslcert hostnameport=$($CurrentFederatedDomainURL):49443"
            $RemoveSSLCerts = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                 & cmd /c $args[0]
                 & cmd /c $args[1]
                 & cmd /c netsh http delete cache  
            } -ArgumentList $URL1, $URL2 -ErrorAction Stop
            
            $InsWebAppProxy = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                Set-WebApplicationProxySslCertificate -Thumbprint $args[0]
                Install-WebApplicationProxy -CertificateThumbprint $Args[0] -FederationServiceName $Args[1] -FederationServiceTrustCredential $args[2]
            } -ArgumentList $CertificateThumbprint, $NewFederatedDomainURL, $DomainCred -ErrorAction Stop

            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: WebApplicationProxyConfiguraion"
            Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                Set-WebApplicationProxyConfiguration -ADFSUrl "https://$($Args[0])/adfs/ls" -OAuthAuthenticationURL "https://$($Args[0])/adfs/oauth2/authorize"
            } -ArgumentList $NewFederatedDomainURL, $DomainCred
            $CurrentWebApps = Get-WebApplicationProxyConfiguration
            $CurrentWebApps | Tee-Object -FilePath "$($logFilePath)\WebApplicationConfigurations_$($date).log" -Append
            Get-Service adfssrv | Restart-Service
        }#Try_END
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }#Catch_END
    }#PROCESS_END

    END{
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Remove: Removing PSSessions on $($PrimaryADFSServer)"
        $ADFSPSSession | Remove-PSSession
    }#END

}#Function




# SIG # Begin signature block
# MIIIaAYJKoZIhvcNAQcCoIIIWTCCCFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2Zr8ncXcaqZqHN9gxrsOmazk
# 0tCgggXMMIIFyDCCBLCgAwIBAgITHwAAAAKXhlLnQ34QXwAAAAAAAjANBgkqhkiG
# 9w0BAQsFADBOMRIwEAYKCZImiZPyLGQBGRYCYXUxEzARBgoJkiaJk/IsZAEZFgNv
# cmcxFDASBgoJkiaJk/IsZAEZFgRBQklPMQ0wCwYDVQQDEwRDQ1JUMB4XDTE4MDcy
# MDAzNDczMFoXDTIwMDcyMDAzNTczMFowZzESMBAGCgmSJomT8ixkARkWAmF1MRMw
# EQYKCZImiZPyLGQBGRYDb3JnMRQwEgYKCZImiZPyLGQBGRYEQUJJTzEOMAwGA1UE
# AxMFVXNlcnMxFjAUBgNVBAMTDUFkbWluaXN0cmF0b3IwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQCNq7s560Wz2Q/s2pZ3sN2r1u0ldKPpGlhhJnzdJMra
# kHKybnUbRB76TY5VBN6t3FDrBMN7qV31gWKn5GHveppDS6gZHVJGQNEcAREpaGgy
# tewEkpmyY7toNSdXn7ydvlqql1AGGu2kGNFA5jEaOqHfm4Nw+Mt0EBfkXXKjSWB5
# 6+0a44feZiAfaGnNUbDq/5P8zgPvnNnrOuKRuagjPy3AehDElk19fDK9ZKOMzu4S
# 11QbPS8Pppc9hOi956d/HysPdKfaCC7UFBlrMagRAOi7M4MDS3JB4heZ5iBcEIBZ
# l7QY6m2NH103YDZ1xUl2cobo196XCiUObCIpZQzbliYPAgMBAAGjggKEMIICgDA9
# BgkrBgEEAYI3FQcEMDAuBiYrBgEEAYI3FQiD9+NKhIacS4eBnT+Gz8FFhKz9TEeB
# vf4ZhaODBgIBZAIBBTATBgNVHSUEDDAKBggrBgEFBQcDAzAOBgNVHQ8BAf8EBAMC
# B4AwGwYJKwYBBAGCNxUKBA4wDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU162YALpI
# MdSWjsWIwbV0i4A8gk0wHwYDVR0jBBgwFoAUKVmuscbhxWcRNj/GnF+rJD3Fdwcw
# gcoGA1UdHwSBwjCBvzCBvKCBuaCBtoaBs2xkYXA6Ly8vQ049Q0NSVCxDTj1GT1NB
# VU1FTERDMDEsQ049Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNl
# cnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QUJJTyxEQz1vcmcsREM9YXU/Y2Vy
# dGlmaWNhdGVSZXZvY2F0aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3Ry
# aWJ1dGlvblBvaW50MIG5BggrBgEFBQcBAQSBrDCBqTCBpgYIKwYBBQUHMAKGgZls
# ZGFwOi8vL0NOPUNDUlQsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2Vz
# LENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9QUJJTyxEQz1vcmcsREM9
# YXU/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNlcnRpZmljYXRpb25B
# dXRob3JpdHkwNAYDVR0RBC0wK6ApBgorBgEEAYI3FAIDoBsMGUFkbWluaXN0cmF0
# b3JAQUJJTy5vcmcuYXUwDQYJKoZIhvcNAQELBQADggEBAFh89pk6ZQf/o99v1yip
# YpDd1FO3R8aRJIOCVAIrkcY/lWngUPzCftxU3qRMwltFLn7qHIApi1U3H7MAvvBG
# GLvEkJUVI1tXg9NqowwLSggPhtzRH/T/G404UL3c3wRFOqm3ctj66FfqIY2JJRds
# UeX6divBXz6SRYfMko+Yedu7xoab/Uz7FHgQ37NZb6Jn+iqanrty88stDSnSy0Zv
# EvnZkUx1BY3ObVUPht4U/SWYS/O2QoK7AOO2SJMOBHIFDB+nlrB4bKwfAe50bGfG
# x4cGstq3EpBRpHh79A3mFhvjOYrCHMkuo+TKeBD8lKbzatq26rhKYnlskWPH8092
# tu0xggIGMIICAgIBATBlME4xEjAQBgoJkiaJk/IsZAEZFgJhdTETMBEGCgmSJomT
# 8ixkARkWA29yZzEUMBIGCgmSJomT8ixkARkWBEFCSU8xDTALBgNVBAMTBENDUlQC
# Ex8AAAACl4ZS50N+EF8AAAAAAAIwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFE36KrOTHchetIXK
# Xjiz4oxxNt4kMA0GCSqGSIb3DQEBAQUABIIBAEqG1IgXZqbH4hKTJNzVjYE00pFg
# PLXchSkRlBYeIxJLBZdlSUW7gETtSr4TqmczvvJA+l4EZjgg5GRV89jue0sXJYLh
# lb8zYLGPSavpai+YxxwWJEd/ts0lyEBp0Dpah0fJ3uzE2og1leiH0plowovQfyA4
# 2gHbvvn0h/9W+a2Sn4lEZTgYGTpu51dWEvNBG9ju/YCJCUh95GIy6EkLLhnOs0qZ
# CnFufmYrUFo70dmrgzmaxA19C/zfdiNxxC+SUfp2MNWsWuQbn4He3rhLsvx3gO2U
# Rwrubm19L053Wdl/pOuUr3AenOzxh28agQE+KD3hfAi913pw1LVzD+quE2g=
# SIG # End signature block
