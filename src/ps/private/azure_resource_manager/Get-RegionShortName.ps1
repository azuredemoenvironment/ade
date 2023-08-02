#cSpell:disable
function Get-RegionShortName {
    param(
        [string] $regionName
    )

    $shortName = switch ($regionName) {
        'asia' { 'as'; break }
        'asiapacific' { 'apac'; break }
        'australia' { 'au'; break }
        'australiacentral' { 'auc'; break }
        'australiacentral2' { 'auc2'; break }
        'australiaeast' { 'aue'; break }
        'australiasoutheast' { 'ause'; break }
        'brazil' { 'br'; break }
        'brazilsouth' { 'brs'; break }
        'brazilsoutheast' { 'brse'; break }
        'canada' { 'ca'; break }
        'canadacentral' { 'cac'; break }
        'canadaeast' { 'cae'; break }
        'centralindia' { 'cin'; break }
        'centralus' { 'cus'; break }
        'centraluseuap' { 'cusea'; break }
        'centralusstage' { 'cusstg'; break }
        'eastasia' { 'ea'; break }
        'eastasiastage' { 'eastg'; break }
        'eastus' { 'eus'; break }
        'eastus2' { 'eus2'; break }
        'eastus2euap' { 'eus2e'; break }
        'eastus2stage' { 'eus2stg'; break }
        'eastusstage' { 'eusstg'; break }
        'eastusstg' { 'eusstg0'; break }
        'europe' { 'eu'; break }
        'france' { 'fr'; break }
        'francecentral' { 'frc'; break }
        'francesouth' { 'frs'; break }
        'germany' { 'de'; break }
        'germanynorth' { 'den'; break }
        'germanywestcentral' { 'dewc'; break }
        'global' { 'glbl'; break }
        'india' { 'in'; break }
        'japan' { 'jp'; break }
        'japaneast' { 'jpe'; break }
        'japanwest' { 'jpw'; break }
        'jioindiacentral' { 'jioinc'; break }
        'jioindiawest' { 'jioinw'; break }
        'korea' { 'kr'; break }
        'koreacentral' { 'krc'; break }
        'koreasouth' { 'krs'; break }
        'northcentralus' { 'ncus'; break }
        'northcentralusstage' { 'ncusstg'; break }
        'northeurope' { 'neu'; break }
        'norway' { 'no'; break }
        'norwayeast' { 'noe'; break }
        'norwaywest' { 'now'; break }
        'qatarcentral' { 'qac'; break }
        'singapore' { 'sg'; break }
        'southafrica' { 'za'; break }
        'southafricanorth' { 'san'; break }
        'southafricawest' { 'zaw'; break }
        'southcentralus' { 'scus'; break }
        'southcentralusstage' { 'scusstg'; break }
        'southcentralusstg' { 'scusstg0'; break }
        'southeastasia' { 'sea'; break }
        'southeastasiastage' { 'seastg'; break }
        'southindia' { 'sin'; break }
        'swedencentral' { 'senc'; break }
        'switzerland' { 'ch'; break }
        'switzerlandnorth' { 'chn'; break }
        'switzerlandwest' { 'chw'; break }
        'uae' { 'ae'; break }
        'uaecentral' { 'aec'; break }
        'uaenorth' { 'aen'; break }
        'uk' { 'uk'; break }
        'uksouth' { 'uks'; break }
        'ukwest' { 'ukw'; break }
        'unitedstates' { 'us'; break }
        'unitedstateseuap' { 'usea'; break }
        'westcentralus' { 'wcus'; break }
        'westeurope' { 'weu'; break }
        'westindia' { 'win'; break }
        'westus' { 'wus'; break }
        'westus2' { 'wus2'; break }
        'westus2stage' { 'wus2stg'; break }
        'westus3' { 'wus3'; break }
        'westusstage' { 'wusstg'; break }
        Default { $regionName }
    }

    return $shortName;
}