#!/bin/bash
if [ $EUID -ne 0 ]; then
	echo "You must use sudo to run this script:"
	echo "sudo $0 $@"
	exit
fi 
apt update
apt install -y rpi-update vim

## dwc2 drivers
sed -i -e "\$adtoverlay=dwc2" /boot/config.txt
echo "dwc2" | sudo tee -a /etc/modules
sudo echo "libcomposite" | sudo tee -a /etc/modules

##Install git and download rspiducky
wget --no-check-certificate https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/asynchron_writing.sh https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/LICENSE https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/duckpi.sh https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/g_hid.ko https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/hid-gadget-test.c https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/hid_usb https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/readme.md https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/usleep https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/usleep.c https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/hid-gadget-test_german.c https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/test.sh https://raw.githubusercontent.com/lucki1000/Raspberry-Rubber-Ducky-Pi/experimental/kernel_files_copie.sh

sleep 3

read -p "Enter Keyboard layout supported layouts: `echo $'\n de \n us \n '`" layout

while [ $layout == "de" ] || [ $layout == "us" ];
do
	read -p "Enter Keyboard layout supported layouts: `echo $'\n de \n us \n '`" layout
done


if [[ $layout == "de" ]]
then	
	gcc hid-gadget-test_german.c -o hid-gadget-test
	echo "DE DEBUG MESSAGE"
fi

kernel="$(uname -r)"

if [ $layout == "us" ]; then
	echo "Your actual kernel version is: ${kernel}"
fi
if [ $layout == "de" ]; then
	echo "Dein aktueller Kernel ist: ${kernel}"
fi

if [[ $layout == "us" ]]
then
	gcc hid-gadget-test.c -o hid-gadget-test
	echo "EN DEBUG MESSAGE"
fi

sleep 3

# make script executable
chmod +x /home/pi/asynchron_writing.sh
# call other script
arg=hello										# It doesn't has a reason why hello :)
chmod +x /home/pi/kernel_files_copie.sh			# make it executable
sudo /home/pi/kernel_files_copie.sh $arg		# call script

# continue with this script
touch /home/pi/payload.txt

#
cat <<'EOF'>>/etc/modules
dwc2
g_hid
EOF

##Make it so that you can put the payload.dd in the /boot directory
sudo cp -r /home/pi/hid_usb /usr/bin/hid_usb
sudo chmod +x /usr/bin/hid_usb

sed -i '/exit/d' /etc/rc.local

cat <<EOF>>/etc/rc.local
/usr/bin/hid_usb # libcomposite configuration
sleep 3
cat /boot/payload.dd > /home/pi/payload.dd
sleep 1
tr -d '\r' < /home/pi/payload.dd > /home/pi/payload2.dd
sleep 1
/home/pi/duckpi.sh ${layout} /home/pi/payload2.dd
/home/pi/asynchron_writing.sh ${layout}
exit 0
EOF

##Making the first payload
cat <<'EOF'>>/boot/payload.dd
GUI r
DELAY 50
STRING www.youtube.com/watch?v=dQw4w9WgXcQ
ENTER
EOF

if [[ $layout == "de" ]]
then
	echo "Erst nach einem Neustart funktioniert dein Pi als Rubber-Ducky\n"
	read -p "Willst du dein Pi Neustarten?\n `echo $'\n ja \n nein \n '`" choice
	if [[ $choice == "ja" ]]
	then
		sudo reboot
	fi
fi

if [[ $layout == "us" ]]
then
	echo "First after a reboot your Pi can working as rubber ducky\n"
	read -p "Did you will restart your Pi?\n `echo $'\n yes \n no \n '`" choice
	if [[ $choice == "yes" ]]
	then
		sudo reboot
	fi
fi
