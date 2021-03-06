Function Update-SPADFSUrlEndpoint {
# .ExternalHelp  .\Update-SPADFSUrlEndpoint.xml
    [cmdletbinding(SupportsShouldProcess)]
    param(
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$PrimaryADFSServer,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$CurrentFederatedDomainURL,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$NewFederatedDomainURL,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string[]]$FederatedDomains,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$NewFederatedDisplayName,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$MsolUserName,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$MsolPassword,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$DomainUsername,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$DomainPassword,
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [string]$CertificateThumbprint,
        [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
        [ValidateScript( {Test-Path $_ -PathType Container})]
        [string]$LogFilePath,
        [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$false)]
        [switch]$MultiDomainSupportEnabled
    )

    BEGIN{
       
        $SecureCred = New-MsolSecurePassword  -UserName $MsolUserName -KeyFile "$LogFilePath\keyfile.txt" -PlainTextPassword $MsolPassword -PasswordFile "$LogFilePath\SecurePass.txt" -Byte 32 -ErrorAction Stop
        $DomainCred = New-MsolSecurePassword  -UserName $DomainUsername -KeyFile "$LogFilePath\Domainkeyfile.txt" -PlainTextPassword $DomainPassword -PasswordFile "$LogFilePath\DomainSecurePass.txt" -Byte 32 -ErrorAction Stop
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Opening: Powershell Session to $($PrimaryADFSServer)"
        $ADFSPSSession = New-PSSession -ComputerName $PrimaryADFSServer
        Function Get-ADFSCurrentServiceProperties {
            param(
                [object]$ADFSSession,
                [String]$LogFilePath,
                [boolean]$AdfsUpdateStatus
            )
            $CurrentADFSProerties = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                Get-AdfsProperties | Select-Object *
                } -ErrorAction Stop
                    if($AdfsUpdateStatus -eq $False){
                        $CurrentADFSProerties | Tee-Object -FilePath "$($logFilePath)\CurrentADFSProperties_$($date).log" -Append
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Current ADFS properties written to log file $($logFilePath)\CurrentADFSProperties_$($date).log"
                    }#IF_End
                    else{
                        $CurrentADFSProerties | Tee-Object -FilePath "$($logFilePath)\UpdatedADFSProperties_$($date).log" -Append
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Updated ADFS properties written to log file $($logFilePath)\UpdatedADFSProperties_$($date).log"
                    }#Eles_EnD
        }#End_SubFunction_Get-ADFSCurrentServiceProperties

        Function Get-ADFSCertificateStatus {
            param(
            [object]$ADFSSession,
            [String]$LogFilePath,
            [boolean]$AdfsCertUpdateStatus
            )
            $CurrentADFSCertificateStatus = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                Get-AdfsSslCertificate | Select-Object *
                } -ErrorAction Stop
                    if($AdfsCertUpdateStatus -eq $False){
                        $CurrentADFSCertificateStatus | Tee-Object -FilePath "$($logFilePath)\CurrentADFSSSLCertificateStatus_$($date).log" -Append
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Current ADFS certificate status  written to log file $($logFilePath)\CurrentADFSSSLCertificateStatus_$($date).log"
                    }#IF_End
                    else{
                        $CurrentADFSCertificateStatus | Tee-Object -FilePath "$($logFilePath)\UpdatedADFSSSLCertificateStatus_$($date).log" -Append
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Updated ADFS certificate status written to log file $($logFilePath)\UpdatedADFSSSLCertificateStatus_$($date).log"
                    }#Eles_EnD
        }#End_SubFunction_Get-ADFSCurrentServiceProperties

        Function Get-AdfsCommunicationCertificateStatus {
            param(
                [object]$ADFSSession,
                [String]$LogFilePath,
                [boolean]$AdfsComCertStatus
                )   
                $CurrentADFSComCertStatus = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                    Get-AdfsCertificate | Select-Object *
                    } -ErrorAction Stop
                        if($AdfsComCertStatus -eq $False){
                            $CurrentADFSComCertStatus | Tee-Object -FilePath "$($logFilePath)\CurrentADFSComCert_$($date).log" -Append
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Current ADFS communication certificate status  written to log file $($logFilePath)\CurrentADFSComCert_$($date).log"
                        }#IF_End
                        else{
                            $CurrentADFSComCertStatus  | Tee-Object -FilePath "$($logFilePath)\UpdatedADFSComCert_$($date).log" -Append
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Updated ADFS communication certificate status written to log file $($logFilePath)\UpdatedADFSComCert_$($date).log"
                        }#Eles_EnD
        }#END_Function_Get-AdfsCommunicationCertificateStatus

        Function Get-ADFSCertificateBindingStaus {
            param(
            [object]$ADFSSession,
            [String]$LogFilePath,
            [boolean]$AdfsCertBindingStatus
            )
            $CurrentADFSCertificateBinding = Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                        netsh http show sslcert
                    } -ErrorAction Stop | Out-Null
                    if($AdfsCertBindingStatus -eq $False){
                        $CurrentADFSCertificateBinding | Tee-Object -FilePath "$($logFilePath)\CurrentADFSCertificateBinding$($date).log" -Append
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Current ADFS certificate binding status  written to log file $($logFilePath)\CurrentADFSSSLCertificateStatus_$($date).log"
                    }#IF_End
                    else{
                        $CurrentADFSCertificateBinding | Tee-Object -FilePath "$($logFilePath)\UpdatedADFSCertificateBinding$($date).log" -Append
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Creating: Updated ADFS certificate binding status written to log file $($logFilePath)\UpdatedADFSSSLCertificateStatus_$($date).log"
                    }#Eles_EnD
        }#ENd_SubFunction_Get-ADFSCertificateBindingStatus
    }#BEGIN

    PROCESS{
        TRY{
            if($PSCmdlet.ShouldProcess("$($PrimaryADFSServer)")){
                $Date = (get-date).ToString("ddMMyyyy_hh_mm_ss")
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Current ADFS properties on $($PrimaryADFSServer)"
                Get-ADFSCurrentServiceProperties -ADFSSession $ADFSPSSession -LogFilePath $LogFilePath -AdfsUpdateStatus $False | Out-Null
                    if($PSCmdlet.ShouldContinue("BEGIN STEP 01 ?", "Service interruptions can occur during ADFS URL Update to $($NewFederatedDomainURL)")){
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP01 - START"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP01 - ADFS server $($PrimaryADFSServer) with new URL information"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP01 - ADFS DisplayName to $($NewFederatedDisplayName)"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP01 - ADFS Hostname to $($NewFederatedDomainURL)"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP01 - ADFS Identifier to http://$($NewFederatedDomainURL)/adfs/services/trust"

                        Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                            Set-AdfsProperties -DisplayName $args[0] -hostname $args[1] -Identifier $args[2]
                        } -ArgumentList $($NewFederatedDisplayName), $($NewFederatedDomainURL), "http://$($NewFederatedDomainURL)/adfs/services/trust" -ErrorAction Stop | Out-Null

                        Get-ADFSCurrentServiceProperties -ADFSSession $ADFSPSSession -LogFilePath $LogFilePath -AdfsUpdateStatus $true | Out-Null
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] COMPLETE: STEP01 COMPLETE"
                    }#Confirm
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Current ADFS certificate status on $($PrimaryADFSServer)"
                    Get-ADFSCertificateStatus -ADFSSession $ADFSPSSession -AdfsCertUpdateStatus $False -LogFilePath $LogFilePath | Out-Null
                    if($PSCmdlet.ShouldContinue("BEGIN STEP02 ?", "Service interruptions can occur during ADFS Certificate Update to $($NewFederatedDomainURL)")){
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP02 - START"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP02 - ADFS server $($PrimaryADFSServer) with new SSL Certificate using thumbprint $($CertificateThumbprint)"
                        Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                            Set-AdfsSslCertificate -Thumbprint $args[0]
                        } -ArgumentList $CertificateThumbprint -ErrorAction Stop
                        Get-ADFSCertificateStatus -ADFSSession $ADFSPSSession -AdfsCertUpdateStatus $true -LogFilePath $LogFilePath | Out-Null
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] COMPLETE: STEP02 COMPLETE"
                }#Confirm
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Current ADFS Service Communication, Token Signing/Decrypting certificate status on $($PrimaryADFSServer)"
                Get-AdfsCommunicationCertificateStatus -ADFSSession $ADFSPSSession -LogFilePath $LogFilePath -AdfsComCertStatus $false | Out-Null

                    if($PSCmdlet.ShouldContinue("BEGIN STEP03", "Service interruptions can occur during ADFS Communication Certificate Update to $($NewFederatedDomainURL)")){
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP03 - START"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP03 - ADFS server $($PrimaryADFSServer) with new SSL Certificate using thumbprint $($CertificateThumbprint)"
                        Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                            Set-AdfsCertificate -CertificateType Service-Communications -Thumbprint $args[0]
                            Update-AdfsCertificate -Urgent
                        } -ArgumentList $CertificateThumbprint -ErrorAction Stop
                        Get-AdfsCommunicationCertificateStatus -ADFSSession $ADFSPSSession -AdfsComCertStatus $true -LogFilePath $LogFilePath | Out-Null
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] COMPLETE: STEP03 COMPLETE"
                    }#Confirm
                    if($PSCmdlet.ShouldContinue("BEGIN STEP04 ?", "ADFS services will be offline until all remaining tasks are completed")){
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP04 - START"
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] ServiceRestart: STEP04   restarting Adfssrv service on $($PrimaryADFSServer)"
                        Invoke-Command -Session $ADFSPSSession -ScriptBlock {Get-Service adfssrv | Restart-Service} -ErrorAction Stop
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] COMPLETE: STEP04 - COMPLETE"
                    }#Confirm
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Current ADFS communication certificate status on $($PrimaryADFSServer)"
                Get-ADFSCertificateBindingStaus -ADFSSession $ADFSPSSession -AdfsCertUpdateStatus $False | Out-Null
                if($PSCmdlet.ShouldContinue("BEGIN STEP05 ?", "Removing SSL binding from domain $($CurrentFederatedDomainURL)")){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP05 - START"
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Removing: STEP05 - SSL binding $($PrimaryADFSServer)"
                    $URL1 = "netsh http delete sslcert hostnameport=$($CurrentFederatedDomainURL):443"
                    $URL2 = "netsh http delete sslcert hostnameport=$($CurrentFederatedDomainURL):49443"
                    Invoke-Command -Session $ADFSPSSession -ScriptBlock {
                        & cmd /c $args[0]
                        & cmd /c $args[1]
                    } -ArgumentList  $URL1, $URL2 -ErrorAction Stop | Out-Null
                    Get-ADFSCertificateBindingStaus -ADFSSession $ADFSPSSession -AdfsCertUpdateStatus $True | Out-Null
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] COMPLETE: STEP05 COMPLETE"
                }#Confirm
                if($PSCmdlet.ShouldContinue("BEGIN STEP06 ?", "Updating Domains on Microsoft Online")){
                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP06 - START"
                    foreach ($FederatedDomain in $FederatedDomains){
                    if($MultiDomainSupportEnabled.IsPresent){
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP06 $($FederatedDomain) on Microsoft Office365"
                            Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                            {
                            Set-MsolADFSContext -Computer $Args[2] -ADFSUserCredentials $Args[3]
                            Connect-MsolService -Credential $Args[0]
                            Update-MsolFederatedDomain -domainName $Args[1] -SupportMultipleDomain
                            Get-Service adfssrv | Restart-Service
                            } -ArgumentList $SecureCred, $FederatedDomain, $PrimaryADFSServer, $DomainCred -ErrorAction Stop
                    }#END_IF
                    else{
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: STEP06 $($FederatedDomain) on Microsoft Office365"
                            Invoke-Command -Session $ADFSPSSession -ScriptBlock `
                            {
                            Set-MsolADFSContext -Computer $Args[2] -ADFSUserCredentials $Args[3] 
                            Connect-MsolService -Credential $Args[0]
                            Update-MsolFederatedDomain -domainName $Args[1]
                            Get-Service adfssrv | Restart-Service
                            } -ArgumentList $SecureCred, $FederatedDomain, $PrimaryADFSServer, $DomainCred -ErrorAction Stop
                    }#else
                    }#Forech_END
                }#Config
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] COMPLETE: STEP06 - COMPLETE"
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] ServiceRestart: STEP07 Restarting Adfssrv service on $($PrimaryADFSServer)"
                Invoke-Command -Session $ADFSPSSession -ScriptBlock {Get-Service adfssrv | Restart-Service} -ErrorAction Stop
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] ServiceRestart: STEP07 COMPLETE)"
            }#IF_END
        }#Try
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }#catch
        }#PROCESS

        END{
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Remove: Removing PSSessions on $($PrimaryADFSServer)"
            $ADFSPSSession | Remove-PSSession
            Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Testing: Testing Updated ADFS URL https://$($NewFederatedDomainURL)/adfs/ls/idpinitiatedsignon.htm"
            $ADFSTestStatus = Invoke-WebRequest -Uri https://$($NewFederatedDomainURL)/adfs/ls/idpinitiatedsignon.htm -ErrorAction SilentlyContinue
            if($($ADFSTestStatus.StatusDescription) -eq "OK"){
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Testing: Test from Internal to ADFS URL https://$($NewFederatedDomainURL)/adfs/ls/idpinitiatedsignon.htm Successful"
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Information: Update Web Application Proxy servers if in use"
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] Information: URL Update completed, Microsoft Online Services can take between 10 - 30 Mins to update settings"
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] COMPLETE: Task Complete"
            }#IF_END
            else{
                Write-Error -Message "Test Failed to https://$($NewFederatedDomainURL)/adfs/ls/idpinitiatedsignon.htm, Check ADFS configuration settings and log files"
                Write-Verbose "[$((get-date).TimeOfDay.ToString()) END ] COMPLETE: Task Complete"
            }#Else_END
        }#END



}#Function

# SIG # Begin signature block
# MIIIaAYJKoZIhvcNAQcCoIIIWTCCCFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+qF0KsJN6bmFKVSNoXWZA+Rh
# U9agggXMMIIFyDCCBLCgAwIBAgITHwAAAAKXhlLnQ34QXwAAAAAAAjANBgkqhkiG
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFE+U0chPm0A85QbB
# 2F+TKYw2RRDwMA0GCSqGSIb3DQEBAQUABIIBAEE/8hUVhVSemFxKA5jaa2LCVlcG
# QW2WDawI9BGBIY2kCGFbwma6z/Wij14SvhSntExYxD9fJA/WzV/7yv4ALWpYeF6s
# 3fPg+ikdHwkb1Y15Dk+i+BrvAwYgxL+3DeqDNBosystE3SSV/ntVEhxnNlGxppXF
# y/1GdpTcgeWkyjjcNDoP2fKIyaJh06tl0J7lrzYQsPxtGpYNFpb4BGHX778h/t2x
# 74GlwEcwin6sLlPHrl3I/ys5QEbn+Pmwf/37eo4DNP9OEtHQCetWztPlSqltauwe
# xln94y5aniYK2rYMFWvsULDWBP3xXK26CRqyaxNDwKIxPvL8GozX6jMzjmA=
# SIG # End signature block
