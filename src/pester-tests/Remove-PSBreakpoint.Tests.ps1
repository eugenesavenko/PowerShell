﻿$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Describe "Remove-PSBreakpoint" {
    # Set up test script
    $testScript = "$here/assets/psbreakpointtestscript.ps1"

    $script = "`$var = 1
`$var2 = Get-Process 

# this is a comment
Get-Date
    "

    $script > $testScript

    BeforeEach {
        # set some breakpoints
        $line     = Set-PSBreakpoint -Line 1,2,3 -Script $testScript
        $command  = Set-PSBreakpoint -Command "Get-Date" -Script $testScript
        $variable = Set-PSBreakpoint -Variable var2 -Script $testScript
    }

    Context "Basic Removal Methods Tests" {
        It "Should be able to remove a breakpoint by breakpoint Id" {
            $NumberOfBreakpoints = $(Get-PSBreakpoint).Id.length
            $BreakID = $(Get-PSBreakpoint).Id[0]
            Remove-PSBreakpoint -Id $BreakID

            $(Get-PSBreakpoint).Id.length | Should Be ($NumberOfBreakpoints -1)
        }

        It "Should be able to remove a breakpoint by variable" {
            $NumberOfBreakpoints = $(Get-PSBreakpoint).Id.length
            Remove-PSBreakpoint -Breakpoint $variable

            $(Get-PSBreakpoint).Id.length | Should Be ($NumberOfBreakpoints -1)
        }

        It "Should be able to remove a breakpoint by command" {
            $NumberOfBreakpoints = $(Get-PSBreakpoint).Id.length
            Remove-PSBreakpoint -Breakpoint $command

            $(Get-PSBreakpoint).Id.length | Should Be ($NumberOfBreakpoints -1)
        }

        It "Should be able to pipe breakpoint objects to Remove-PSBreakpoint" {
            $NumberOfBreakpoints = $(Get-PSBreakpoint).Id.length
            $variable | Remove-PSBreakpoint

            $(Get-PSBreakpoint).Id.length | Should Be ($NumberOfBreakpoints -1)
        }
    }

    Context "Alias Tests" {
        It "Should remove a breakpoint using the rbp alias" {
            $NumberOfBreakpoints = $(Get-PSBreakpoint).Id.length
            $BreakID = $(Get-PSBreakpoint).Id[0]
            rbp -Id $BreakID

            $(Get-PSBreakpoint).Id.length | Should Be ($NumberOfBreakpoints -1)
        }
    }

    It "Should Remove all breakpoints" {
        $(Get-PSBreakpoint).Id.Length | Should Not BeNullOrEmpty

        Get-PSBreakpoint | Remove-PSBreakpoint

        $(Get-PSBreakpoint).Id.Length | Should Be 0
    }


    #Clean up after ourselves

    Remove-Item $testScript
}