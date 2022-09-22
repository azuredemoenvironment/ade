function Get-RegionShortName {
    param(
        [string] $regionName
    )

    $shortName = switch ($regionname) {
        'eastus' {'eus'; break }
        'eastus2' {'eus2'; break }
        'southcentralus' {'scus'; break }
        'westus2' {'wus2'; break }
        'westus3' {'wus3'; break }
        'australiaeast' {'aue'; break }
        'southeastasia' {'sea'; break }
        'northeurope' {'neu'; break }
        'swedencentral' {'senc'; break }
        'uksouth' {'uks'; break }
        'westeurope' {'weu'; break }
        'centralus' {'cus'; break }
        'southafricanorth' {'san'; break }
        'centralindia' {'cin'; break }
        'eastasia' {'ea'; break }
        'japaneast' {'jpe'; break }
        'koreacentral' {'krc'; break }
        'canadacentral' {'cac'; break }
        'francecentral' {'frc'; break }
        'germanywestcentral' {'dewc'; break }
        'norwayeast' {'noe'; break }
        'switzerlandnorth' {'chn'; break }
        'uaenorth' {'aen'; break }
        'brazilsouth' {'brs'; break }
        'eastus2euap' {'eus2e'; break }
        'qatarcentral' {'qac'; break }
        'centralusstage' {'cusstg'; break }
        'eastusstage' {'eusstg'; break }
        'eastus2stage' {'eus2stg'; break }
        'northcentralusstage' {'ncusstg'; break }
        'southcentralusstage' {'scusstg'; break }
        'westusstage' {'wusstg'; break }
        'westus2stage' {'wus2stg'; break }
        'asia' {'a'; break }
        'asiapacific' {'apac'; break }
        'australia' {'au'; break }
        'brazil' {'br'; break }
        'canada' {'ca'; break }
        'europe' {'eu'; break }
        'france' {'fr'; break }
        'germany' {'de'; break }
        'global' {'glbl'; break }
        'india' {'in'; break }
        'japan' {'jp'; break }
        'korea' {'kr'; break }
        'norway' {'no'; break }
        'singapore' {'sg'; break }
        'southafrica' {'za'; break }
        'switzerland' {'ch'; break }
        'uae' {'ae'; break }
        'uk' {'uk'; break }
        'unitedstates' {'us'; break }
        'unitedstateseuap' {'useuap'; break }
        'eastasiastage' {'eastg'; break }
        'southeastasiastage' {'seastg'; break }
        'eastusstg' {'eusstg0'; break }
        'southcentralusstg' {'scusstg0'; break }
        'northcentralus' {'ncus'; break }
        'westus' {'wus'; break }
        'jioindiawest' {'jioinw'; break }
        'centraluseuap' {'cuseuap'; break }
        'westcentralus' {'wcus'; break }
        'southafricawest' {'zaw'; break }
        'australiacentral' {'auc'; break }
        'australiacentral2' {'auc2'; break }
        'australiasoutheast' {'ause'; break }
        'japanwest' {'jpw'; break }
        'jioindiacentral' {'jioinc'; break }
        'koreasouth' {'krs'; break }
        'southindia' {'sin'; break }
        'westindia' {'win'; break }
        'canadaeast' {'cae'; break }
        'francesouth' {'frs'; break }
        'germanynorth' {'den'; break }
        'norwaywest' {'now'; break }
        'switzerlandwest' {'chw'; break }
        'ukwest' {'ukw'; break }
        'uaecentral' {'aec'; break }
        'brazilsoutheast' {'brse'; break }
        Default { $regionName }
    }

    return $shortName;
}