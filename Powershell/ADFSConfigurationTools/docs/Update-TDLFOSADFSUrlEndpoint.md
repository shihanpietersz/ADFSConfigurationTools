---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Update-TDLFOSADFSUrlEndpoint

## SYNOPSIS
This commad updates the Primary ADFS server URL endpoint. 

## SYNTAX

```
Update-TDLFOSADFSUrlEndpoint [-PrimaryADFSServer] <String> [-CurrentFederatedDomainURL] <String>
 [-NewFederatedDomainURL] <String> [-FederatedDomains] <String[]> [-NewFederatedDisplayName] <String>
 [-MsolUserName] <String> [-MsolPassword] <String> [-DomainUsername] <String> [-DomainPassword] <String>
 [-CertificateThumbprint] <String> [-LogFilePath] <String> [-MultiDomainSupportEnabled] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Use this command to update the primary ADFS URL endpoint. The command also u SSL certificates as required.
after URL update, The command updates all Microsoft Federated domains with the New URL endpoint. If any webapplication Proxy
servers are present they need to be updated with the Update-TLDFOSWebapplicationProxyURL command
## EXAMPLES

### Example 1
```powershell
PS C:\> Update-TDLFOSADFSUrlEndpoint -PrimaryADFSServer "FOSAUMELSRV004.abio.org.au" -FederatedDomains 'afca.org.au', 'fos.org.au' -CurrentFederatedDomainURL "sso.fos.org.au" -NewFederatedDomainURL "sso.afca.org.au" -NewFederatedDisplayName "AFCA User Signin" -CertificateThumbprint "EA4FB1FABBE3746C85A0CAC94B761C9D84BF7CE1" -MsolUserName "FOSPOCLAB@FOSPOCLAB.onmicrosoft.com" -MsolPassword "MicrosoftOnlineLoginPasword" -DomainUsername "ABIO\Administrator" -DomainPassword 'Pa$$w0rd' -LogFilePath "C:\Scripts\ADFSLogs" -MultiDomainSupportEnabled  -Verbose
```

The above command updates the ADFS URL endpoint from fos.org.au to AFCA.org.au on the primary ADFS server FOSAUMELSRV004. It then updates the federated domains afca.org.au and fos.org.au. all log files will be written in C:\scripts\ADFSLogs\Logfilename

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
{{current federated DomainURL}

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
If ADFS server is behind a Microsoft Web Application Proxy Server. The Update-TLDFOSWebapplicationProxyURL commad can be run with the required paramaneters. In some occations it can take 
between 10 - 20 Minus for the webapplicationproxy server to updated the changes.

This command was created by Shihan Pietersz from Thomas Duryea Logicalis  for FOS.

## RELATED LINKS