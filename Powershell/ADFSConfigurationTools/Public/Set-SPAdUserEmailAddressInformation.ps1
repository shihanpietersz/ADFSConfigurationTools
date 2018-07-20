
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
