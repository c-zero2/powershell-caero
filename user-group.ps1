# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the path to the CSV file containing email addresses
$csvFilePath = "$env:USERPROFILE\userlist.csv"

# Specify the path for the CSV file to export results
$outputCsvPath = "$env:USERPROFILE\out.csv"

# Initialize an array to store the results
$results = @()

# Import email addresses from CSV
$emailAddresses = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty EmailAddress

# Loop through each email address
foreach ($email in $emailAddresses) {
    # Get groups that the user is a member of
    $userGroups = Get-ADUser -Filter { UserPrincipalName -eq $email } | Get-ADPrincipalGroupMembership | Get-ADGroup

    # Loop through each group and create a new row
    foreach ($group in $userGroups) {
        $resultObject = [PSCustomObject]@{
            Email = $email
            Group = $group.Name
        }

        # Add the result object to the array
        $results += $resultObject
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Script execution completed. Results exported to $outputCsvPath"
