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
