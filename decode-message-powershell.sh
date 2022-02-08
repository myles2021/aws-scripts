# install awscli on powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
# set env variable fix
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
# check it's installed
aws --version
# give the encrypted code as an argument and output it into the terminal
aws sts decode-authorization-message --encoded-message
