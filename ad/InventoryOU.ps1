Get-ADComputer -Filter * -SearchBase 'OU=Tech,OU=Laptops,DC=Domain,DC=local' | ForEach {

    $cs = Get-WmiObject Win32_ComputerSystem -ComputerName $_.Name

    $bios = Get-WmiObject Win32_BIOS -ComputerName $_.Name

    $props = @{
        'Machine Name' = $cs.Name
        'Manufacturer' = $cs.Manufacturer
        'Model' = $cs.Model
        'Serial Number' = $bios.SerialNumber
    }

    New-Object PsObject -Property $props

} | Export-Csv c:\techlaptops.csv -NoTypeInformation
