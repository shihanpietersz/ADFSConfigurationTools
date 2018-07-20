
Function Set-SPADUserEmailAddressInformation {
    # .ExternalHelp  .\Set-SPADUserEmailAddressInformation.xml
    [CmdletBinding(SupportsShouldProcess)]
    param(
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="ByUserName")]
    [String]$UserName,
    [parameter(ValueFromPipeline=$False,ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="ByOU")]
    [String]$SearchBase,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$NewSMTPDomain,
    [parameter(ValueFromPipeline=$False,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$CurrentSMTPDomain,
    [switch]$EnableCurrentSMTPAlias,
    [switch]$ForceUpdateIfEmpty
    )
    BEGIN{
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] Starting: $($MyInvocation.MyCommand)"
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] PSVersion = $($PSVersionTable.PSVersion)"
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] OS = $((Get-wmiobject win32_OperatingSystem).Caption)"
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] User = $($env:userdomain)\$($env:USERNAME)"
        Write-Verbose "[$((get-date).TimeOfDay.ToString()) BEGIN ] Is Admin = $IsAdmin"
        Import-module ActiveDirectory -Verbose:$false
    }#BEGIN
    PROCESS{
        TRY{
        
            if($UserName){
                $UserInfo = Get-ADUser -Identity $UserName -Properties Name, SamAccountName, EmailAddress, ProxyAddresses
            }#EndiIF
            elseif($SearchBase){
                $UserInfo = Get-ADUser -Filter * -SearchBase $SearchBase -Properties Name, SamAccountName, EmailAddress, ProxyAddresses
            }#EndElseIF
                foreach ($ADUserInfo in $UserInfo){        
                    if($PSCmdlet.ShouldProcess($($ADUserInfo.SamAccountName))){
                        #Check UserEmailAddress
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: User $($AdUserInfo.Name) email address"
                        $PEmailPresent = $False
                        $CEmailPresent = $False
                        $OEmailPresent = $False
                    
                        if($AdUserInfo.EmailAddress -ieq ("$($AdUserInfo.SamAccountName)$($NewSMTPDomain)")){
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Skipping: Email address detected $($AdUserInfo.EmailAddress) skipping email address update"
                            $PEmailPresent = $true
                        }#END_IFF
                        elseif($AdUserInfo.EmailAddress -ieq ("$($AdUserInfo.SamAccountName)$($NewSMTPDomain)")){
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Current email address detected $($AdUserInfo.EmailAddress)"
                            $CEmailPresent = $true
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: email from  $($AdUserInfo.EmailAddress) to "$($AdUserInfo.SamAccountName)$($NewSMTPDomain)""
                            Set-AdUser -Identity $ADUserInfo.SamAccountName -EmailAddress ("$($AdUserInfo.SamAccountName)$($NewSMTPDomain)")
                        }#End_ElseIF
                        else{
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: email address detected $($AdUserInfo.EmailAddress)"
                            $OEmailPresent = $True
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Updating: email from  $($AdUserInfo.EmailAddress) to $($AdUserInfo.SamAccountName)$($NewSMTPDomain)"
                            Set-AdUser -Identity $ADUserInfo.SamAccountName -EmailAddress ("$($AdUserInfo.SamAccountName)$($NewSMTPDomain)")
                        }#EndElse
                        #Check if New PrimarySMTP address and proxy address
                        Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: User $($AdUserInfo.Name) for primary Proxy email address" 
                        $PSMTPProxyPresent = $False
                        $CSMTPProxyPresent = $False
                        $OSMTPProxyPresent = $False
                        $NoSMTPProxyPresent = $False
                        $UpdateUser = $False

                        if($ForceUpdateIfEmpty.IsPresent -and $($ADUserInfo.ProxyAddresses).count -eq 0){
                            $NoSMTPProxyPresent = $true
                        }#END_IF
                        foreach ($ProxyAttribute in $ADUserInfo.ProxyAddresses){
                            if($ProxyAttribute.StartsWith("SMTP:")){
                                if($ProxyAttribute -ieq ("SMTP:$($AdUserInfo.SamAccountName)$($NewSMTPDomain)")){
                                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: New primary SMTP address detected $($ProxyAttribute)"
                                    $PSMTPProxyPresent = $true
                                }#END_IF
                                elseif($ProxyAttribute -ieq ("SMTP:$($AdUserInfo.SamAccountName)$($CurrentSMTPDomain)")){
                                    Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Enumerating: Current primary SMTP address detected $($ProxyAttribute)" 
                                    $CSMTPProxyPresent = $true
                                }#ElseIF
                                else{
                                    $OSMTPProxyPresent = $true
                                }#Else
                            }#EndIF
                        }#ForeachProxyAddress
                        if(($CSMTPProxyPresent -eq $true) -and ($PSMTPProxyPresent -eq $False) -and ($($OSMTPProxyPresent -eq $False))){
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Removing: Removing current primary SMTP address SMTP:$($AdUserInfo.SamAccountName)$($CurrentSMTPDomain)"  
                            $ADUserInfo.ProxyAddresses.remove("SMTP:$($AdUserInfo.SamAccountName)$($CurrentSMTPDomain)")
                            $ADUserInfo.ProxyAddresses.Add("SMTP:$($AdUserInfo.SamAccountName)$($NewSMTPDomain)")
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Removing: Proxy address SMTP:$($AdUserInfo.SamAccountName)$CurrentSMTPDomain"
                            Set-ADUser -Identity $AdUserInfo.SamAccountName -Remove @{proxyAddresses="SMTP:"+$($AdUserInfo.SamAccountName)+$CurrentSMTPDomain}
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Removing: Proxy address smtp:$($AdUserInfo.SamAccountName)$NewSMTPDomain if exists"
                            Set-ADUser -Identity $AdUserInfo.SamAccountName -Remove @{proxyAddresses="smtp:"+$($AdUserInfo.SamAccountName)+$NewSMTPDomain} -ErrorAction SilentlyContinue
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Adding: New Primary SMTP address SMTP:$($AdUserInfo.SamAccountName)$($NewSMTPDomain)"
                            Set-ADUser -Identity $AdUserInfo.SamAccountName -add @{proxyAddresses="SMTP:"+$($AdUserInfo.SamAccountName)+$NewSMTPDomain} 
                            if($EnableCurrentSMTPAlias.IsPresent){
                                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Adding: Current SMTP address smtp:$($AdUserInfo.SamAccountName)$($CurrentSMTPDomain) as alias"
                                Set-ADUser -Identity $AdUserInfo.SamAccountName -Add @{proxyAddresses="smtp:"+$($AdUserInfo.SamAccountName)+$CurrentSMTPDomain}
                            }#End_SubIF
                        }#ENDIF
                        elseif($NoSMTPProxyPresent -eq $true){
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Adding: New primary SMTP address SMTP:$($AdUserInfo.SamAccountName)$($NewSMTPDomain)"
                            Set-ADUser -Identity $AdUserInfo.SamAccountName -add @{proxyAddresses="SMTP:"+$($AdUserInfo.SamAccountName)+$NewSMTPDomain} 
                            if($EnableCurrentSMTPAlias.IsPresent){
                                Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Adding: Current SMTP address smtp:$($AdUserInfo.SamAccountName)$($CurrentSMTPDomain) as alias"
                                Set-ADUser -Identity $AdUserInfo.SamAccountName -Add @{proxyAddresses="smtp:"+$($AdUserInfo.SamAccountName)+$CurrentSMTPDomain}
                            }#End_SubIF
                        }#End_elseIF
                        elseif(($PSMTPProxyPresent -eq $true) -and ($CSMTPProxyPresent -eq $false) -and ($OSMTPProxyPresent -eq $False)){
                            Write-Verbose "[$((get-date).TimeOfDay.ToString()) PROCESS ] Skipping: New primary SMTP address detected SMTP:$($AdUserInfo.SamAccountName)$($NewSMTPDomain)"   
                            $UpdateUser = $False
                        }#End_elseIF  
                    }#END_IF  
                }#Foreach
        }#TRY
        Catch{
            $ErrorMessage = $_.Exception.Message
            $ErrorMessage
        }#Catch
    }#PROCESS
}#Function 

# SIG # Begin signature block
# MIIIaAYJKoZIhvcNAQcCoIIIWTCCCFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDP+oVxmkIAQx6xZ+RbIMVWSr
# 0L6gggXMMIIFyDCCBLCgAwIBAgITHwAAAAKXhlLnQ34QXwAAAAAAAjANBgkqhkiG
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFAgMcG1XJ3JJcf0J
# JIRluSJc9QpyMA0GCSqGSIb3DQEBAQUABIIBADPN1W+F/kg2bPiyvwVh2To4U21u
# HL+9aBxmoBLBiYKzTijcyrZWAeNwGfT7mf23LERRcU/VjXFef+dP+bDml/o+2tPe
# qXUcYkohRrOogu19Bki9VqZjq8CEsUhDQqdl+fCnFcFFxB+2kSdq0LItxa3ZOc5r
# 0bSF4wI4hM3E8sFujSs65RfJ4mzIMyHNWWsP7DBRKR1zH0nCEvqwQWDUjrq2mNPy
# ei8OL/AmE8rKIfV8wysxSY4gZelrvBy0GKCnrMoYOChggcgbgOCoP6Fa8ygHmpLv
# GQaMZYY+Pxyxt1GsUE28NjxjID0U8gZKq2JHELO0+kgOMyVH3pXGqJtexFc=
# SIG # End signature block
