MokListRT error occurs due to older versions of BIOS where EFI isn't fully implemented. Here is the workaround to get an Ubuntu USB to boot on those machines.

1. Enter Dell BIOS via F12
2. Select 'Boot Sequence' on left-hand menu
3. 'Unlock' the BIOS with the administrative password
4. Ensure 'Boot List Option' is toggled to 'UEFI'
5. Select 'Add Boot Option'
6. Name it 'UEFI [Secondary]'
7. Click '...' to browse for files
8. Select each 'FS' from the dropdown until you locate the Ubuntu USB drive
9. Navigate to /EFI/BOOT/
10. Select 'GRUBx64.EFI
11. Press OK two times
12. Select 'Apply'
13. Exit
14. If you get missing vmzlinuz or initrd
          a. Open the USB and navigate to /casper/
          b. Copy vmzlinuz and initrd
          c. Paste them in same directory and rename them as follows
          d. vmzlinuz.efi and initrd.lz