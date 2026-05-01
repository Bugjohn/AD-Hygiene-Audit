function Export-ADHygieneCsvReport {
    param(
        [array]$Findings,
        [string]$OutputPath
    )

    function Get-FindingCount {
        param(
            [object]$Value
        )

        if ($null -eq $Value) {
            return $null
        }

        try {
            return [int]$Value
        }
        catch {
            return $null
        }
    }

    function ConvertTo-CsvSafeRow {
        param(
            [object]$InputObject
        )

        $PreferredColumns = @(
            "SamAccountName",
            "Name",
            "Enabled",
            "LastLogonDate",
            "PasswordLastSet",
            "Created",
            "DistinguishedName"
        )

        $Properties = @($InputObject.PSObject.Properties | Where-Object { $_.MemberType -in @("NoteProperty", "Property") })
        $PropertyNames = @($Properties.Name)
        $Ordered = [ordered]@{}

        foreach ($Column in $PreferredColumns) {
            if ($PropertyNames -contains $Column) {
                $Ordered[$Column] = ConvertTo-CsvSafeValue -Value $InputObject.$Column
            }
        }

        foreach ($Property in $Properties) {
            if ($PreferredColumns -notcontains $Property.Name) {
                $Ordered[$Property.Name] = ConvertTo-CsvSafeValue -Value $Property.Value
            }
        }

        [PSCustomObject]$Ordered
    }

    function ConvertTo-CsvSafeValue {
        param(
            [object]$Value
        )

        if ($null -eq $Value) {
            return $null
        }

        if ($Value -is [string] -or $Value.GetType().IsPrimitive -or $Value -is [datetime] -or $Value -is [timespan]) {
            return $Value
        }

        if ($Value -is [System.Collections.IEnumerable]) {
            return (@($Value) | ForEach-Object { [string]$_ }) -join ", "
        }

        return ($Value | ConvertTo-Json -Depth 5 -Compress)
    }

    foreach ($Finding in @($Findings)) {
        $NameSuffix = $Finding.Title -replace "^Membres du groupe\s+", ""
        $InvalidChars = [Regex]::Escape((-join [System.IO.Path]::GetInvalidFileNameChars()))
        $SafeNameSuffix = $NameSuffix -replace "[$InvalidChars]", "" -replace "\s+", "_"
        $SafeNameSuffix = $SafeNameSuffix.Trim("_")

        $FileName = "$($Finding.Id)-$($Finding.Category)-$SafeNameSuffix.csv"
        $CsvPath = Join-Path $OutputPath $FileName

        $Count = Get-FindingCount -Value $Finding.Count
        if ($null -ne $Count -and $Count -le 0) {
            continue
        }

        $Rows = @()

        if ($Finding.Items) {
            $Rows = @($Finding.Items)
        }
        elseif ($Finding.Data) {
            $Rows = @($Finding.Data)
        }

        if ($Rows.Count -gt 0) {
            $Rows |
                ForEach-Object { ConvertTo-CsvSafeRow -InputObject $_ } |
                Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
        }
    }
}
