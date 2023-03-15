# Ubuntu Autoinstall

This folder contains the autoinstall files for Ubuntu. These files should go to the CIDATA filesystem
that is mounted during the installation process.

This guide was roughly based on [How to automate a bare metal Ubuntu 22.04 installation](https://www.jimangel.io/posts/automate-ubuntu-22-04-lts-bare-metal/). The actual Ubuntu documentation is [here](https://ubuntu.com/server/docs/install/autoinstall).

All commands assume a debian based system.

## How to use

NOTE: The Razor terminals currently have issues autoinstalling Ubuntu 22.04. We can get around this
by installing Ubuntu 20.04 and then upgrading to 22.04. Hopefully this will be fixed in the future.
If you are using a Razor terminal, you will need to use Ubuntu 20.04 in place of 22.04 below.

### Download the ISO

```bash
sudo su -
export ISO="https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
wget $ISO
```

### Create the modified ISO

This is used to specify the autoinstall files and to reduce the boot menu timeout.

WARNING: The below updates to the grub file also enable autoinstall. This will disable the install prompt for the installation media. If the installation media were to be left in a machine which was set to boot from it, it would automatically install Ubuntu.

#### Mount the ISO locally to copy files

```bash
export ORIG_ISO="ubuntu-22.04.5-live-server-amd64.iso"
mkdir mnt
mount -o loop $ORIG_ISO mnt
```

#### Copy the existing boot file to `/tmp/grub.cfg`

```bash
cp --no-preserve=all mnt/boot/grub/grub.cfg /tmp/grub.cfg
```

Modify `/tmp/grub.cfg` in the first section “Try or Install Ubuntu Server” to include ‘autoinstall quiet’ after ’linux /casper/vmlinuz.’

##### Autoinstall files hosted in GitHub

Required Internet; This is the preferred method as it allows for easy updates to the autoinstall files.

```bash
sed -i 's/linux	\/casper\/vmlinuz  ---/linux	\/casper\/vmlinuz autoinstall ds="nocloud-net;s=https://raw.githubusercontent.com/quikserve/carbon-bootstrap/master/ubuntu/autoinstaller/" quiet ---/g' /tmp/grub.cfg
```

##### Autoinstall files on USB drive

Requires a second USB drive to be plugged in during installation.

Drive must be formatted as FAT32 and named “CIDATA”. The user-data and meta-data files must be placed in the root of the drive.

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

### Create the installation media

Use your favorite tool to create a USB drive from the ISO.
