
Function Enable-SPADFSMultiDomainSupport {
    # .ExternalHelp  .\Enable-SPADFSMultiDomainSupport.xml
    [cmdletbinding(SupportsShouldProcess)]
    param( 
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$PrimaryADFSServer,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$MsolUserName,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$MsolPassword,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$NewDomainToFederate
    )

    BEGIN{
        $SecureCred = New-MsolSecurePassword  -UserName $MsolUserName -KeyFile "$PSScriptRoot\keyfile.txt" -PlainTextPassword $MsolPassword -PasswordFile "$PSScriptRoot\SecurePass.txt" -Byte 32 -ErrorAction Stop
        $ADFSPSSession = New-PSSession -ComputerName $PrimaryADFSServer
    }

    PROCESS{
        Try{
            $NewFederationSupportStatus += @()
            $ADFSCurrentFederatedDomainInfo += @()
            $MsolCurrentdDomainInfo += @()
            $NewFederationStatus = $false
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Active Federated Domains"
            
                $MsolCurrentdDomainInfo = Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                {
                    Connect-MsolService -Credential $Args[0]
                    Get-MsolDomain 
                } -ArgumentList $SecureCred -ErrorAction stop
                
                foreach ($Domain in $MsolCurrentdDomainInfo){
                    $ADFSCurrentFederatedDomainInfo += $Domain | Where-Object {$_.Authentication -eq "Federated"}
                }#Foreach_END
                
                
                foreach ($FDDoman in $ADFSCurrentFederatedDomainInfo){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Information: Domain $($FDDoman.Name) is $($FDDoman.Authentication)"   
                }#Foreach_END
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Information: Total Federated Domains found  $($ADFSCurrentFederatedDomainInfo.count)"        
        

            if($PSCmdlet.ShouldContinue("Temporary Service interruptions will occur during ADFS federation of  Domain $($NewDomainToFederate)", 'Confirm ?')){
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Removing: Removing Relaying PartyTrust on primary ADFS Server $($PrimaryADFSServer)"
                Invoke-Command -ComputerName $PrimaryADFSServer -ScriptBlock `
                {
                Get-AdfsRelyingPartyTrust | Where-Object {$_.Name -eq "Microsoft office 365 Identity Platform"} | Remove-AdfsRelyingPartyTrust
                } -ErrorAction Stop
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Remove: Complete"
                foreach($FD in $ADFSCurrentFederatedDomainInfo.Name){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: Existing federated domain to support Multidomain"
                    
                        $FDDomainUpdate = Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                        {
                            Connect-MsolService -Credential $Args[0]
                            Update-MsolFederatedDomain  -DomainName $Args[1] -SupportMultipledomain
                        }  -ArgumentList $SecureCred, $FD -ErrorAction Stop
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: $($FDDomainUpdate) to support Multidomain"    
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: $($NewDomainToFederate) as federated domain and enabling Multidomain support"
                    if($NewFederationStatus -eq $false){
                        $NewFederationSupportStatus += Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                        {
                        Connect-MsolService -Credential $Args[0]    
                        Convert-MsolDomainToFederated -DomainName $Args[1] -SupportMultipledomain
                        Update-MsolFederatedDomain -domainName $Args[1] -SupportMultipleDomain 
                        Get-Service adfssrv | Restart-Service
                        } -ArgumentList $SecureCred, $NewDomainToFederate -ErrorAction Continue
                    }#IF_END
                    $NewFederationStatus = $true

                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Informaton: Status MultiDomain $($NewFederationSupportStatus)"
                }#foreach_END
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Informaton: Operation Complete"
            }#END_IF
        }#Try_END
        Catch{
            $ErrorMessage = $_.Exception.Message
            throw $ErrorMessage
        }#Catch_END
    }#Process

    END{
        
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] ServiceRestart:  restarting Adfssrv service on $($PrimaryADFSServer)"
        Invoke-Command -Session $ADFSPSSession -ScriptBlock {Get-Service adfssrv | Restart-Service}
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Remove: Removing PSSessions on $($PrimaryADFSServer)"
        $ADFSPSSession | Remove-PSSession
    }

}#End_Function  

# SIG # Begin signature block
# MIIIaAYJKoZIhvcNAQcCoIIIWTCCCFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkJ+CYIx0kQhR9bGL9FDkJJ9q
# hSagggXMMIIFyDCCBLCgAwIBAgITHwAAAAKXhlLnQ34QXwAAAAAAAjANBgkqhkiG
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFFIxM6njO/96AZeV
# k7J5a3VKzAeiMA0GCSqGSIb3DQEBAQUABIIBADq6zIGH9PjmAlO3TmcK3fZzB5nc
# yxjgwz3+zcQ4F/U5tt9zA5fy/ZnSqogcDBMLBdV8fEjcJvr3GrIBTZC/UVKfbTXP
# 9ytVxLS1QelmwG+gMmkR4yM2Lbti1wlRO7EB94FLxtcq7OuwGK4hv97u/wyKbh1D
# sMJCW1sSj9yyoj1FIt5WWdIvY1XipRet+Y3xxFgRjeRnBL+CGIcDhOCs9/aSpvnF
# o/BOXyAYFrMINXtSAGQVKgfT9wn6EuWJ0wTLIIlqDav+hPV8mdiiAfy4LqGtLl4S
# k46yOSqPV0GsUA+YbeCOdLgIPQNR1xsraeWp90qeYY0hCAQArbHQYJfhakc=
# SIG # End signature block
