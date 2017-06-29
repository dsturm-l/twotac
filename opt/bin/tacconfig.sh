#!/bin/bash
#Files variable may need work and may need to automatically gather file names/paths from a function
DIR=$(find /opt/bin/ /var/www/html/ /etc/tacacs+/ /etc/postfix/ -type f)
FILES="$DIR"
TACLOG="/opt/bin/taclog"
CONFIGURED=false
#This is where the current variables will be stored NOTE CHANGE TO /OPT/BIN/TAC.CONF WHEN TESTING IS OVER
trap '' 2
echo "<----`date`---->" >> $TACLOG
echo "Twotac Management" >> $TACLOG
while true
do
	source tac.conf
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
		echo "=====================================================" >> /tmp/tacjunk
		echo "                   Current Changes                   " >> /tmp/tacjunk
		echo "=====================================================" >> /tmp/tacjunk
		echo -e " Original#::::#New" >> /tmp/tacjunk
		if [[ $NEWORG ]]; then
			echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
		fi
		if [[ $NEWWEB ]]; then
			echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
		fi
		if [[ $NEWMAIL ]]; then
			echo -e " $MAIL#::::#NEWMAIL" >> /tmp/tacjunk
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
	echo "Enter your selection"
	echo "====================================================="
	echo ""
	read answer
	case $answer in
		[Aa] ) 	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
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
	  				else
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
	  				else
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
	  				else
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
	  				else
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
	  				else
	  					NEWKEY="$TEMPKEY"
	  					echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
	  					CONFIGURED=false
	  				fi
				done
			fi
			if ! [[ "$yn" =~ ^[Cc](ancel)?$ ]]; then
				yn="n"
		   		clear
				echo "====================================================="
				echo "                   Current Changes                   "
				echo "====================================================="
				echo -e " Original    \t\t::::\t    New"
				echo -e " $ORG    \t::::\t    $NEWORG"
				echo -e " $WEB    \t::::\t    $NEWWEB"
				echo -e " $MAIL    \t::::\t    $NEWMAIL"
				echo -e " $SMTP    \t::::\t    $NEWSMTP"
				echo -e " $KEY    \t::::\t    $NEWKEY"
				echo "====================================================="
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
		1) 	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
				clear
				if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
					echo "=====================================================" >> /tmp/tacjunk
					echo "                   Current Changes                   " >> /tmp/tacjunk
					echo "=====================================================" >> /tmp/tacjunk
					echo -e " Original#::::#New" >> /tmp/tacjunk
					if [[ $NEWORG ]]; then
						echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
					fi
					if [[ $NEWWEB ]]; then
						echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
					fi
					if [[ $NEWMAIL ]]; then
						echo -e " $MAIL#::::#NEWMAIL" >> /tmp/tacjunk
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
	  			else
	  				NEWORG="$TEMPORG"
	  				echo "$ORG \t::::\t $NEWORG" >> $TACLOG
	  				CONFIGURED=false
	  			fi
			done
					;;
		2) 	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
				clear
				if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
					echo "=====================================================" >> /tmp/tacjunk
					echo "                   Current Changes                   " >> /tmp/tacjunk
					echo "=====================================================" >> /tmp/tacjunk
					echo -e " Original#::::#New" >> /tmp/tacjunk
					if [[ $NEWORG ]]; then
						echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
					fi
					if [[ $NEWWEB ]]; then
						echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
					fi
					if [[ $NEWMAIL ]]; then
						echo -e " $MAIL#::::#NEWMAIL" >> /tmp/tacjunk
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
	  			else
	  				NEWWEB="$TEMPWEB"
	  				echo "$WEB \t::::\t $NEWWEB" >> $TACLOG
	  				CONFIGURED=false
	  			fi
			done
					;;
		3) 	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
				clear
				if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
					echo "=====================================================" >> /tmp/tacjunk
					echo "                   Current Changes                   " >> /tmp/tacjunk
					echo "=====================================================" >> /tmp/tacjunk
					echo -e " Original#::::#New" >> /tmp/tacjunk
					if [[ $NEWORG ]]; then
						echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
					fi
					if [[ $NEWWEB ]]; then
						echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
					fi
					if [[ $NEWMAIL ]]; then
						echo -e " $MAIL#::::#NEWMAIL" >> /tmp/tacjunk
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
	  			else
	  				NEWMAIL="$TEMPMAIL"
	  				echo "$MAIL \t::::\t $NEWMAIL" >> $TACLOG
	  				CONFIGURED=false
	  			fi
			done
					;;
		4) 	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
				clear
				if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
					echo "=====================================================" >> /tmp/tacjunk
					echo "                   Current Changes                   " >> /tmp/tacjunk
					echo "=====================================================" >> /tmp/tacjunk
					echo -e " Original#::::#New" >> /tmp/tacjunk
					if [[ $NEWORG ]]; then
						echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
					fi
					if [[ $NEWWEB ]]; then
						echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
					fi
					if [[ $NEWMAIL ]]; then
						echo -e " $MAIL#::::#NEWMAIL" >> /tmp/tacjunk
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
	  			else
	  				NEWSMTP="$TEMPSMTP"
	  				echo "$SMTP \t::::\t $NEWSMTP" >> $TACLOG
	  				CONFIGURED=false
	  			fi
			done
					;;
		5) 	until [[ "$yn" =~ ^[Yy](es)?$ ]]; do
				clear
				if [[ $NEWORG ]] || [[ $NEWWEB ]] || [[ $NEWMAIL ]] || [[ $NEWSMTP ]] || [[ $NEWKEY ]]; then
					echo "=====================================================" >> /tmp/tacjunk
					echo "                   Current Changes                   " >> /tmp/tacjunk
					echo "=====================================================" >> /tmp/tacjunk
					echo -e " Original#::::#New" >> /tmp/tacjunk
					if [[ $NEWORG ]]; then
						echo -e " $ORG#::::#$NEWORG" >> /tmp/tacjunk
					fi
					if [[ $NEWWEB ]]; then
						echo -e " $WEB#::::#$NEWWEB" >> /tmp/tacjunk
					fi
					if [[ $NEWMAIL ]]; then
						echo -e " $MAIL#::::#NEWMAIL" >> /tmp/tacjunk
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
	  			else
	  				NEWKEY="$TEMPKEY"
	  				echo "$KEY \t::::\t $NEWKEY" >> $TACLOG
	  				CONFIGURED=false
	  			fi
			done
					;;
		[Cc] ) read -p "Are you certain you want to commit these changes? There will be no way to undo them. (yes/no)" yn
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
		[Qq] ) echo "<--------------END-LOG--------------->" >> $TACLOG
				clear
				exit 
				;;
	esac
done