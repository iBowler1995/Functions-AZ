Function Get-AzWebJobStatus{    <#
    NOTES
    ===========================================================================
    Script Name: Get-AzWebAppJobStatus
    Created on:   	6/1/2023
    Created by:   	iBowler1995
    Filename: Get-AzwebAppJobStatus.ps1
    ===========================================================================
    .DESCRIPTION
        This script is used to check status of Azure App Serivce Web Jobs.
    ===========================================================================
    IMPORTANT:
    ===========================================================================
    This script is provided 'as is' without any warranty. Any issues stemming 
    from use is on the user.
    ===========================================================================
    .PARAMETER RG
    This parameter is a string and required - specifies target Resource Group
    .PARAMETER AppName
    This parameter is a string and required - specifies target Web App 
    .PARAMETER JobName
    This parameter is a string and required - specifies target Web Job
    .PARAMETER JobType
    This parameter is a string and required - specifies whether target job is continuous or triggered. Must use either Trig or Cont
    .PARAMETER Slot
    This parameter is a string and not required - specifies a specific deployment slot independent of the current active slot
    .EXAMPLES
    Get-AzWebAppJobStatus -RG 'contoso_rg' -AppName 'contoso_app' -Jobname 'contoso-job' -JobType 'cont' <- This will retrieve the status of the Web Job contoso-job from the Web App contoso_app in resource group contoso_rg
    Get-AzWebAppJobStatus -RG 'contoso_rg' -AppName 'contoso_app' -Jobname 'contoso-job' -JobType 'cont' -Slot contoso-slot <- This will retrieve the status of the Web Job contoso-job from the slot contoso-slot in the Web App contoso_app in resource group contoso_rg
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $TRUE)]
        [String]$RG,
        [Parameter(Mandatory = $TRUE)]
        [String]$AppName,
        [Parameter(Mandatory = $TRUE)]
        [String]$JobName,
        [Parameter(Mandatory = $TRUE)]
        [ValidateSet("Trig","Cont")]
        [String]$JobType,
        [Parameter()]
        [String]$Slot
    )


    #####################################
    If ($Slot){

        $profileIndex = 0  # Index of the profile to retrieve (0 for the first profile)
        # Get the deployment slot publishing profile
        $publishingProfileXml = Get-AzWebAppSlotPublishingProfile -ResourceGroupName $RG -Name $AppName -Slot $Slot
        # Load the XML into an XML document
        $publishingProfileDoc = [xml]$publishingProfileXml
        # Select a specific profile based on the index
        $selectedProfile = $publishingProfileDoc.publishData.publishProfile[$profileIndex]
        # Extract the publishing username and password from the selected profile
        $User = $selectedProfile.userName
        $Pass = $selectedProfile.userPWD
        $creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${user}:${pass}")));
        $header = @{

            Authorization = "Basic $creds"

        };
        #Generating the base URL for the Web App
        $kuduSlotApiBaseUrl = "https://$AppName-$Slot.scm.azurewebsites.net/api";
        #This runs if job is a triggered Web Job
        If ($Jobtype -eq "Trig"){

            
            $URI = "$kuduSlotApiBaseUrl/triggeredwebjobs/$JobName/"
            Try{

            Invoke-RestMethod -Uri $URI -Headers $Header -Method GET

            }
            catch{

                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody  

            }

        }
        #Otherwise this runs instead
        elseif ($JobType -eq "Cont"){

            $URI = "$kuduSlotApiBaseUrl/continuouswebjobs/$JobName/"
            Try{

                Invoke-RestMethod -Uri $URI -Headers $Header -Method GET
    
            }
            catch{
    
                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody  
    
            }
            

        }

    }
    else {

        # Get the publishing profile for the active deployment slot
        $publishingProfileXml = Get-AzWebAppPublishingProfile -ResourceGroupName $resourceGroupName -Name $appName
        # Load the XML into an XML document
        $publishingProfileDoc = [xml]$publishingProfileXml
        # Select the first publishing profile
        $firstProfile = $publishingProfileDoc.publishData.publishProfile[0]
        # Extract the publishing username and password from the first profile
        $User = $firstProfile.userName
        $Pass = $firstProfile.userPWD
        $creds = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${user}:${pass}")));
        $header = @{
            Authorization = "Basic $creds"
        };
        #Generating the base URL for the Web App
        $kuduApiBaseUrl = "https://$AppName.scm.azurewebsites.net/api";
        
        #####################################
    
        #This runs if job is a triggered Web Job
        If ($Jobtype -eq "Trig"){

            $URI = "$kuduApiBaseUrl/triggeredwebjobs/$JobName/"
            Try{

            Invoke-RestMethod -Uri $URI -Headers $Header -Method GET

            }
            catch{

                $ResponseResult = $_.Exception.Response.GetResponseStream()
                $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                $ResponseBody = $ResponseReader.ReadToEnd()
                $ResponseBody  

            }

        }
        #Otherwise this runs instead
        elseif ($JobType -eq "Cont"){

            $URI = "$kuduApiBaseUrl/continuouswebjobs/$JobName/"
            Try{

                Invoke-RestMethod -Uri $URI -Headers $Header -Method GET
    
                }
                catch{
    
                    $ResponseResult = $_.Exception.Response.GetResponseStream()
                    $ResponseReader = New-Object System.IO.StreamReader($ResponseResult)
                    $ResponseBody = $ResponseReader.ReadToEnd()
                    $ResponseBody  
    
                }

    }

    }

}