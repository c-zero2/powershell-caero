# Ignore SSL Warning
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Specify the path to the CSV file with the URIs
$csvPath = 'E:\Expires_cert\Expires-date.csv'

# Specify the output CSV file path
$outputCsvPath = 'E:\Expires_cert\Output_Expires.csv'

# Read the CSV file
$uris = Import-Csv $csvPath

# Create an array to store output information
$outputArray = @()

foreach ($uriInfo in $uris) {
    $uri = $uriInfo.URI

    # Create Web Http request to URI
    $webRequest = [Net.HttpWebRequest]::Create($uri)

    try {
        # Retrieve the Information for URI
        $webRequest.GetResponse() | Out-NULL

        # Get SSL Certificate and its details
        $certificate = $webRequest.ServicePoint.Certificate

        # Get SSL Certificate Expiration Date in the desired format
        $expirationDate = $certificate.GetExpirationDateString()
        $formattedExpirationDate = Get-Date $expirationDate -Format 'dd/MM/yy HH:mm'

        # Create an object with URI and formatted certificate expiration date
        $outputObject = [PSCustomObject]@{
            URI               = $uri
            ExpirationDate    = $formattedExpirationDate
        }

        # Add the object to the array
        $outputArray += $outputObject
    } catch {
        Write-Host "Error checking URI: $uri"
        Write-Host "Error details: $_"
    }
}

# Export the output information to a new CSV file
$outputArray | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Output information exported to: $outputCsvPath"
