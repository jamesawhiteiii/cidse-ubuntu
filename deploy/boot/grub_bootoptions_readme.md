#### GRUB Reference

These represent most of the GRUB kernel boot options we've used or encounted in getting the preseed up and working.
There are likely more than this. But this is a good reference starting point if you're reconfiguring a GRUB menu option or troubleshooting.


```
splash                                        -- Ubuntu dots splash screen when first booting to live environment
quiet                                         -- Seems to surpress console output while loading initial install environment
auto=true                                     -- No effect?
nomodeset                                     -- Fix 1/2 for NVMe computers or GPU related issues (looking at you nVidia)
acpi=off                                      -- Fix 2/2 for NVMe computers (so far only needed on laptops sometimes)
only-ubiquity                                 -- No GNOME shell but still installer GUI (not automated necessarily)
file=/cdrom/preseed/fse.seed                  -- Preseed file itself
debian-installer/locale=en_US                 -- Language stuff
keyboard-configuration/layoutcode=us          -- Language stuff
languagechooser/language-name=English         -- Language stuff
countrychooser/shortlist=US                   -- Language stuff
localechooser/supported-locales=en_US.UTF-8   -- Language stuff
boot=casper                                   -- Pre-Ubiquity environment (needed to load the installer)
automatic-ubiquity                            -- Automatic mode for ubiquity (implies only-ubiquity as well)
noninteractive                                -- Text-based installer (no Ubiquity GUI or GNOME), useful for debugging, also looks cool
````