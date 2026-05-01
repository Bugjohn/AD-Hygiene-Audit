function Export-ADHygieneCsvReport {
    param(
        [array]$Findings,
        [string]$OutputPath
    )

    foreach ($Finding in $Findings) {
        $NameSuffix = $Finding.Title -replace "^Membres du groupe\s+", ""
        $InvalidChars = [Regex]::Escape((-join [System.IO.Path]::GetInvalidFileNameChars()))
        $SafeNameSuffix = $NameSuffix -replace "[$InvalidChars]", "" -replace "\s+", "_"
        $SafeNameSuffix = $SafeNameSuffix.Trim("_")

        $FileName = "$($Finding.Id)-$($Finding.Category)-$SafeNameSuffix.csv"
        $CsvPath = Join-Path $OutputPath $FileName

        if ($Finding.Items -and $Finding.Count -gt 0) {
            $Finding.Items |
                Select-Object `
                    SamAccountName,
                    Name,
                    Enabled,
                    LastLogonDate,
                    PasswordLastSet,
                    Created,
                    DistinguishedName |
                Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
        }
    }
}
