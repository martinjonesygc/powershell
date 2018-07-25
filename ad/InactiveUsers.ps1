<#
  .Description
		Exports inactive users to csv, edit -TimeSpan to desired number of days.
#>

Search-ADAccount -AccountInactive -TimeSpan 90 -UsersOnly | Where-Object { $_.Enabled -eq $true
} | sort-object name | Format-Table Name, lastlogondate, UserPrincipalName > c:\Inactive-AD-Users.txt
