# -------- PARAMETERS --------
$resourceGroup = "rg-jv-upgrade2025"
$location = "WestEurope"
$zone = "" 
$diskName = "WindowsServer2025UpgradeDisk"

# Target version: server2025Upgrade, server2022Upgrade, server2019Upgrade, server2016Upgrade or server2012Upgrade
$sku = "server2025Upgrade"

#--------END PARAMETERS --------
$publisher = "MicrosoftWindowsServer"
$offer = "WindowsServerUpgrade"
$managedDiskSKU = "Standard_LRS"

$versions = Get-AzVMImage -PublisherName $publisher -Location $location -Offer $offer -Skus $sku | sort-object -Descending {[version] $_.Version	}
$latestString = $versions[0].Version

$image = Get-AzVMImage -Location $location `
                       -PublisherName $publisher `
                       -Offer $offer `
                       -Skus $sku `
                       -Version $latestString

if (-not (Get-AzResourceGroup -Name $resourceGroup -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroup -Location $location    
}

if ($zone){
    $diskConfig = New-AzDiskConfig -SkuName $managedDiskSKU `
                                   -CreateOption FromImage `
                                   -Zone $zone `
                                   -Location $location
} else {
    $diskConfig = New-AzDiskConfig -SkuName $managedDiskSKU `
                                   -CreateOption FromImage `
                                   -Location $location
} 

Set-AzDiskImageReference -Disk $diskConfig -Id $image.Id -Lun 0

New-AzDisk -ResourceGroupName $resourceGroup `
           -DiskName $diskName `
           -Disk $diskConfig
