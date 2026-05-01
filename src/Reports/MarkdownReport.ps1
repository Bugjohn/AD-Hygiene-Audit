function Export-ADHygieneMarkdownReport {
    param(
        [array]$Findings,
        [object]$ScoreSummary,
        [string]$OutputPath
    )

    function ConvertTo-MarkdownValue {
        param(
            [object]$Value
        )

        if ($null -eq $Value) {
            return ""
        }

        if ($Value -is [string]) {
            return ($Value -replace "\|", "\|" -replace "(`r`n|`n|`r)", "<br>")
        }

        if ($Value.GetType().IsPrimitive -or $Value -is [datetime] -or $Value -is [timespan]) {
            return ([string]$Value -replace "\|", "\|")
        }

        if ($Value -is [System.Collections.IEnumerable]) {
            return ((@($Value) | ForEach-Object { ConvertTo-MarkdownValue -Value $_ }) -join ", ")
        }

        return (($Value | ConvertTo-Json -Depth 5 -Compress) -replace "\|", "\|")
    }

    function Get-ObjectProperties {
        param(
            [object]$InputObject
        )

        if ($null -eq $InputObject) {
            return @()
        }

        return @($InputObject.PSObject.Properties | Where-Object {
            $_.MemberType -in @("NoteProperty", "Property")
        })
    }

    function Add-MarkdownTable {
        param(
            [System.Text.StringBuilder]$Builder,
            [array]$Rows
        )

        $Rows = @($Rows | Where-Object { $null -ne $_ })

        if ($Rows.Count -eq 0) {
            return
        }

        $Columns = @(
            $Rows |
                ForEach-Object { Get-ObjectProperties -InputObject $_ } |
                Select-Object -ExpandProperty Name -Unique
        )

        if ($Columns.Count -eq 0) {
            foreach ($Row in $Rows) {
                [void]$Builder.AppendLine("- $(ConvertTo-MarkdownValue -Value $Row)")
            }
            [void]$Builder.AppendLine("")
            return
        }

        [void]$Builder.AppendLine("| $($Columns -join ' | ') |")
        [void]$Builder.AppendLine("| $(($Columns | ForEach-Object { '---' }) -join ' | ') |")

        foreach ($Row in $Rows) {
            $Values = foreach ($Column in $Columns) {
                ConvertTo-MarkdownValue -Value $Row.$Column
            }

            [void]$Builder.AppendLine("| $($Values -join ' | ') |")
        }

        [void]$Builder.AppendLine("")
    }

    function Add-FindingSection {
        param(
            [System.Text.StringBuilder]$Builder,
            [object]$Finding
        )

        $Title = if ($Finding.Title) { $Finding.Title } else { "Finding" }
        [void]$Builder.AppendLine("## $($Finding.Id) - $Title")
        [void]$Builder.AppendLine("")
        [void]$Builder.AppendLine("- Category: $($Finding.Category)")
        [void]$Builder.AppendLine("- Severity: $($Finding.Severity)")

        if ($Finding.PSObject.Properties["Status"]) {
            [void]$Builder.AppendLine("- Status: $($Finding.Status)")
        }

        if ($Finding.PSObject.Properties["Count"]) {
            [void]$Builder.AppendLine("- Count: $($Finding.Count)")
        }

        if ($Finding.Description) {
            [void]$Builder.AppendLine("- Description: $(ConvertTo-MarkdownValue -Value $Finding.Description)")
        }

        if ($Finding.Risk) {
            [void]$Builder.AppendLine("- Risk: $(ConvertTo-MarkdownValue -Value $Finding.Risk)")
        }

        if ($Finding.Recommendation) {
            [void]$Builder.AppendLine("- Recommendation: $(ConvertTo-MarkdownValue -Value $Finding.Recommendation)")
        }
        elseif ($Finding.Recommendations) {
            [void]$Builder.AppendLine("- Recommendations: $(ConvertTo-MarkdownValue -Value $Finding.Recommendations)")
        }

        [void]$Builder.AppendLine("")

        if ($Finding.Items) {
            [void]$Builder.AppendLine("### Items")
            [void]$Builder.AppendLine("")
            Add-MarkdownTable -Builder $Builder -Rows @($Finding.Items)
        }
        elseif ($Finding.Data) {
            [void]$Builder.AppendLine("### Data")
            [void]$Builder.AppendLine("")
            Add-MarkdownTable -Builder $Builder -Rows @($Finding.Data)
        }
    }

    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }

    $ReportPath = Join-Path $OutputPath "ad-hygiene-report.md"
    $Builder = [System.Text.StringBuilder]::new()
    $GeneratedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    [void]$Builder.AppendLine("# AD-Hygiene-Audit Report")
    [void]$Builder.AppendLine("")
    [void]$Builder.AppendLine("- Generated at: $GeneratedAt")
    [void]$Builder.AppendLine("- Score: $($ScoreSummary.Score)/100")
    [void]$Builder.AppendLine("")

    [void]$Builder.AppendLine("## Severity Summary")
    [void]$Builder.AppendLine("")
    [void]$Builder.AppendLine("| Severity | Findings |")
    [void]$Builder.AppendLine("| --- | ---: |")
    [void]$Builder.AppendLine("| Critical | $($ScoreSummary.Critical) |")
    [void]$Builder.AppendLine("| High | $($ScoreSummary.High) |")
    [void]$Builder.AppendLine("| Medium | $($ScoreSummary.Medium) |")
    [void]$Builder.AppendLine("| Low | $($ScoreSummary.Low) |")
    [void]$Builder.AppendLine("| Info | $($ScoreSummary.Info) |")
    [void]$Builder.AppendLine("")

    [void]$Builder.AppendLine("## Findings")
    [void]$Builder.AppendLine("")

    foreach ($Finding in @($Findings)) {
        Add-FindingSection -Builder $Builder -Finding $Finding
    }

    $Builder.ToString() | Out-File -FilePath $ReportPath -Encoding UTF8
}
