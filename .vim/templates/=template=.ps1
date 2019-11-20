#requires -version 5
<#
.SYNOPSIS
  <Overview of script>

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         %USER% <%MAIL%>
  Creation Date:  %DATE%
  Purpose/Change: Initial script development

.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#--------------------------------[Parameters]---------------------------------
Param(
  [ValidateNotNull()]
  [parameter(Mandatory=$True)]
  [string]$MyParam
)

#-------------------------------[Initialisation]------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#--------------------------------[Declarations]--------------------------------

#----------------------------------[Functions]---------------------------------

<#

Function <FunctionName>{
  Param()

  Begin{
  }

  Process{
    Try{
      <code goes here>
    }

    Catch{
      Break
    }
  }

  End{
    If($?){
      Write-Verbose "Completed successfully."
    }
  }
}

#>

#----------------------------------[Execution]---------------------------------
