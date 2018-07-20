Function New-MsolSecurePassword{

    [cmdletbinding()]
    param(
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$KeyFile,
    [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$PlainTextPassword,
    [parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$UserName,
    [parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [String]$PasswordFile,
    [parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [ValidateSet("16","24","32")] 
    [String]$Byte
    )

    PROCESS{


        #Create Cryptography Key
        $Key = New-Object Byte[] 16
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
        $key | Out-File $KeyFile

        $Key = Get-Content $KeyFile
        $Password = "$PlainTextPassword" | ConvertTo-SecureString -AsPlainText -Force
        $Password | ConvertFrom-SecureString -key $Key | Out-File $PasswordFile

        $properties = [Ordered]@{
                        "PasswordFile" = $PasswordFile
                        "KeyFile" = $KeyFile
                        "SecurePassword" = (Get-Content $PasswordFile)
                        "Key" = $Key
                    }
        $Object = New-Object -TypeName Psobject -Property $properties
        



        $username = $UserName
        $AESKey = Get-Content "$($KeyFile)"
        $pwdTxt =  Get-Content "$($PasswordFile)"
        $securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey
        $credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
        Return $credObject      

    }

}#Function 



