# e_FileSystemBrowser

# Script runs Get-ChildItem on a path and displays a HTML table.
# It defaults to a root of "D:\"
# It adds links to folders. The links call this script with the folder as root.

# To start:
# https://dan-function.azurewebsites.net/api/e_FileSystemBrowser?code=aLh1w7m6HPw4OJ6jHtHe0nc/JjrfdgauDEgRFwuLKLAkGWrqe805FA==

#region Setup and variables
using namespace System.Net

param($Request, $TriggerMetadata)

if ($null -eq $Request.Query.Root) {
    # Root defaults to D:\ if not provided
    [string]$root = 'D:\'
} else {
    # Custom Root has been provided
    [string]$root = $Request.Query.Root
}

# Function URL is hardcoded in script
# What's the proper way of doing this? Use an Application Setting?
if ($env:AZURE_FUNCTIONS_ENVIRONMENT -eq 'Development') {
    $functionURL = 'http://localhost:7071/api/e_FileSystemBrowser?'
}
else {
    $functionURL = 'https://dan-function.azurewebsites.net/api/e_FileSystemBrowser?code=aLh1w7m6HPw4OJ6jHtHe0nc/JjrfdgauDEgRFwuLKLAkGWrqe805FA==&'
}
#endregion

#region Functions
Function Add-LinkToChildItem {
    param($item)
        # Constuct link HTML
        $linkHtml  = '<a href="'
        $linkHtml += $functionURL
        $linkHtml += 'Root='
        $linkHtml += $item.FullName # Path of folder
        $linkHtml += '">' # End of <a
        $linkHtml += 'Open'
        $linkHtml += '</a>'

        # Add link HTML as new Property
        $params = @{
            MemberType = 'NoteProperty'
            Name       = 'LinkToFolder'
            Value      = $linkHtml
        }
        $item | Add-Member @params
}
#endregion

#region Script actions
$childItems = Get-ChildItem -Path $root

# Loop through items
ForEach ($item in $childItems) {
    if ($item.GetType().Name -eq 'DirectoryInfo') {
        # Item is a Directory
        Add-LinkToChildItem $item
    }
}

# Select our favourite properties
$childItems = $childItems | 
    Select-Object -Property LinkToFolder,Name,Extension,CreationTime,Length

# Convert to HTML
$body = $childItems | 
    ConvertTo-Html | 
    Out-String # So we don't get an array
# Make text output dangerous again
$body = $body.Replace('&lt;','<').Replace('&quot;','"').Replace('&gt;','>')

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = [HttpStatusCode]::OK # This has no connection to reality
    ContentType = "text/html"
    Body        = $body
})
#endregion