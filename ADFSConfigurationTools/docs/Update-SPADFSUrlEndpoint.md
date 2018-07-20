---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Update-SPADFSUrlEndpoint

## SYNOPSIS
This commad updates the Primary ADFS server URL endpoint. 

## SYNTAX

```
Update-SPADFSUrlEndpoint [-PrimaryADFSServer] <String> [-CurrentFederatedDomainURL] <String>
 [-NewFederatedDomainURL] <String> [-FederatedDomains] <String[]> [-NewFederatedDisplayName] <String>
 [-MsolUserName] <String> [-MsolPassword] <String> [-DomainUsername] <String> [-DomainPassword] <String>
 [-CertificateThumbprint] <String> [-LogFilePath] <String> [-MultiDomainSupportEnabled] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Use this command to update the primary ADFS URL endpoint. The command Service Communication certificates and Token Signing and Decrypting certificates as required.

Post URL update, The command updates all Microsoft Federated domains with the New URL endpoint. If any webapplication Proxy servers are present they need to be updated with the Update-SPWebapplicationProxyURL command
## EXAMPLES

### Example 1
```powershell
PS C:\> Update-SPADFSUrlEndpoint -PrimaryADFSServer "ADFS01.adfslocal" -FederatedDomains 'adfs.com.au', 'adfstools.com.au' -CurrentFederatedDomainURL "sso.adfs.com.au" -NewFederatedDomainURL "sso.adfstools.com.au" -NewFederatedDisplayName "Created with Powershell" -CertificateThumbprint "EA4FB1EWBBE3746C85AAWAC94B761C9D2ABF7C22" -MsolUserName "MSGlobalADmin@adfstools.onmicrosoft.com" -MsolPassword "MicrosoftOnlineLoginPasword" -DomainUsername "ADFS\Administrator" -DomainPassword 'Pa$$w0rd' -LogFilePath "C:\Scripts\ADFSLogs" -MultiDomainSupportEnabled  -Verbose
```

The above command updates the ADFS URL endpoint from sso.adfs.com.au to sso.adfstools.com.au on the primary ADFS serverADFS01.adfslocal. It then updates the federated domains adfs.com.au and adfstools.com.au. all log files written in C:\scripts\ADFSLogs\Logfilename

## PARAMETERS

### -CertificateThumbprint
New Federated domain certificate thrmbprint

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 9
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -CurrentFederatedDomainURL
current federated DomainURL

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DomainPassword
Active Direcotory Domain password with administrative rights

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 8
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DomainUsername
Active Direcotory Domain Username with administrative rights

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 7
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FederatedDomains
All Federated Domains, Including current

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LogFilePath
Log file path, Needs to be a folder

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 10
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MsolPassword
Microsoft onlineServices Password. Needs to be a global Administrator

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MsolUserName
Microsoft onlineServices Username. Needs to be a global Administrator

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MultiDomainSupportEnabled
If current environment has more than one Federated Domain. The -MultiDomainSupportEnabled Switch needs to used for all federated domains to be updated

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NewFederatedDisplayName
New Display name for Microsoft Online Services Sign In Page

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NewFederatedDomainURL
New Federated domain URL

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PrimaryADFSServer
Primary ADFS server.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
System.String[]
System.Management.Automation.SwitchParameter


## OUTPUTS

### System.Object

## NOTES
All Current configuration will be logged in the LogFilePath for reference
If ADFS server is behind a Microsoft Web Application Proxy Server. The Update-SPWebapplicationProxyURL command can be run with the required parameters. 

## RELATED LINKS