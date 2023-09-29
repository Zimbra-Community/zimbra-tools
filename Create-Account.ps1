# Define the URL for the SOAP endpoint
$zimbraServerUrl = "https://ZimbraServer:7071/service/admin/soap/"

#Define admin Creds
$adminUsername = Read-Host "Enter your admin email account"
$securePassword = (Read-Host "Enter your admin Password" -AsSecureString)
$adminPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

# Define the SOAP envelope for the first step of authentication
$authRequestStep1 = @"
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <context xmlns="urn:zimbra"/>
  </soap:Header>
  <soap:Body>
    <AuthRequest xmlns="urn:zimbraAdmin">
      <account by="adminName">$adminUsername</account>
      <password>$adminPassword</password>
    </AuthRequest>
  </soap:Body>
</soap:Envelope>
"@

# Send the first step of the authentication request
$authResponseStep1 = Invoke-RestMethod -Uri $zimbraServerUrl -Method Post -Body $authRequestStep1 -ContentType "application/soap+xml"

# Extract the temporary auth token from the response
$tempAuthToken = $authResponseStep1.Envelope.Body.AuthResponse.authToken

# Define your two-factor authentication code
$twoFactorCode = Read-Host "Please enter 2FA code"

# Define the SOAP envelope for the second step of authentication
$authRequestStep2 = @"
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <context xmlns="urn:zimbra">
      <authToken>$tempAuthToken</authToken>
    </context>
  </soap:Header>
  <soap:Body>
    <AuthRequest xmlns="urn:zimbraAdmin">
      <twoFactorCode>$twoFactorCode</twoFactorCode>
    </AuthRequest>
  </soap:Body>
</soap:Envelope>
"@

# Send the second step of the authentication request
$authResponseStep2 = Invoke-RestMethod -Uri $zimbraServerUrl -Method Post -Body $authRequestStep2 -ContentType "application/soap+xml"

# Extract the final auth token from the response
$authToken = $authResponseStep2.Envelope.Body.AuthResponse.authToken

# Define the SOAP request body
$createAccountRequest = @"
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Header>
    <context xmlns="urn:zimbra">
      <authToken>$authToken</authToken>
    </context>
  </soap:Header>
  <soap:Body>
    <CreateAccountRequest xmlns="urn:zimbraAdmin">
      <name>$email</name>
	  <a n="displayName">$fullname</a>
	  <a n="givenName">$firstname</a>
	  <a n="sn">$surname</a>
	  <a n="description">$jobtitle</a>
	  <a n="zimbraNotes">$group</a>
    </CreateAccountRequest>
  </soap:Body>
</soap:Envelope>
"@

# Send the HTTP request
$createAccountResponse = Invoke-RestMethod -Uri $zimbraServerUrl -Method Post -Body $createAccountRequest -Headers $headers

# Output the response
$createAccountResponse

# Clear Admin password variable
Remove-Variable -Name "adminPassword"