# b_LocalDebug

# See blog post:
# https://blog.osull.com/2019/06/03/demo-debug-powershell-azure-functions-locally/

# Run Function with:
#   irm http://localhost:7071/api/b_LocalDebug?name=Minneapolis

# Enter debug:
#   Get-PSHostProcessInfo
#   Get-PSHostProcessInfo | Where-Object {$_.ProcessName -eq 'dotnet'} | Enter-PSHostProcess
#   Get-Runspace
#   Debug-Runspace -id (Get-RunspaceDebug | Where-Object {$_.Enabled -eq 1}).RunspaceId

# Explore input param:
#   $Request
#   $TriggerMetaData

# Environment
#   dir env:

# Script variables:
#   $name
#   $body
#   $status

# When finished:
#   continue

# It's also possible to debug in VS Code:
# https://docs.microsoft.com/en-us/azure/azure-functions/functions-debug-powershell-local#debug-in-visual-studio-code

using namespace System.Net
# So e.g. [System.Net.HttpStatusCode] can be shortened to [HttpStatusCode] 

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Information 'PowerShell HTTP trigger function processed a request.'

# Interact with query parameters or the body of the request.
$name = $Request.Query.Name
if (-not $name) {
    $name = $Request.Body.Name
}

if ($name) {
    $status = [HttpStatusCode]::OK
    # Create a hashtable and convert to JSON
    $body = @{
        greeting = "Hello $name"
    } | ConvertTo-Json
}
else {
    $status = [HttpStatusCode]::BadRequest
    $body   = 'Please pass a name on the query string or in the request body.'
}

Write-Information 'Write $body to log stream'
$body

if ($env:AZURE_FUNCTIONS_ENVIRONMENT -eq 'Development') {
    Wait-Debugger
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body       = $body
})
