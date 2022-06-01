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

# GET TICKET/ATTACHMENT

# Get user API credentials
$ApiIntegrationCode = Read-Host "API Key" 
$UserName = Read-Host "Username"
$Secret = Read-Host "Secret"

$headers  = @{
    'ApiIntegrationcode' = $ApiIntegrationCode
    'UserName' = $UserName
    'Secret' = $Secret
    'Content-Type' = 'application/json'
}

# Autotask number of ticket to parse, eg: TYYYYMMDD.XXXX
$ticketNumber = Read-Host "Ticket Number: "

# get ticket id
# ticket id is a unique identifier for each ticket
# different to ticket number
#
# credentials are checked on first api call
# others are not checked, as assumed correct
# incorrect credentials will exit script
Write-Output "Getting Ticket..."
$uri = "https://webservices6.autotask.net/atservicesrest/v1.0/Tickets/query?search={'filter':[{'op':'eq','field':'ticketNumber','value':'$($ticketNumber)'}]}"
try{ 
    $ticketResult = Invoke-RestMethod -uri $uri -Headers $headers 
}
catch { 
    Write-Output "Invalid credentials!"
    exit
}
if($ticketResult.items.Length -eq 0) { 
    Write-Output "No ticket with number '$($ticketNumber)' found!"
    exit 
}
$parentID = $ticketResult.items.id
$ticketTitle = $ticketResult.items.title
$ticketTitle = $ticketTitle.replace(':', '-')
Write-Output "Retrieved ticket '$($ticketTitle)'"

# get ticket attachment id
Write-Output "Getting Ticket Attachment..." 
$uri = "https://webservices6.autotask.net/atservicesrest/v1.0/AttachmentInfo/query?search={'filter':[{'op':'eq','field':'ParentID','value':$($parentID)}]}"
$attachmentResult = Invoke-RestMethod -uri $uri -Headers $headers
$attachmentID = $attachmentResult.items.id

# get attachment data
$uri = "https://webservices6.autotask.net/atservicesrest/v1.0/Tickets/$($parentID)/Attachments/$($attachmentID)"
$attachmentEncoded = Invoke-RestMethod -uri $uri -Headers $headers


# PARSE ATTACHMENT

$attachmentPlaintext = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($attachmentEncoded.items.data)) 
$digestFile = $attachmentPlaintext.Split([Environment]::NewLine)
Write-Output "Parsing..."

$firstLine = 0
$lastLine = 0
$count = 1

$firstLineBuffer = 4
$lastLineBuffer = 6

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
                Reason = ''
                Score = ''
                Recipient = $recipient 
                Sender = $sender
                Subject = $subject
            }
            $email = new-object psobject -Property $props
        }
        elseif ($split.Length -eq 2){
            $reasonString = $split[0].Trim()
            $reasonLength = $reasonString.IndexOf('(') - 1
            if($reasonLength -le 0){ $reasonLength = 0 }
            $reason = $reasonString.Substring(0, $reasonLength)
            $score = $reasonString.Substring($reasonString.IndexOf('(') + 1).replace(') pts', '')
            $email.Reason = $reason
            $email.Score = $score
            $table += $email
        }   
    }
}

# output all items in table
# sorted by lowest score
Write-Output $table | Sort -Property Score | Format-Table -AutoSize
Write-Output $table | Sort -Property Score | Format-Table -AutoSize | Out-File $("$pwd\$ticketTitle.txt") -Width 512
Write-Output "Output to '$($ticketTitle)'.txt"