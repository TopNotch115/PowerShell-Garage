#Manage a server/computer that is not on the same domain as your management computer. 
 #Example senario is a home lab with Hyper-V. Managing VMs from your personal computer(One that you do not plan on adding to your Lab Domain)
#On Hyper-V VM:
Enable-PSRemoting
Enable-WSManCredSSP -Role server

#View current trusted hosts on your computer that is not apart of a domain. 
Get-Item WSMan:\localhost\Client\TrustedHosts
#The TrustedHosts list only saves the last set value. This is because the TrustedHosts list is updated using the Set-Item command that you have executed by overwriting the previous entries. if you want to add an additional computer, without deleting the previous entries, you must use the following method.

#Use this command on both ends of machines.(Ie. Hyper-V VM and local computer running Hyper-V)
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "ComputerName.localhost" 
#If you have multiple computers/devices use * as a wildcard for any device.
Set-Item WSMan:\localhost\Client\TrustedHosts -Value *
