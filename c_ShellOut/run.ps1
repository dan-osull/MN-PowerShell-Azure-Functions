# c_ShellOut

# Script that runs powershell.exe, grabs its $PSVersionTable
# and shoves it down the pipe.

# Oneliner:
#   irm https://dan-function.azurewebsites.net/api/c_ShellOut?code=qCyxnco69Vu8khTnAqD2OCS%2FUW9rUikH52TH1cWqDauj3OrH0qB6uQ%3D%3D | Out-File temp.xml; Import-Clixml temp.xml; Remove-Item temp.xml

using namespace System.Net

param($Request, $TriggerMetadata)

# Run PS5, get $PSVersionTable, export to XML file
& powershell.exe -Command {
    $PSVersionTable | Export-Clixml 'd:/local/Temp/psVersionTable.xml'
}

# Read XML back in and delete temp file
# ReadCount 0 reads the entire file in a single read operation
# Without this I was getting 1 object for each line
$response = Get-Content -Path 'd:/local/Temp/psVersionTable.xml' -ReadCount 0

Remove-Item $xmlTempPath

$status = [HttpStatusCode]::OK

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body       = $response
})
