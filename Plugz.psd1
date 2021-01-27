@{
    ModuleVersion        = '0.1.0'

    GUID                 = 'cfabab54-ea42-4ecf-8201-eefc71731e9b'
    Author               = 'Freddie Sackur'
    CompanyName          = 'DustyFox'
    Copyright            = '(c) 2021 Freddie Sackur. All rights reserved.'

    Description          = 'A simple tool to conditionally load bits in your PS profile.'
    HelpInfoURI          = 'https://github.com/fsackur/Plugz'

    PowerShellVersion    = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    RootModule           = 'Plugz.psm1'

    RequiredModules      = @(
        @{
            ModuleName    = 'Configuration'
            ModuleVersion = '1.3.1'
        }
    )

    FunctionsToExport    = @()

    PrivateData          = @{

        PSData = @{

            Tags       = @('Plugin', 'Profile')
            LicenseUri = 'https://raw.githubusercontent.com/fsackur/Plugz/main/LICENSE'
            ProjectUri = 'https://github.com/fsackur/Plugz'
        }
    }
}

