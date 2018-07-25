<# Martin Jones 25-06-2018
Export inactive users to csv change timespan to no of days #>
Search-ADAccount -AccountInactive -TimeSpan 90 -UsersOnly | Where-Object { $_.Enabled -eq $true
} | sort-object name | Format-Table Name, lastlogondate, UserPrincipalName > c:\Inactive-AD-Users.txt
