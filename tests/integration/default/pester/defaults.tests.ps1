describe "ansible_test_kitchen_windows_role ansible role" {
    Context "PSM Installation Path" {
        $Path = "C:\Program Files (x86)\Cyberark\PSM\Recordings"
        it "PSM Recordings Directory Exists" {
            Test-Path -Path $Path | Should be $true
        }
    }
}