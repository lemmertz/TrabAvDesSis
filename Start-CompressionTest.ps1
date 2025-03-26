#region EnvSetup

# Github sample file URL
$FileUrl = "https://raw.githubusercontent.com/lemmertz/TrabAvDesSis/refs/heads/main/20mb-examplefile-com.txt"

# Temporary out file for testing
$TestFile = "$env:TEMP\20mb_test_file.txt"

# Downloads file for compression test
Invoke-WebRequest -Uri $FileUrl -UseBasicParsing -OutFile $TestFile

#endregion

#region HwDataCollection

# Query processor information
$procInfo = Get-WmiObject -Class Win32_processor | Select-Object Name, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors

# Query memory information
$memInfo = Get-CIMInstance Win32_OperatingSystem | Select-Object -Property @{Name="FreePhysicalMemoryGB";Expression={[math]::round($PSItem.FreePhysicalMemory / 1MB, 2)}}, @{Name="TotalVisibleMemorySizeGB";Expression={[math]::round($PSItem.TotalVisibleMemorySize / 1MB, 2)}}

#endregion

#region CompressionTest

# 100 runs of compressing the file
$compress = for($i=0;$i -eq 100;$i++) {
    Measure-Command {
        Compress-Archive -Path $TestFile -DestinationPath "$env:TEMP\test_zip_file_$($i).zip" -CompressionLevel Fastest -Force
    }
}

$result = $compress | Measure-Object -Property TotalMilliseconds -Average -Maximum -Minimum


#endregion

#region Cleanup

# Removes zipped files
Get-ChildItem -Path "$env:TEMP\" -Filter "test_zip_file_*.zip" | Remove-Item -Force

# Removes original TXT file
Remove-Item -Path $TestFile -Force

#endregion

Write-Host $result
