#!/bin/bash
#Files variable may need work and may need to automatically gather file names/paths from a function
DIR=$(find /opt/bin/ /var/www/html/ /etc/tacacs+/ /etc/postfix/ -type f)
FILES="$DIR"
TACLOG="/var/log/taclogs/taclog"
USERLIST=$(getent group tacusers | cut -f4 -d ':' | sed 's/,/ /g;')
CONFIGURED=false
#This is where the current variables will be stored NOTE CHANGE TO /OPT/BIN/TAC.CONF WHEN TESTING IS OVER
source tac.conf
#trap '' 2
echo "<----`date`---->" >> $TACLOG
echo "Twotac Management" >> $TACLOG
if [ $FIRSTSETUP = "false" ]; then
	clear
	yn=""
	echo "========================================================================================="
	echo "                                      Twotac Setup                                       "
	echo "========================================================================================="
	echo ""
	echo ""
	echo "This looks like your first time running setup, would you like to skip straight to setup?"
	echo "(yes/no)"
	echo ""
	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
  		read yn
		if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
			echo " That output doesn't register, please try again."
		fi
		if [[ "$yn" =~ ^[Nn](o)?$ ]]; then
			FIRSTSETUP="true"
			sed -i 's/FIRSTSETUP\=\"false\"/FIRSTSETUP\=\"true\"/g' /opt/bin/tac.conf
			break
		fi
	done
	echo ""
	echo "This system employs a number of scripts to make this software easy to use."
	echo "The current list of scripts in /opt/bin are:"
	ls /opt/bin/ | grep .sh
	echo ""
	yn=""
	until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
		echo " Would you like to make these scripts global? (y/n)"
	 		read yn
		if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
			echo " That output doesn't register, please try again."
		fi
	done
	if [[ "$yn" =~ ^[Nn](o)?$ ]]; then
		break
	fi
	if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		sudo ln -s /opt/bin/*.sh /usr/bin/
	fi
	yn=""
	echo "========================================================================================="
	echo "                                  Twotac Configurations                                  "
	echo "========================================================================================="
	echo ""
	echo "Checking for installed files..."
	if [[ /etc/tacacs+/tac_plus.conf ]]; then 
		tacacs="tacacs" 
	else 
		tacacs="" 
	fi
	if [[ /etc/postfix/main.cf ]]; then 
		postfix="postfix" 
	else 
		postfix="" 
	fi
	if [[ /etc/pam.d/tac_plus ]]; then 
		pam="pam" 
	else 
		pam="" 
	fi
	if [[ /etc/apache2/apache2.conf ]]; then 
		apache2="apache2" 
	else 
		apache2="" 
	fi
	if [[ $tacacs ]] || [[ $postfix ]] || [[ $pam ]]; then
		echo ""
		echo "It looks like these configurations are available to overwrite:"
		echo ""
		if [[ $tacacs ]]; then 
			echo -e "$tacacs"
		fi
		if [[ $postfix ]]; then 
			echo -e "$postfix"
		fi
		if [[ $pam ]]; then 
			echo -e "$pam"
		fi
		echo ""
		echo "Would you like to overwrite your standard configurations for the twotac default configuration?"
		until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
			echo " Would you like to continue? (y/n)"
		 		read yn
			if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
				echo " That output doesn't register, please try again."
			fi
		done
		 	if [[ "$yn" =~ ^[Nn](o)?$ ]]; then
		 		break
		 	fi
		 	if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		 		NEWKEY="$TEMPKEY"
		 		echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
		 		CONFIGURED=false
		if [[ $tacacs ]]; then
			tacacs=$(cat /opt/tacconfigs/tacacs+/tac_plus.conf)
			sudo echo "" > /etc/tacacs+/tac_plus.conf
			sudo echo "$tacacs" >> /etc/tacacs+/tac_plus.conf
		fi
		if [[ $postfix ]]; then
			postfix=$(cat /opt/tacconfigs/postfix/main.cf)
			sudo echo "" > /etc/postfix/main.cf
			sudo echo "$postfix" >> /etc/postfix/main.cf
		fi
		if [[ $pam ]]; then
			pam=$(cat /opt/tacconfigs/pam.d/tac_plus)
			sudo echo "" > /etc/pam.d/tac_plus
			sudo echo "$pam" >> /etc/pam.d/tac_plus
		fi
		fi
		echo ""
		echo ""
		if ! [[ $apache2 ]] && [[ $tacacs ]] && [[ $postfix ]] && [[ $pam ]]; then
			echo "Some dependencies still aren't installed"
			echo "Please install"
			if ! [[ $tacacs ]]; then 
				echo -e "tacacs"
			fi
			if ! [[ $postfix ]]; then 
				echo -e "postfix"
			fi
			if ! [[ $pam ]]; then 
				echo -e "pam"
			fi
			if ! [[ $apache2 ]]; then 
				echo -e "apache2"
			fi
			echo "Twotac will not work as intended until you install all dependencies"
		fi
	else
		echo "It doesn't look like any dependencies are installed."
		echo "Please install"
		if ! [[ $tacacs ]]; then 
			echo -e "tacacs"
		fi
		if ! [[ $postfix ]]; then 
			echo -e "postfix"
		fi
		if ! [[ $pam ]]; then 
			echo -e "pam"
		fi
		if ! [[ $apache2 ]]; then 
			echo -e "apache2"
		fi
		echo "This software will not work as intended until you do."
	fi
	echo "Rewriting config data..."
	yn=""
	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
		echo "========================================================================================="
		echo "                                    Organization Name                                    "
		echo "========================================================================================="
		echo -e " Currently, the organization name is $ORG \n What would you like to change it to?"
			if [[ $NEWORG ]]; then
				echo -e "The current replacement is $NEWORG"
			fi
		echo ""
		read TEMPORG
		echo ""
		echo " $TEMPORG will be your new organization name"
		yn=""
		until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
			echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
  			read yn
			if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
			echo " That output doesn't register, please try again."
			fi
		done
		if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
			break
		fi
		if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
			NEWORG="$TEMPORG"
			echo "$ORG \t::::\t $NEWORG" >> $TACLOG
			CONFIGURED=false
		fi
	done
	if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
	yn="n"
	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
		echo "========================================================================================="
		echo "                                      Web Host Name                                      "
		echo "========================================================================================="
		echo -e " Currently, the website's hostname is $WEB \n What would you like to change it to?"
		echo " NOTE: If you would like to make this site https, include it in the hostname"
		echo " Example format: https://tacacs.com     (do not leave a trailing /)"
			if [[ $NEWWEB ]]; then
				echo -e "The current replacement is $NEWWEB"
			fi
		echo ""
		read TEMPWEB
		echo ""
		echo " $TEMPWEB will be your new host address"
		yn=""
		until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
			echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		 		read yn
			if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
				echo " That output doesn't register, please try again."
			fi
		 	done
		if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
			break
		fi
		if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
			NEWWEB="$TEMPWEB"
			echo "$WEB \t::::\t $NEWWEB" >> $TACLOG
			CONFIGURED=false
		fi
	done
	fi
	if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
	yn="n"
	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
		echo "========================================================================================="
		echo "                                   Administrator Mail                                    "
		echo "========================================================================================="
		echo -e " Currently, the admin's mail address is $MAIL \n What would you like to change it to?"
			if [[ $NEWMAIL ]]; then
				echo -e "The current replacement is $NEWMAIL"
			fi
		echo ""
		read TEMPMAIL
		echo ""
		echo " $TEMPMAIL will be your new admin's e-mail"
		yn=""
		until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
			echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
				read yn
			if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
				echo " That output doesn't register, please try again."
			fi
			done
		if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
			break
		fi
		if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
			NEWMAIL="$TEMPMAIL"
			echo "$MAIL \t::::\t $NEWMAIL" >> $TACLOG
			CONFIGURED=false
		fi
	done
	fi
	if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
	yn="n"
	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
		echo "========================================================================================="
		echo "                                     SMTP Relay Host                                     "
		echo "========================================================================================="
		echo -e " Currently, the SMTP host is $SMTP \n What would you like to change it to?"
		echo " Example: smtp.gmail.com     (or your organization's smtp server address)"
			if [[ $NEWSMTP ]]; then
				echo -e "The current replacement is $NEWSMTP"
			fi
		echo ""
		read TEMPSMTP
		echo ""
		echo " $TEMPSMTP will be your new SMTP host"
		yn=""
		until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
			echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
				read yn
			if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
				echo " That output doesn't register, please try again."
			fi
			done
			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
				break
			fi
			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
				NEWSMTP="$TEMPSMTP"
				echo "$SMTP \t::::\t $NEWSMTP" >> $TACLOG
				CONFIGURED=false
			fi
	done
	fi
	if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
	yn="n"
	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
		echo "========================================================================================="
		echo "                                       TACACS+ Key                                       "
		echo "========================================================================================="
		echo -e " Currently, the TACACS+ key is $KEY \n What would you like to change it to?"
		echo " ***WARNING, YOU WILL NEED TO CHANGE ALL ROUTER CONFIGS TO MATCH THE NEW ONE***"
			if [[ $NEWKEY ]]; then
				echo -e "The current replacement is $NEWKEY"
			fi
		echo ""
		read TEMPKEY
		echo ""			
		echo " $TEMPKEY is your new TACACS+ key. If your routers don't match, they will be inaccessible"
		yn=""
		until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
			echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		 		read yn
			if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
				echo " That output doesn't register, please try again."
			fi
			done
			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
				break
			fi
			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
				NEWKEY="$TEMPKEY"
				echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
				CONFIGURED=false
			fi
	done
	fi
	if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		yn="n"
		clear
		if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
		echo "========================================================================================="
		echo "                                   Configuration Changes                                 "
		echo "========================================================================================="
		echo -e " Original#::::#New" >> /tmp/tacjunk
		if [[ $NEWORG ]]; then
			echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
		fi
		if [[ $NEWWEB ]]; then
			echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
		fi
		if [[ $NEWMAIL ]]; then
			echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
		fi
		if [[ $NEWSMTP ]]; then
			echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
		fi
		if [[ $NEWKEY ]]; then
			echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
		fi
		cat /tmp/tacjunk | column -t -s '#'
		rm /tmp/tacjunk
		fi
		echo ""
		read -p " Are you certain you want to commit these changes? There will be no way to undo them. (yes/no)" yn
		  case $yn in
		    [Yy]* )
			sed -i 's/FIRSTSETUP\=\"false\"/FIRSTSETUP\=\"true\"/g' /opt/bin/tac.conf
			if [[ $NEWORG ]]; then
				echo "$NEWORG COMMITTED" >> $TACLOG
				sed -i "s/$ORG/$NEWORG/g" $FILES
				NEWORG=""
				fi
			if [[ $NEWWEB ]]; then
				echo "$NEWWEB COMMITTED" >> $TACLOG
				sed -i "s/$WEB/$NEWWEB/g" $FILES
				NEWWEB=""
				fi
			if [[ $NEWMAIL ]]; then
				echo "$NEWMAIL COMMITTED" >> $TACLOG
				sed -i "s/$MAIL/$NEWMAIL/g" $FILES
				NEWMAIL=""
				fi
			if [[ $NEWSMTP ]]; then
				echo "$NEWSMTP COMMITTED" >> $TACLOG
				sed -i "s/$SMTP/$NEWSMTP/g" $FILES
				NEWSMTP=""
				fi
			if [[ $NEWKEY ]]; then
				echo "$NEWKEY COMMITTED" >> $TACLOG
				sed -i "s/$KEY/$NEWKEY/g" $FILES
				NEWKEY=""
				fi
			CONFIGURED=true
			;;
		[Nn]* ) continue
			;;
		  esac
		fi
fi
while true
do
	clear
	yn=""
	if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
	echo "========================================================================================="
	echo "                                   Configuration Changes                                 "
	echo "========================================================================================="
	echo "***Changes have NOT been saved. Go to case 3 to commit these changes***"
	echo -e " Original#::::#New" >> /tmp/tacjunk
	if [[ $NEWORG ]]; then
		echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
	fi
	if [[ $NEWWEB ]]; then
		echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
	fi
	if [[ $NEWMAIL ]]; then
		echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
	fi
	if [[ $NEWSMTP ]]; then
		echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
	fi
	if [[ $NEWKEY ]]; then
		echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
	fi
	cat /tmp/tacjunk | column -t -s '#'
	rm /tmp/tacjunk
	fi
	echo "========================================================================================="
	echo "                                    Twotac Management                                    "
	echo "========================================================================================="
	echo " Available commands:"
	echo " To add, edit or view users,            enter 1"
	echo " To run backups or view logs,           enter 2"
	echo " To setup or change script information, enter 3"
	echo " To view or edit configs,               enter 4"
	echo " To exit this interface,                enter Q"
	if [ $FIRSTSETUP = "false" ]; then
		echo " To stop first time setups,             enter S"
	fi
	echo ""
	echo "====================================================="
	echo " Enter your selection"
	echo "====================================================="
	echo ""
	read answer
	case $answer in
		[Ss] )
		sed -i 's/FIRSTSETUP\=\"false\"/FIRSTSETUP\=\"true\"/g' /opt/bin/tac.conf
		;;
		1) #This case enters the user management interface
			clear
			yn=""
			echo "========================================================================================="
			echo "                                 Twotac User Management                                  "
			echo "========================================================================================="
			echo " Available commands:"
			echo " To view current users,                 enter 1"
			echo " To add a user,                         enter 2"
			echo " To delete a user,                      enter 3"
			echo " To exit this interface,                enter Q"
			echo ""
			echo "====================================================="
			echo " Enter your selection"
			echo "====================================================="
			echo ""
			read answer
			case $answer in
				1) #This case will find users, add them to a file and columnate it before cat'ing and deleting that file.
					echo -e "Viewed user list" >> $TACLOG
					for f in $USERLIST; do
							getent passwd $f | cut -f5 -d',' | cut -f1 -d':' >> /tmp/tacjunk
						done
					MAILLIST=$(cat /tmp/tacjunk | sed ':a;N;$!ba;s/\n/ /g')
					rm /tmp/tacjunk
						for f in $USERLIST; do
							grep -c $f /etc/tacacs+/tac_plus.conf >> /tmp/tacjunk
						done
					TACLIST=$(cat /tmp/tacjunk | sed ':a;N;$!ba;s/\n/ /g' | sed 's/1/Registered/g' | sed 's/0/Unregistered/g')
					rm /tmp/tacjunk
						for f in $USERLIST; do
							find /home/$f/ -exec stat \{} --printf="%y\n" \; | sort -n -r | head -n 1 | awk '{print $1}' >> /tmp/tacjunk
						done
					REGLIST=$(cat /tmp/tacjunk | sed ':a;N;$!ba;s/\n/ /g')
					rm /tmp/tacjunk
					echo -e "$USERLIST\n$MAILLIST\n$TACLIST\n$REGLIST" >> /tmp/tacjunk
					cat /tmp/tacjunk | sed 's/ /,:,/g' | column -t -s ','
					rm /tmp/tacjunk
					read -p " Press enter to continue"
					;;
				2) #This case will add a user based on input
					until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "Add user initiated" >> $TACLOG
						echo " You have chosen to add a user."
						echo " Please enter the new username"
						read username
						echo -e "Username= $username" >> $TACLOG
						password=""
						passconf=""
						until [[ $password ]] &&  [[ $passconf ]] && [[ $password == $passconf ]]; do
							if  [[ $password ]]; then
								if [[ $password -ne $passconf ]]; then
									echo " The passwords do not match, please try again"
								fi
							fi
							echo " Please enter the new password"
							read -s password
							echo " Please confirm your password"
							read -s passconf
						done
						echo " Please enter the user's e-mail address"
						read usermail
						echo -e "E-mail= $usermail" >> $TACLOG
						echo " Please enter the user's full name"
						read fullname
						echo -e "Name= $fullname" >> $TACLOG
						echo " Your current entries are:"
						echo -e " $username, $usermail, and $fullname"
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
  							read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					echo -e "Add user cancelled" >> $TACLOG
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					echo "Initiating tacuser.sh, breaking log" >> $TACLOG
							echo "<-------------LOG-BREAK-------------->" >> $TACLOG
		  					/opt/bin/tacuser -u $username -p $password -e $usermail -n $fullname
							echo "<-------------BREAK-END-------------->" >> $TACLOG
		  				fi
		  			done
					;;
				3) #This case will delete users based on input
					until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "Delete user initiated" >> $TACLOG
						echo " You have chosen to delete a user."
						echo " Please enter their username"
						read username
						echo -e "Username= $username" >> $TACLOG
						echo " Please enter the user's e-mail address"
						read usermail
						echo -e "E-mail= $usermail" >> $TACLOG
						echo " Please enter the user's full name"
						read fullname
						echo -e "Name= $fullname" >> $TACLOG
						echo " Your current entries are:"
						echo -e " $username, $usermail, and $fullname"
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
  							read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					echo -e "Delete user cancelled" >> $TACLOG
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					echo "Initiating tacdelete.sh, breaking log" >> $TACLOG
							echo "<-------------LOG-BREAK-------------->" >> $TACLOG
		  					/opt/bin/tacdelete -u $username -e $usermail -n $fullname
		  					echo "<-------------BREAK-END-------------->" >> $TACLOG
		  				fi
		  				if ! /opt/bin/tacdelete ; then
		  					echo " !!!ERROR!!!"
		  					echo ""
		  					read -p "Press enter to continue"
		  				fi
		  			done
					;;
				[Qq]) break
					;;
			esac
			;;
		2) #This case will allow you to interact with the Logs and Backups menu
			clear
			yn=""
			echo "========================================================================================="
			echo "                                 Twotac Logs and Backups                                 "
			echo "========================================================================================="
			echo " Available commands:"
			echo " To view logs,                          enter 1"
			echo " To run a backup,                       enter 2"
			echo " To view a list of backups,             enter 3"
			echo " To exit this interface,                enter Q"
			echo ""
			echo "====================================================="
			echo " Enter your selection"
			echo "====================================================="
			echo ""
			read answer
			case $answer in
				1) #This case shows logs and allows the user to view the content of individual logs
					until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
					echo -e "Viewed logs" >> $TACLOG
					clear
					echo "========================================================================================="
					echo "                                       Twotac Logs                                       "
					echo "========================================================================================="
					echo " (Weeks without activity will not be logged)"
					ls -gavA /var/log/taclogs/
					echo ""
					echo "====================================================="
					echo " Which log would you like to view? (Blank to go back)"
					echo "====================================================="
					echo ""
					read logsearch
					if ! [[ $logsearch ]]; then
						break
					fi
					cat /var/log/taclogs/$logsearch 2>/dev/null
					echo -e "Viewed /var/log/taclogs/$logsearch" >> $TACLOG
					echo ""
					echo ""
					echo "====================================================="
					echo " END OF LOG"
					echo "====================================================="
					echo ""
					echo ""
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
  						read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
						if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					break
		  				fi
					done
					;;
				2) #This case will run a backup
					echo -e "Running backup" >> $TACLOG
					/etc/cron.weekly/backup.sh 2>/dev/null
					echo "Backup ran successfully"
					echo ""
					read -p "Press enter to continue"
					;;
				3) #This case will show the user all the backups that have been stored in the backups folder.
					echo -e "Viewing backups" >> $TACLOG
					echo "========================================================================================="
					echo "                                     Twotac Backups                                      "
					echo "========================================================================================="
					echo " (Weeks without activity will not be logged)"
					echo ""
					echo ""
					ls -gavA /opt/tacbackups/
					echo ""
					echo ""
					echo ""
					echo "====================================================="
					echo " END OF LOG"
					echo "====================================================="
					echo ""
					read -p " Press Enter to Continue"
					;;
				[Qq] ) break
						;;
			esac
			;;
		3) #This case sets up the hardcoded placeholder variables and makes them functional scripts in context
		clear
		yn=""
			if [[ $CONFIGURED = true ]]; then
				echo "========================================================================================="
				echo "***Your changes have been saved!***"
			fi
		echo "========================================================================================="
		echo "                                    Twotac Management                                    "
		echo "========================================================================================="
		echo " Available commands:"
		echo " For a quick edit to all variables, enter A"
		echo " To edit the organization name,     enter 1"
		echo " To edit the website's hostname,    enter 2"
		echo " To edit the admin's mail address,  enter 3"
		echo " To configure your SMTP relay host, enter 4"
		echo " To configure your TACACS+ key,     enter 5"
		echo " To commit changes to memory,       enter C"
		echo " To exit,                           enter Q"
		#Checks if a file has been CONFIGURED using the $CONFIGURED variable
			if [[ $CONFIGURED = false ]]; then
				echo ""
				echo " **NOTE: IF YOU DO NOT COMMIT, CHANGES WILL NOT BE SAVED**"
			fi
		echo -e ""
		#If changes have been made in the form of $NEWVAR, it will appear before your selection
		if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
			echo "========================================================================================="
			echo "                                     Current Changes                                     "
			echo "========================================================================================="
			echo -e " Original#::::#New" >> /tmp/tacjunk
			if [[ $NEWORG ]]; then
				echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
			fi
			if [[ $NEWWEB ]]; then
				echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
			fi
			if [[ $NEWMAIL ]]; then
				echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
			fi
			if [[ $NEWSMTP ]]; then
				echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
			fi
			if [[ $NEWKEY ]]; then
				echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
			fi
			cat /tmp/tacjunk | column -t -s '#'
			rm /tmp/tacjunk
		fi
		echo "====================================================="
		echo " Enter your selection"
		echo "====================================================="
		echo ""
		read answer
		case $answer in
			[Aa] ) #This case changes all settings in order, allowing reviews at the end before committing changes
					until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "========================================================================================="
						echo "                                    Organization Name                                    "
						echo "========================================================================================="
						echo -e " Currently, the organization name is $ORG \n What would you like to change it to?"
							if [[ $NEWORG ]]; then
								echo -e "The current replacement is $NEWORG"
							fi
						echo ""
						read TEMPORG
						echo ""
						echo " $TEMPORG will be your new organization name"
						yn=""
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
  							read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					NEWORG="$TEMPORG"
		  					echo "$ORG \t::::\t $NEWORG" >> $TACLOG
		  					CONFIGURED=false
		  				fi
					done
					if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
						yn="n"
			 		until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "========================================================================================="
						echo "                                      Web Host Name                                      "
						echo "========================================================================================="
						echo -e " Currently, the website's hostname is $WEB \n What would you like to change it to?"
						echo " NOTE: If you would like to make this site https, include it in the hostname"
						echo " Example format: https://tacacs.com     (do not leave a trailing /)"
							if [[ $NEWWEB ]]; then
								echo -e "The current replacement is $NEWWEB"
							fi
						echo ""
						read TEMPWEB
						echo ""
						echo " $TEMPWEB will be your new host address"
						yn=""
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  					read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
								echo " That output doesn't register, please try again."
							fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					NEWWEB="$TEMPWEB"
		  					echo "$WEB \t::::\t $NEWWEB" >> $TACLOG
		  					CONFIGURED=false
		  				fi
					done
				fi
				if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
					yn="n"
			 		until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "========================================================================================="
						echo "                                   Administrator Mail                                    "
						echo "========================================================================================="
						echo -e " Currently, the admin's mail address is $MAIL \n What would you like to change it to?"
							if [[ $NEWMAIL ]]; then
								echo -e "The current replacement is $NEWMAIL"
							fi
						echo ""
						read TEMPMAIL
						echo ""
						echo " $TEMPMAIL will be your new admin's e-mail"
						yn=""
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  					read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
								echo " That output doesn't register, please try again."
							fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					NEWMAIL="$TEMPMAIL"
		  					echo "$MAIL \t::::\t $NEWMAIL" >> $TACLOG
		  					CONFIGURED=false
		  				fi
					done
				fi
				if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
					yn="n"
			 		until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "========================================================================================="
						echo "                                     SMTP Relay Host                                     "
						echo "========================================================================================="
						echo -e " Currently, the SMTP host is $SMTP \n What would you like to change it to?"
						echo " Example: smtp.gmail.com     (or your organization's smtp server address)"
							if [[ $NEWSMTP ]]; then
								echo -e "The current replacement is $NEWSMTP"
							fi
						echo ""
						read TEMPSMTP
						echo ""
						echo " $TEMPSMTP will be your new SMTP host"
						yn=""
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  					read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
								echo " That output doesn't register, please try again."
							fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					NEWSMTP="$TEMPSMTP"
		  					echo "$SMTP \t::::\t $NEWSMTP" >> $TACLOG
		  					CONFIGURED=false
		  				fi
					done
				fi
				if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
					yn="n"
			 		until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
						echo "========================================================================================="
						echo "                                       TACACS+ Key                                       "
						echo "========================================================================================="
						echo -e " Currently, the TACACS+ key is $KEY \n What would you like to change it to?"
						echo " ***WARNING, YOU WILL NEED TO CHANGE ALL ROUTER CONFIGS TO MATCH THE NEW ONE***"
							if [[ $NEWKEY ]]; then
								echo -e "The current replacement is $NEWKEY"
							fi
						echo ""
						read TEMPKEY
						echo ""			
						echo " $TEMPKEY is your new TACACS+ key. If your routers don't match, they will be inaccessible"
						yn=""
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
							echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  					read yn
							if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
								echo " That output doesn't register, please try again."
							fi
		  				done
		  				if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					NEWKEY="$TEMPKEY"
		  					echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
		  					CONFIGURED=false
		  				fi
					done
				fi
				if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
					yn="n"
			   		clear
					if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
					echo "========================================================================================="
					echo "                                   Configuration Changes                                 "
					echo "========================================================================================="
					echo -e " Original#::::#New" >> /tmp/tacjunk
					if [[ $NEWORG ]]; then
						echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
					fi
					if [[ $NEWWEB ]]; then
						echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
					fi
					if [[ $NEWMAIL ]]; then
						echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
					fi
					if [[ $NEWSMTP ]]; then
						echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
					fi
					if [[ $NEWKEY ]]; then
						echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
					fi
					cat /tmp/tacjunk | column -t -s '#'
					rm /tmp/tacjunk
					fi
					echo ""
					read -p " Are you certain you want to commit these changes? There will be no way to undo them. (yes/no)" yn
		    	case $yn in
		       		[Yy]* )
						if [[ $NEWORG ]]; then
							echo "$NEWORG COMMITTED" >> $TACLOG
							sed -i "s/$ORG/$NEWORG/g" $FILES
							NEWORG=""
							fi
						if [[ $NEWWEB ]]; then
							echo "$NEWWEB COMMITTED" >> $TACLOG
							sed -i "s/$WEB/$NEWWEB/g" $FILES
							NEWWEB=""
							fi
						if [[ $NEWMAIL ]]; then
							echo "$NEWMAIL COMMITTED" >> $TACLOG
							sed -i "s/$MAIL/$NEWMAIL/g" $FILES
							NEWMAIL=""
							fi
						if [[ $NEWSMTP ]]; then
							echo "$NEWSMTP COMMITTED" >> $TACLOG
							sed -i "s/$SMTP/$NEWSMTP/g" $FILES
							NEWSMTP=""
							fi
						if [[ $NEWKEY ]]; then
							echo "$NEWKEY COMMITTED" >> $TACLOG
							sed -i "s/$KEY/$NEWKEY/g" $FILES
							NEWKEY=""
							fi
						CONFIGURED=true
						;;
					[Nn]* ) continue
						;;
		    	esac
		    	fi
				;;
			1) #This case will change the organization name
				until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
					clear
					if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
						echo "========================================================================================="
						echo "                                     Current Changes                                     "
						echo "========================================================================================="
						echo -e " Original#::::#New" >> /tmp/tacjunk
						if [[ $NEWORG ]]; then
							echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
						fi
						if [[ $NEWWEB ]]; then
							echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
						fi
						if [[ $NEWMAIL ]]; then
							echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
						fi
						if [[ $NEWSMTP ]]; then
							echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
						fi
						if [[ $NEWKEY ]]; then
							echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
						fi
						cat /tmp/tacjunk | column -t -s '#'
						rm /tmp/tacjunk
					fi
					echo "========================================================================================="
					echo "                                    Organization Name                                    "
					echo "========================================================================================="
					echo -e " Currently, the organization name is $ORG \n What would you like to change it to?"
						if [[ $NEWORG ]]; then
							echo -e "The current replacement is $NEWORG"
						fi
					echo ""
					read TEMPORG
					echo ""
					echo " $TEMPORG will be your new organization name"
					yn=""
					until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
		  			done
		  			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  				break
		  			fi
		  			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  				NEWORG="$TEMPORG"
		  				echo "$ORG \t::::\t $NEWORG" >> $TACLOG
		  				CONFIGURED=false
		  			fi
				done
				;;
			2) #This case will adjust the hostname. Note the format should be http://hostname.com without trailng slashes.
				until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
					clear
					if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
						echo "========================================================================================="
						echo "                                     Current Changes                                     "
						echo "========================================================================================="
						echo -e " Original#::::#New" >> /tmp/tacjunk
						if [[ $NEWORG ]]; then
							echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
						fi
						if [[ $NEWWEB ]]; then
							echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
						fi
						if [[ $NEWMAIL ]]; then
							echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
						fi
						if [[ $NEWSMTP ]]; then
							echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
						fi
						if [[ $NEWKEY ]]; then
							echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
						fi
						cat /tmp/tacjunk | column -t -s '#'
						rm /tmp/tacjunk
					fi
					echo "========================================================================================="
					echo "                                      Web Host Name                                      "
					echo "========================================================================================="
					echo -e " Currently, the website's hostname is $WEB \n What would you like to change it to?"
					echo " NOTE: If you would like to make this site https, include it in the hostname"
					echo " Example format: https://tacacs.com     (do not leave a trailing /)"
						if [[ $NEWWEB ]]; then
							echo -e "The current replacement is $NEWWEB"
						fi
					echo ""
					read TEMPWEB
					echo ""
					echo " $TEMPWEB will be your new host address"
					yn=""
					until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
					done
		  			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  				break
		  			fi
		  			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  				NEWWEB="$TEMPWEB"
		  				echo "$WEB \t::::\t $NEWWEB" >> $TACLOG
		  				CONFIGURED=false
		  			fi
				done
						;;
			3) #This case adjusts the administrator who will typically run the mail system and receive copy of all sent mail
				until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
					clear
					if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
						echo "========================================================================================="
						echo "                                     Current Changes                                     "
						echo "========================================================================================="
						echo -e " Original#::::#New" >> /tmp/tacjunk
						if [[ $NEWORG ]]; then
							echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
						fi
						if [[ $NEWWEB ]]; then
							echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
						fi
						if [[ $NEWMAIL ]]; then
							echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
						fi
						if [[ $NEWSMTP ]]; then
							echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
						fi
						if [[ $NEWKEY ]]; then
							echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
						fi
						cat /tmp/tacjunk | column -t -s '#'
						rm /tmp/tacjunk
					fi
					echo "========================================================================================="
					echo "                                   Administrator Mail                                    "
					echo "========================================================================================="
					echo -e " Currently, the admin's mail address is $MAIL \n What would you like to change it to?"
						if [[ $NEWMAIL ]]; then
							echo -e "The current replacement is $NEWMAIL"
						fi
					echo ""
					read TEMPMAIL
					echo ""
					echo " $TEMPMAIL will be your new admin's e-mail"
					yn=""
					until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
					done
		  			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  				break
		  			fi
		  			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  				NEWMAIL="$TEMPMAIL"
		  				echo "$MAIL \t::::\t $NEWMAIL" >> $TACLOG
		  				CONFIGURED=false
		  			fi
				done
						;;
			4) #This case will attempt to configure SMTP for further use, but postfix may require more direct configuration
				until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
					clear
					if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
						echo "========================================================================================="
						echo "                                     Current Changes                                     "
						echo "========================================================================================="
						echo -e " Original#::::#New" >> /tmp/tacjunk
						if [[ $NEWORG ]]; then
							echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
						fi
						if [[ $NEWWEB ]]; then
							echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
						fi
						if [[ $NEWMAIL ]]; then
							echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
						fi
						if [[ $NEWSMTP ]]; then
							echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
						fi
						if [[ $NEWKEY ]]; then
							echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
						fi
						cat /tmp/tacjunk | column -t -s '#'
						rm /tmp/tacjunk
					fi
					echo "========================================================================================="
					echo "                                     SMTP Relay Host                                     "
					echo "========================================================================================="
					echo -e " Currently, the SMTP host is $SMTP \n What would you like to change it to?"
						if [[ $NEWSMTP ]]; then
							echo -e "The current replacement is $NEWSMTP"
						fi
					echo ""
					read TEMPSMTP
					echo ""
					echo " $TEMPSMTP will be your new SMTP host"
					yn=""
					until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
					done
		  			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  				break
		  			fi
		  			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  				NEWSMTP="$TEMPSMTP"
		  				echo "$SMTP \t::::\t $NEWSMTP" >> $TACLOG
		  				CONFIGURED=false
		  			fi
				done
						;;
			5) #This will change the Tacacs+ key, which will require reconfiguration of network devices to be functional
				until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
					clear
					if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
						echo "========================================================================================="
						echo "                                     Current Changes                                     "
						echo "========================================================================================="
						echo -e " Original#::::#New" >> /tmp/tacjunk
						if [[ $NEWORG ]]; then
							echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
						fi
						if [[ $NEWWEB ]]; then
							echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
						fi
						if [[ $NEWMAIL ]]; then
							echo -e " $MAIL#::::#$NEWMAIL" >> /tmp/tacjunk
						fi
						if [[ $NEWSMTP ]]; then
							echo -e " $SMTP#::::#$NEWSMTP" >> /tmp/tacjunk
						fi
						if [[ $NEWKEY ]]; then
							echo -e " $KEY#::::#$NEWKEY" >> /tmp/tacjunk
						fi
						cat /tmp/tacjunk | column -t -s '#'
						rm /tmp/tacjunk
					fi
					echo "========================================================================================="
					echo "                                       TACACS+ Key                                       "
					echo "========================================================================================="
					echo -e " Currently, the TACACS+ key is $KEY \n What would you like to change it to?"
					echo " ***WARNING, YOU WILL NEED TO CHANGE ALL ROUTER CONFIGS TO MATCH THE NEW ONE***"
						if [[ $NEWKEY ]]; then
							echo -e "The current replacement is $NEWKEY"
						fi
					echo ""
					read TEMPKEY
					echo ""			
					echo " $TEMPKEY is your new TACACS+ key. If your routers don't match, they will be inaccessible"
					yn=""
					until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
					done
		  			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  				break
		  			fi
		  			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  				NEWKEY="$TEMPKEY"
		  				echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
		  				CONFIGURED=false
		  			fi
				done
						;;
			[Cc] ) #This case will take $NEWVAR and overwrite $VAR
					read -p "Are you certain you want to commit these changes? There will be no way to undo them. (yes/no)" yn
		    		case $yn in
		        		[Yy]* )
							if [[ $NEWORG ]]; then
								echo "$NEWORG COMMITTED" >> $TACLOG
								sed -i "s/$ORG/$NEWORG/g" $FILES
								NEWORG=""
								fi
		
							if [[ $NEWWEB ]]; then
								echo "$NEWWEB COMMITTED" >> $TACLOG
								sed -i "s/$WEB/$NEWWEB/g" $FILES
								NEWWEB=""
								fi
		
							if [[ $NEWMAIL ]]; then
								echo "$NEWMAIL COMMITTED" >> $TACLOG
								sed -i "s/$MAIL/$NEWMAIL/g" $FILES
								NEWMAIL=""
								fi
		
							if [[ $NEWSMTP ]]; then
								echo "$NEWSMTP COMMITTED" >> $TACLOG
								sed -i "s/$SMTP/$NEWSMTP/g" $FILES
								NEWSMTP=""
								fi
		
							if [[ $NEWKEY ]]; then
								echo "$NEWKEY COMMITTED" >> $TACLOG
								sed -i "s/$KEY/$NEWKEY/g" $FILES
								NEWKEY=""
								fi
							CONFIGURED=true
							;;
						[Nn]* ) continue
							;;
		    		esac
					;;
			[Qq] ) continue
					;;
		esac
		;;

	4) #This case enters the user management interface
		clear
		yn=""
		echo "========================================================================================="
		echo "                                  Twotac Configurations                                  "
		echo "========================================================================================="
		echo " Available commands:"
		echo " To view or edit current configs,       enter 1"
		echo " To overwrite existing configs,         enter 2"
		echo " To exit this interface,                enter Q"
		echo ""
		echo "====================================================="
		echo " Enter your selection"
		echo "====================================================="
		echo ""
		read answer
		case $answer in
			1) #This case shows logs and allows the user to view the content of individual logs
				until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
				clear
				echo "========================================================================================="
				echo "                                      View Configs                                       "
				echo "========================================================================================="
				echo ""
				echo " Which config would you like to view?"
				echo " For the tacacs+ config,                enter 1"
				echo " For the postfix config,                enter 2"
				echo " For the pam config,                    enter 3"
				echo " To view default twotac configs,        enter 4"
				echo " To exit this interface,                enter Q"
				echo ""
				echo "====================================================="
				echo " Enter your selection"
				echo "====================================================="
				echo ""
				read answer
				case $answer in
					1) #This case views the tacacs+ config
						clear
						cat /etc/tacacs+/tac_plus.conf
						echo ""
						echo ""
						echo "Would you like to edit this file? (y/n)"
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
						done
		  				if [[ "$yn" =~ ^[Nn](o)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					nano /etc/tacacs+/tac_plus.conf
		  				fi
		  				;;
		  			2) #This case views the postfix config
						clear
						cat /etc/postfix/main.cf
						echo ""
						echo ""
						echo "Would you like to edit this file? (y/n)"
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
						done
		  				if [[ "$yn" =~ ^[Nn](o)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					nano /etc/postfix/main.cf
		  				fi
		  				;;
		  			3) #This case views the pam config
						clear
						cat /etc/pam.d/tac_plus
						echo ""
						echo ""
						echo "Would you like to edit this file? (y/n)"
						until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
						done
		  				if [[ "$yn" =~ ^[Nn](o)?$ ]]; then
		  					break
		  				fi
		  				if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  					nano /etc/pam.d/tac_plus
		  				fi
		  				;;
		  			4) #This case views all default twotac configs
						echo ""
						echo ""
						echo "====================================================="
						echo "Twotac default tacacs+ configuration"
						echo "====================================================="
						cat /opt/tacconfigs/tacacs+/tac_plus.conf
						echo ""
						echo ""
						echo "====================================================="
						echo "Twotac default postfix configuration"
						echo "====================================================="
						cat /opt/tacconfigs/postfix/main.cf
						echo ""
						echo ""
						echo "====================================================="
						echo "Twotac default pam configuration"
						echo "====================================================="
						cat /opt/tacconfigs/pam/tac_plus
						echo ""
						echo ""
						read -r "Press enter to continue"
						;;
		  			esac
		  		done
		  		;;
			2) #This case will overwrite standard configurations with the default twotac configuration
				clear
				yn=""
				echo "========================================================================================="
				echo "                                  Twotac Configurations                                  "
				echo "========================================================================================="
				echo ""
				echo "Checking for installed files..."
				if [[ /etc/tacacs+/tac_plus.conf ]]; then 
					tacacs="tacacs" 
				else 
					tacacs="" 
				fi
				if [[ /etc/postfix/main.cf ]]; then 
					postfix="postfix" 
				else 
					postfix="" 
				fi
				if [[ /etc/pam.d/tac_plus ]]; then 
					pam="pam" 
				else 
					pam="" 
				fi
				if [[ /etc/apache2/apache2.conf ]]; then 
					apache2="apache2" 
				else 
					apache2="" 
				fi
				if [[ $tacacs ]] || [[ $postfix ]] || [[ $pam ]]; then
					echo ""
					echo "It looks like these configurations are available to overwrite"
					if [[ $tacacs ]]; then 
						echo -e "$tacacs"
					fi
					if [[ $postfix ]]; then 
						echo -e "$postfix"
					fi
					if [[ $pam ]]; then 
						echo -e "$pam"
					fi
					echo ""
					echo ""
					echo "Would you like to overwrite your standard configurations for the twotac default configuration?"
					until [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; do
						echo " Would you like to continue? \"No\" will restart this section (y/n/c)"
		  				read yn
						if ! [[ "$yn" =~ ^[Yy](es)?$ ]] || [[ "$yn" =~ ^[Cc](ancel)?$ ]] || [[ "$yn" =~ ^[Nn](o)?$ ]]; then
							echo " That output doesn't register, please try again."
						fi
					done
		  			if [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
		  				break
		  			fi
		  			if [[ "$yn" =~ ^[Yy](es)?$ ]]; then
		  				NEWKEY="$TEMPKEY"
		  				echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
		  				CONFIGURED=false
					if [[ $tacacs ]]; then
						tacacs=$(cat /opt/tacconfigs/tacacs+/tac_plus.conf)
						sudo echo "" > /etc/tacacs+/tac_plus.conf
						sudo echo "$tacacs" >> /etc/tacacs+/tac_plus.conf
					fi
					if [[ $postfix ]]; then
						postfix=$(cat /opt/tacconfigs/postfix/main.cf)
						sudo echo "" > /etc/postfix/main.cf
						sudo echo "$postfix" >> /etc/postfix/main.cf
					fi
					if [[ $pam ]]; then
						pam=$(cat /opt/tacconfigs/pam.d/tac_plus)
						sudo echo "" > /etc/pam.d/tac_plus
						sudo echo "$pam" >> /etc/pam.d/tac_plus
					fi
					fi
					echo ""
					echo ""
					if ! [[ $apache2 ]] && [[ $tacacs ]] && [[ $postfix ]] && [[ $pam ]]; then
						echo "Some dependencies still aren't installed"
						echo "Please install"
						if ! [[ $tacacs ]]; then 
							echo -e "tacacs"
						fi
						if ! [[ $postfix ]]; then 
							echo -e "postfix"
						fi
						if ! [[ $pam ]]; then 
							echo -e "pam"
						fi
						if ! [[ $apache2 ]]; then 
							echo -e "apache2"
						fi
					fi
				else
					echo "It doesn't look like any dependencies are installed."
					echo "Please install"
					if ! [[ $tacacs ]]; then 
						echo -e "tacacs"
					fi
					if ! [[ $postfix ]]; then 
						echo -e "postfix"
					fi
					if ! [[ $pam ]]; then 
						echo -e "pam"
					fi
					if ! [[ $apache2 ]]; then 
						echo -e "apache2"
					fi
					echo "This software will not work as intended until you do."
				fi
				;;

			[Qq] ) break
					;;
				esac
				;;
	
	[Qq] ) echo "<--------------END-LOG--------------->" >> $TACLOG
			echo "" >> $TACLOG
			clear
			exit 
			;;
	esac
done