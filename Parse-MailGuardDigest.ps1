##############################################################################
# Parse MailGuard Digest
#
# Description:
#   Parse MailGuard Quarantine Digest for Easy Reading 
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

$firstLineBuffer = 2
$lastLineBuffer = 3

# get start and end location of b64 block, using nearby markers
$digestFile | foreach {
    if ($firstLine -eq 0 -and $_ -match 'Content-Transfer-Encoding: base64') { 
        $firstLine = $count + $firstLineBuffer
    }
    if ($_ -like 'Content-Type: text/html; charset="UTF-8"') {
        $lastLine = $count - $lastLineBuffer
    }
    ++$count
}

# decode base 64 into plaintext
$encodedText = $digestFile[$firstLine..$lastLine] -join ''
$plaintext = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($encodedtext)) 
$plaintextArray = $plaintext.Split([Environment]::NewLine)

# split and re-combine plaintext items into object
$table = @()
$plaintextArray | foreach {
    $split = $_.Split('|')
    if ($split.Length -gt 1) {
        if ($split.Length -eq 4){
            $sender = $split[0].Trim()
            $recipient = $split[1].Trim()
            $subject = $split[2].Trim()
            $props = [ordered]@{
                Score = ''
                Recipient = $recipient 
                Sender = $sender
                Subject = $subject
            }
            $email = new-object psobject -Property $props
        }
        elseif ($split.Length -eq 2){
            $reason = $split[0].Trim()
            $score = $reason.Substring($reason.IndexOf('(') + 1).replace(') pts', '')
            $email.Score = $score
            $table += $email
        }   
    }
}

# output all items in table
# sorted by lowest score
$dateTime = get-date -Format "dd-MM-yyyy-HH-mm-ss"
Write-Output $table | Sort -Property Score | ft -AutoSize
Write-Output $table | Sort -Property Score | ft -AutoSize | Out-File "$($dateTime).txt"
Write-Output "Output to $($dateTime).txt"