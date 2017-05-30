cls
Describe ("Environment checks for the Pester Max talk") {
    Context "Apps" {
        It "Mail Should be closed" {
            (Get-Process HxMail -ErrorAction SilentlyContinue).COunt | Should Be 0
        }
        It "Tweetium should be closed" {
            (Get-Process WWAHost -ErrorAction SilentlyContinue).Count | Should Be 0
        }
        It "Slack should be closed" {
            (Get-Process slack* -ErrorAction SilentlyContinue).Count | Should Be 0
        }

        It "NginX should be running" {
            (Get-Process nginx -ErrorAction SilentlyContinue).Count | Should Be 2
        }
        It "Docker for Windows should be running" {
            (Get-Process 'Docker for Windows' -ErrorAction SilentlyContinue).Count | Should Be 1
        }
        It "The docker deamon should be running" {
            (Get-Process dockerd -ErrorAction SilentlyContinue).Count | Should Be 1
        }
    }
}
