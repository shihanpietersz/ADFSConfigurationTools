#Get Public and Private function definition files

$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

foreach ($Import in @($Public + $Private))
{

    try{
        . $import.FullName
    }
    Catch{

        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }


}#Foreach
Export-ModuleMember -Function $Public.BaseName 