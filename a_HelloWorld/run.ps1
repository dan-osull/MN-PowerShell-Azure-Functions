# a_HelloWorld

# Based on Azure Functions PowerShell quickstart:
# https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-function-powershell

# Start local server with:
#   func host start

# Run Function with:
#   Invoke-WebRequest http://localhost:7071/api/a_HelloWorld?name=Minneapolis
#   Invoke-RestMethod http://localhost:7071/api/a_HelloWorld?name=Minneapolis

using namespace System.Net
# Allows e.g. [System.Net.HttpStatusCode] to be shortened to [HttpStatusCode] 

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

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $status
    Body       = $body
})
