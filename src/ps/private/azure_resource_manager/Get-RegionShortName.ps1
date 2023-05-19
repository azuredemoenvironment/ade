function Get-RegionShortName {
    param(
        [string] $regionName
    )

    $shortName = switch ($regionname) {
        'EastUS' { 'eus'; break }
        'EastUS2' { 'eus2'; break }
        'WestUS' { 'wus'; break }
        'WestUS2' { 'wus2'; break }
        'WestUS3' { 'wus3'; break }
        Default { $regionName }
    }

    return $shortName;
}