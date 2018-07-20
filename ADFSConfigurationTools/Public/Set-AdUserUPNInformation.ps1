Function Set-AdUserUPNInformation {
    [cmdletbinding(supportsshouldprocess)]
    param(
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="ByUsername")]
    [string]$UserName,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true,ParameterSetName="BySearchBase")]
    [string]$SearchBase,
    [parameter(ValueFromPipeline=$false,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [string]$Domain
    )
    BEGIN{

    }#End Begin

    PROCESS{
            if($UserName){
                $UserInfo = Get-ADUser -Identity $UserName -Properties Name, SamAccountName, EmailAddress, UserPrincipalName
            }#EndiIF
            elseif($SearchBase){
                $UserInfo = Get-ADUser -Filter * -SearchBase $SearchBase -Properties Name, SamAccountName, EmailAddress, UserPrincipalName
            }#EndElseIF
            foreach($ADUser in $UserInfo){
                if($PSCmdlet.ShouldProcess($ADUser.SamAccountName, "Set new domain UPN $($Domain)")){
                    Set-Aduser -Identity $ADUser.SamAccountName -UserPrincipalName "$($ADUser.SamAccountName)@$($Domain)"
                }#EndIF
            }#Foreach
    }#End Process

    END{
        #LeftBlank
    }#END
}#End Function

# SIG # Begin signature block
# MIIIaAYJKoZIhvcNAQcCoIIIWTCCCFUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUzVniZX3y11X2IrfNBgiSdd0
# +9KgggXMMIIFyDCCBLCgAwIBAgITHwAAAAKXhlLnQ34QXwAAAAAAAjANBgkqhkiG
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
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFH6fKI+Rz/UyYk9e
# 3ARU+m++FpEpMA0GCSqGSIb3DQEBAQUABIIBAIibzpMidf/lylH9V1pQnjFVyADJ
# E0KycFiO2O8fS2iF4gZaaofo/tQtH/5eeorccM6EOA3gwhavBHZfiq674P6hIDCF
# UHEjtJ3At+fM0YRD+jlYcW6TtHf1H15j2o+RyNMB+ZzDY0pGr9cdzlo8UmCDVJxI
# DQHLFZTRVBppIMiUCzr8SXEX3axQhG1hx2RZcbHWHrEWgvyqj7YBRKuS/jyhPqsx
# X0YLI9XrAkuaqBiA28SOHwwU/q8FPuKL0DuKG1IVkxCvygklvK8VLKmQHi3GBrGW
# tbnogw+qm/KlxpBh8GoJHZPxCzMcanoY+ULHSsoAGGwHqylAFEfVV/TZwkk=
# SIG # End signature block
