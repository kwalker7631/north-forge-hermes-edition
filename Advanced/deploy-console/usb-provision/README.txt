USB PROVISION — private pack only

Public north-forge-agent is not modified. Do not add this folder there.

Make the zip from THIS folder:
  Advanced\deploy-console\usb-provision\
Zip name: USB-PROVISION.zip
Drop the zip at the root of Advanced\deploy-console\ (admin tools).
Unpack next to Launch-Deploy-Console.cmd, or unpack anywhere and keep
this folder next to Zero-Touch-Deploy.ps1 if you copy that file in too.

Run:  Right-click Provision-USB.cmd → Run as administrator

It only lists USB / removable disks (Disk Number + size + model).
C: and other internal disks are hidden. Installing onto a PC disk is
possible with -AllowLocal after you type INSTALL-LOCAL. Do not.
