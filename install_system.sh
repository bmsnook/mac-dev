#!/bin/bash

## 
## VARIABLES - Directories
## 
export BIN="/usr/bin"
export SBIN="/usr/sbin"
export DOWNLOADS="~/Downloads"
export LOCALREPO="${DOWNLOADS}"

## Using the Daisy for Jenkins and YinYang for Ansible profile pics
##   enclose variable calls in quotes to protect spaces, i.e.:
##     ... "${YINYANG_PIC}" ... 
export DAISY_PIC="/Library/User Pictures/Flowers/Yellow Daisy.tif"
export YINYANG_PIC="/Library/User Pictures/Fun/Ying-Yang.png"


## 
## COMMANDS - System Functions Defined
## 

get_next_uid () { dscl . -list /Users UniqueID | \
	awk '$NF>uid{uid=$NF} END { \
		if(uid>=500){ \
			printf("%d\n",uid+1)} \
		else{print "500"}}'; \
}

update_os () { ${BIN}/sudo ${SBIN}/softwareupdate -i -a; }
get_energy_settings () { \
	${BIN}/sudo ${SBIN}/systemsetup -getcomputersleep; 
	${BIN}/sudo ${SBIN}/systemsetup -getdisplaysleep; 
	${BIN}/sudo ${SBIN}/systemsetup -getharddisksleep; 
	${BIN}/sudo ${SBIN}/systemsetup -getwakeonnetworkaccess; 
	${BIN}/sudo ${SBIN}/systemsetup -getrestartpowerfailure; 
}
set_energy_settings () { \
	${BIN}/sudo ${SBIN}/systemsetup -setcomputersleep Never; 
	${BIN}/sudo ${SBIN}/systemsetup -setdisplaysleep 5; 
	${BIN}/sudo ${SBIN}/systemsetup -setharddisksleep Never; 
	${BIN}/sudo ${SBIN}/systemsetup -setwakeonnetworkaccess off; 
	${BIN}/sudo ${SBIN}/systemsetup -setrestartpowerfailure on; 
}


## Create account(s)
##   use ${BIN}/dscl or ${SBIN}/sysadminctl
#${SBIN}/sysadminctl
create_account_ansible () { \
  NUID=`get_next_uid`;
  PASS=`head -1 /dev/random | md5`;
sudo ${SBIN}/sysadminctl -addUser ansible -fullName "Ansible" -UID ${NUID} -shell /bin/bash -password ${PASS} -hint "Use SSH Keys" -picture ${YINYANG_PIC} -admin;
}

create_account_ansible_dscl () {
  NUID=`get_next_uid`;
  PASS=`head -1 /dev/random | md5`;
  sudo dscl . -create /Users/ansible;
  sudo dscl . -create /Users/ansible UserShell /bin/bash;
  sudo dscl . -create /Users/ansible RealName "Ansible";
  sudo dscl . -create /Users/ansible UniqueID ${NUID};
  sudo dscl . -create /Users/ansible PrimaryGroupID 20;
  sudo dscl . -create /Users/ansible NFSHomeDirectory /Users/ansible;
  sudo dscl . -passwd /Users/ansible ${PASS};
  sudo dscl . -merge /Groups/admin GroupMembership ansible;
}


## Energy Settings
echo "Show (get) the current Energy settings"
get_energy_settings
#set_energy_settings


## 
## COMMANDS - Software Setup Functions Defined
## 

## download Xcode
download_xcode () { cd ${LOCALREPO} && curl -O https://download.developer.apple.com/Developer_Tools/Xcode_10.2.1/Xcode_10.2.1.xip; }

## install Xcode
install_xcode () { cd ${LOCALREPO} && ls -tr Xcode*.xip | tail -1 | xargs open; }

## install Developer tools
install_dev_tools () { xcode-select --install; }

## install Homebrew
##   NOTE: install line from https://brew.sh
install_homebrew () { /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }

## download Oracle Java
download_java () { 
cd ${LOCALREPO} && \
curl --cookie "Cookie: oraclelicense=accept -securebackup-cookie" -O \
https://download.oracle.com/otn/java/jdk/8u211-b12/478a62b7d4e34b78b671c754eaaf38ab/jdk-8u211-macosx-x64.dmg; 
}
## Using wget w/ the "magic cookie" workaround still prompts for a Sun account
## https://kdecherf.com/blog/2012/04/12/oracle-i-download-your-jdk-by-eating-magic-cookies/
## 
# brew install wget
# wget --no-check-certificate -c --header "Cookie: oraclelicense=accept -securebackup-cookie" \
# https://download.oracle.com/otn/java/jdk/8u211-b12/478a62b7d4e34b78b671c754eaaf38ab/jdk-8u211-macosx-x64.dmg
## 
## Adding auth info to .netrc resulted in failure with the final message: 
##   20 redirections exceeded.
## 

## install Oracle Java
##   https://www.oracle.com/technetwork/java/javase/downloads/index.html
##   https://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
install_java () { cd ${LOCALREPO} && ls -tr jdk*.dmg | tail -1 | xargs open; }

## install Node
##   NOTE: install Oracle Java first
install_node () { brew install node; }

## install Appium
install_appium () { npm install -g appium; }

## install RVM (Ruby Version Manager)
install_rvm () { curl -sSL https://get.rvm.io | bash -s stable; }
## ALSO: 
##   rvm install 2.6.3
##   rpm use 2.6.3 --default

## install Android Studio
## https://developer.android.com/studio#downloads
##   android-studio-ide-183.5522156-mac.dmg
install_android_studio () { cd ${LOCALREPO} && ls -tr android-studio*.dmg | tail -1 | xargs open; }

## prep to install Jenkins
prep_jenkins_before {
  sudo mkdir /Users/Shared/Jenkins;
  chown -R jenkins /Users/Shared/Jenkins;
}

## install Jenkins
##   https://jenkins.io/download/
##   https://jenkins.io/download/thank-you-downloading-osx-installer-stable/
##   https://wiki.jenkins.io/display/JENKINS/Thanks+for+using+OSX+Installer
install_jenkins () {
  cd ${LOCALREPO} && ls -tr jenkins*.pkg | tail -1 | xargs open;
}

## prep after Jenkins installation
prep_jenkins_after {
  ## update /Library/Preferences/org.jenkins-ci.plist
  echo;
}

## install Microsoft Visual Studio
##   https://visualstudio.microsoft.com/vs/mac/
##   https://visualstudio.microsoft.com/thank-you-downloading-visual-studio-mac/?sku=communitymac&rel=16
##   https://visualstudio.microsoft.com/thank-you-downloading-visual-studio-mac/?sku=communitymac&rel=16#
install_ms_visual_studio () { cd ${LOCALREPO} && ls -tr VisualStudio*.dmg | tail -1 | xargs open; }


## COMMANDS - Main Execution
## 
echo
echo "## Complete system prerequisites"
echo update_os 
echo get_energy_settings
echo set_energy_settings
echo get_energy_settings
echo create_account_ansible
echo 
echo "## List of things to do:"
echo install_xcode
echo install_dev_tools
echo install_java
echo install_node
echo install_appium
echo install_rvm
echo install_android_studio
echo install_jenkins
echo install_ms_visual_studio


