---
external help file:
Module Name:
online version:
schema: 2.0.0
---

# Enable-TDLFOSADFSMultiDomainSupport

## SYNOPSIS
Enables MultiDomain Support for current and new federated domains

## SYNTAX

```
Enable-TDLFOSADFSMultiDomainSupport [-PrimaryADFSServer] <String> [-MsolUserName] <String>
 [-MsolPassword] <String> [-NewDomainToFederate] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This command enables multidomain supports for existing and new federated domains

## EXAMPLES

### Example 1
```powershell
PS C:\> Enable-TDLFOSADFSMultidomainSupport -PrimaryADFSServer "FOSAUMELSRV004.abio.org.au" -MsolUserName "FOSPOCLAB@FOSPOCLAB.onmicrosoft.com" -MsolPassword "Pa$`$w0rd" -NewDomainToFederate "afca.org.au" -Verbose
```

the above example enables a new federation for the domain afca.org.au and enables multidomain support for existing domains

## PARAMETERS

### -MsolPassword
Microsoft Online services password

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MsolUserName
Microsoft online services username

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NewDomainToFederate
New Domain name to federate and enable multidomain support

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -PrimaryADFSServer
Primary ADFS server in domain

```yaml
Type: String
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
Type: SwitchParameter
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
Type: SwitchParameter
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


## OUTPUTS

### System.Object

## NOTES


## RELATED LINKS
