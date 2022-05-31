##############################################################################
# Parse MailGuard Digest
#
# Description:
#   Parse MailGuard Quarantine Digest for Easy Reading 
#   in provided HTML format
#
#   VERSION 1.0
#
#   AUTHOR
#   Linus Kay
#   Hugh Beavis
#
##############################################################################

Write-Output ''
$inputFile = Read-Host ".eml Digest File"
Write-Output "Reading file..."
$digestFile = Get-Content $inputFile

Write-Output "Parsing..."

$firstLine = 0
$lastLine = 0
$count = 1

$firstLineBuffer = 4
$lastLineBuffer = 2

# get start and end location of b64 block, using nearby markers
$digestFile | foreach {
    if ($firstLine -eq 0 -and $_ -match 'Content-Type: text/html; charset="UTF-8"') { 
        $firstLine = $count + $firstLineBuffer
    }
    ++$count
}
$lastLine = $digestFile.Length - $lastLineBuffer

# decode base 64 into plaintext
$encodedText = $digestFile[$firstLine..$lastLine] -join ''
$plaintext = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($encodedtext)) 

$dateTime = get-date -Format "dd-MM-yyyy-HH-mm-ss"
$plaintext | Out-File "$($dateTime).html"
Write-Output "Output to $($dateTime).html"