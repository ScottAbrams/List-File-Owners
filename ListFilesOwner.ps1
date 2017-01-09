# List all files in the folder and sub folders.  Pipe to a csv file with columns of Directory, Name, Length, Owner, Created and LastWrite
# Usage .\ListFilesOwner.ps1 -folder Folder -skip FolderToSkip  Example .\ListFilesOwner.ps1 -folder G:\Common -skip MarketPub
# Scott Abrams December 22 2016
#    

# set parameters and set skip value to Null
Param ([string]$folder="",[string]$skip="NULL")

# set array and make it empty
$arr = @()

Get-Childitem $folder -recurse | Where-Object{ $_.fullname -notmatch "\\$skip\\?" } | Where-Object {$_.PSIsContainer -eq $False} | ForEach-Object {
  $obj = New-Object PSObject
  $obj | Add-Member NoteProperty Directory $_.DirectoryName 
  $obj | Add-Member NoteProperty Name $_.Name
  $obj | Add-Member NoteProperty Length $_.Length
  $obj | Add-Member NoteProperty Owner ((Get-ACL $_.FullName).Owner)
  $obj | Add-Member NoteProperty Created $_.CreationTime
  $obj | Add-Member NoteProperty LastWrite $_.LastWriteTime
  $arr += $obj
  $count = $count+1
  Write-Host $count " " + $_.Directory
  } 

 # Export to CSV file
  $arr | Export-CSV -notypeinformation "c:\administration\scripts\log\ListOwnerReport.csv"

  # Rename output file with date added

$filename = "c:\administration\scripts\log\ListOwnerReport.csv"

# Check the file exists
if (-not(Test-Path $fileName)) {break}

# Display the original name
"Original filename: $fileName"

$fileObj = get-item $fileName

# Get the date
$DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"

$extOnly = $fileObj.extension

if ($extOnly.length -eq 0) {
   $nameOnly = $fileObj.Name
   rename-item "$fileObj" "$nameOnly-$DateStamp"
   }
else {
   $nameOnly = $fileObj.Name.Replace( $fileObj.Extension,'')
   rename-item "$fileName" "$nameOnly-$DateStamp$extOnly"
   }

# Display the new name
"New filename: $nameOnly-$DateStamp$extOnly"