#Create a PSSession and connect to an Exchange Virtual Database. #Organization Management group not required. 
#get winrm permissions #Make sure you have permission for remote authentication connections. 
winrm get winrm/config/client/auth

#Create a variable with your administrator credentials
$UserCredential =  Get-Credential -UserName nicholas.spaugh.da -Message "Enter Admin Account Password"

#Create the session
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Lab-EX-01/powershell -Credential $UserCredential -Authentication Kerberos -AllowRedirection
 
#Import the PSSession. May take 5-30 seconds to establish the connection and load the Exchange powershell modules. 
Import-PSSession $Session -DisableNameChecking

#End session before closing PS window
Remove-PSSession $Session
