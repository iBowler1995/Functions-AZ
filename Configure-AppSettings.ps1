Function Configure-AppSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String[]]$Values,
        [Parameter(Mandatory = $true)]
        [String[]]$Settings,
        [Parameter(Mandatory = $True)]
        [String]$App,
        [Parameter(Mandatory = $True)]
        [String]$RG
    )

    if ($Settings.Count -ne $Values.Count) {
        throw "Settings and Values arrays must be the same length."
    }    
    
    Try {

        #Wait for SiteConfig to be ready, sometimes this doesn't populate quickly enough.
        $appReady = $false
        for ($i = 0; $i -lt 10; $i++) {
            $Application = Get-AzWebApp -Name $App -ResourceGroupName $RG
            if ($Application.SiteConfig.AppSettings) {
                $appReady = $true
                break
            }
            Start-Sleep -Seconds 3
        }

        #Throw error if SiteConfig still not loaded
        if (-not $appReady) { throw "Web App not ready (SiteConfig missing)." }
        
        $newAppSettings = @{}
        foreach ($s in $Application.SiteConfig.AppSettings) {
            $newAppSettings[$s.Name] = $s.Value
        }
            
        #Add the new settings to the hashtable
        For ($i = 0; $i -lt $Settings.Count; $i++){
            Write-Host "Configuring App setting $($Settings[$i])..." -ForegroundColor Cyan
            $newAppSettings[$Settings[$i]] = $Value[$i]
            Write-Host "App Setting $($Settings[$i]) successfully added!" -ForegroundColor Green
            Write-Host "================"            
        }
        
            
        #Update the web app with the new settings
        Write-Host "Applying new settings..." -ForegroundColor Cyan
        Set-AzWebApp -AppSettings $newAppSettings -ResourceGroupName $RG -Name $App -ErrorAction Stop | Out-Null
        Write-Host "Restarting Web App..." -ForegroundColor Cyan
        Restart-AzWebApp -Name $App -ResourceGroupName $RG | Out-Null
        Write-Host "App settings configured!" -ForegroundColor Green
        Write-Host "================"
            

    }
    catch {

        Write-Error "Error configuring App settings at line $($_.InvocationInfo.ScriptLineNumber): $_"

    }

}