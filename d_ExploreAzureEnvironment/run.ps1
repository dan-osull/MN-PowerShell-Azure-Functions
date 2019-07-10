# d_ExploreAzureEnvironment

# Script to explore the Azure Functions PowerShell environment
# by running commands from a menu and returning their output
# as a string.

using namespace System.Net

param($Request, $TriggerMetadata)

$itemToRun = $Request.Query.Run

$runResult = switch ($itemToRun) {
    0 { Get-ChildItem env: }
    1 { $PSVersionTable }
    2 { Get-Variable }
    3 { Get-Process }
}
if ($runResult) {
    $status = [HttpStatusCode]::OK
    $body   = $runResult | Out-String
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body   = 'Supply a parameter of Run with a value between 0 and 3'
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body       = $body
})
