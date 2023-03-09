# Ubuntu Autoinstall

This folder contains the autoinstall files for Ubuntu. These files should go to the CIDATA filesystem
that is mounted during the installation process.

This guide was roughly based on [How to automate a bare metal Ubuntu 22.04 installation](https://www.jimangel.io/posts/automate-ubuntu-22-04-lts-bare-metal/). The actual Ubuntu documentation is [here](https://ubuntu.com/server/docs/install/autoinstall).

## How to use

NOTE: We prefer Ubuntu 22.04 as it defaults to wayland, which fixes some multi-display issues. However,
as of current 22.04 has issues with autoinstall so 20.04 is what is currently used. Hopefully this will
be resolved soon.

### Download the ISO

```bash
sudo su -
export ISO="https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso"
wget $ISO
```

### Disable install prompts

This is used to disable the initial installation prompt.

WARNING: This will disable the install prompt for the installation media. If the installation media were
to be left in a machine which was set to boot from it, it would automatically install Ubuntu.

#### Mount the ISO locally to copy files

```bash
export ORIG_ISO="ubuntu-22.04.1-live-server-amd64.iso"
mkdir mnt
mount -o loop $ORIG_ISO mnt
```

#### Copy the existing boot file to `/tmp/grub.cfg`

```bash
cp --no-preserve=all mnt/boot/grub/grub.cfg /tmp/grub.cfg
```

Modify `/tmp/grub.cfg` in the first section “Try or Install Ubuntu Server” to include ‘autoinstall quiet’ after ’linux /casper/vmlinuz.’

```bash
sed -i 's/linux	\/casper\/vmlinuz  ---/linux	\/casper\/vmlinuz autoinstall quiet ---/g' /tmp/grub.cfg
```

#### Reduce the boot menu timeout

```bash
sed -i 's/timeout=30/timeout=1/g' /tmp/grub.cfg
```

#### Rebuild the modified ISO

```bash
apt install xorriso squashfs-tools python3-debian gpg liblz4-tool python3-pip -y

git clone https://github.com/mwhudson/livefs-editor

cd livefs-editor/

python3 -m pip install .

# copy command exactly as is, it appends `-modded` to the new filename
export MODDED_ISO="${ORIG_ISO::-4}-modded.iso"
livefs-edit ../$ORIG_ISO ../$MODDED_ISO --cp /tmp/grub.cfg new/iso/boot/grub/grub.cfg
```
