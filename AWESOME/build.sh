#!/bin/bash
#set -e
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
buildFolder="$HOME/ArcoHefftor-build"
outFolder="$HOME/ArcoHefftor-Out"

#Setting variables
#Let us change the name"
#First letter of desktop small

desktop="awesome"

#build.sh
oldname1="iso_name=arcolinux-hefftor"
newname1="iso_name=arco-hefftor-$desktop"

oldname2='iso_label="arcolinux-hefftor'
newname2='iso_label="arco-hefftor-'$desktop

#os-release
oldname3='NAME="ArcoLinux-Hefftor"'
newname3='NAME=ArcoLinux-Hefftor-'$desktop

oldname4='ID=ArcoLinux-Hefftor'
newname4='ID=ArcoLinux-Hefftor-'$desktop

#lsb-release
oldname5='DISTRIB_ID=ArcoLinux-Hefftor'
newname5='DISTRIB_ID=ArcoLinux-Hefftor-'$desktop

oldname6='DISTRIB_DESCRIPTION="ArcoLinux-Hefftor"'
newname6='DISTRIB_DESCRIPTION=ArcoLinux-Hefftor-'$desktop

#hostname
oldname7='ArcoLinux-Hefftor'
newname7='ArcoLinux-Hefftor-'$desktop

#hosts
oldname8='ArcoLinux-Hefftor'
newname8='ArcoLinux-Hefftor-'$desktop

echo
echo "################################################################## "
tput setaf 2;echo "Phase 1 : clean up and download the latest hefftor-iso from github";tput sgr0
echo "################################################################## "
echo
echo "Deleting the work folder if one exists"
[ -d ../work ] && rm -rf ../work
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder
echo "Git cloning files and folder to work folder"
git clone https://github.com/bradheff/hefftor-iso ../work

echo
echo "################################################################## "
tput setaf 2;echo "Phase 2 : Getting the latest versions for some important files";tput sgr0
echo "################################################################## "
echo
echo "Removing the old packages.x86_64 file from work folder"
rm ../work/archiso/packages.x86_64
echo "Copying the new packages.x86_64 file"
cp -f archiso/packages.x86_64 ../work/archiso/packages.x86_64

echo
echo "################################################################## "
tput setaf 2;echo "Phase 3 : Renaming the ArcoLinux iso";tput sgr0
echo "################################################################## "
echo
echo "Renaming to "$newname1
echo "Renaming to "$newname2
echo
sed -i 's/'$oldname1'/'$newname1'/g' ../work/archiso/build.sh
sed -i 's/'$oldname2'/'$newname2'/g' ../work/archiso/build.sh
sed -i 's/'$oldname3'/'$newname3'/g' ../work/archiso/airootfs/etc/os-release
sed -i 's/'$oldname4'/'$newname4'/g' ../work/archiso/airootfs/etc/os-release
sed -i 's/'$oldname5'/'$newname5'/g' ../work/archiso/airootfs/etc/lsb-release
sed -i 's/'$oldname6'/'$newname6'/g' ../work/archiso/airootfs/etc/lsb-release
sed -i 's/'$oldname7'/'$newname7'/g' ../work/archiso/airootfs/etc/hostname
sed -i 's/'$oldname8'/'$newname8'/g' ../work/archiso/airootfs/etc/hosts

echo
echo "################################################################## "
tput setaf 2;echo "Phase 4 : Checking if archiso is installed";tput sgr0
echo "################################################################## "
echo

package="archiso"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "################## "$package" is already installed"
		echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi yay &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with yay"
		echo "################################################################"
		yay -S --noconfirm $package

	elif pacman -Qi trizen &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with trizen"
		echo "################################################################"
		trizen -S --noconfirm --needed --noedit $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "#########  "$package" has been installed"
		echo "################################################################"

	else

		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi

fi

echo
echo "################################################################## "
tput setaf 2;echo "Phase 5 : Moving files to build folder";tput sgr0
echo "################################################################## "
echo

echo "Copying files and folder to build folder as root"
sudo mkdir $buildFolder
sudo cp -r ../work/* $buildFolder

sudo chmod 750 ~/ArcoHefftor-build/archiso/airootfs/etc/sudoers.d
sudo chmod 750 ~/ArcoHefftor-build/archiso/airootfs/etc/polkit-1/rules.d
sudo chgrp polkitd ~/ArcoHefftor-build/archiso/airootfs/etc/polkit-1/rules.d

echo "Deleting the work folder if one exists - clean up"
[ -d ../work ] && rm -rf ../work

cd $buildFolder/archiso


echo
echo "################################################################## "
tput setaf 2;echo "Phase 6 : Cleaning the cache";tput sgr0
echo "################################################################## "
echo

yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2;echo "Phase 7 : Building the iso";tput sgr0
echo "################################################################## "
echo

sudo ./build.sh -v

echo
echo "################################################################## "
tput setaf 2;echo "Phase 8 : Moving the iso to out folder";tput sgr0
echo "################################################################## "
echo

[ -d $outFolder ] || mkdir $outFolder
cp $buildFolder/archiso/out/arcolinux* $outFolder

echo
echo "################################################################## "
tput setaf 2;echo "Phase 9 : Making sure we start with a clean slate next time";tput sgr0
echo "################################################################## "
echo
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder