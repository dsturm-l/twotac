#!/bin/bash
TACLOG="/var/log/twotac/taclog"
TACCONF="/etc/twotac/twotac.conf"
DATE=`date -u +%Y-%m-%dT%H:%MZ`
ALLFILES="/etc/twotac/twotac.conf /etc/apache2/ /etc/tacacs+/tac_plus.conf /etc/pam.d/tac_plus /etc/postfix/main.cf /etc/ssh/sshd_config /etc/cron.weekly/ /opt/bin/ /opt/tacbackups/ /opt/tacconfigs/ /opt/tacmail/ /var/www/html/ /var/log/taclogs/ /home/"
source $TACCONF
echo "Backup initiated" >> $TACLOG
if [[ $DOBACKUPS ]]; then
	echo "Running Backup" >> $TACLOG
	tar -zcvf "$BACKUPDIR""$DATE"tacbackups.tar.gz $ALLFILES
	$MAILDIR/mailbackup | mail -aFrom:$MAILER -s "Tacacs+ Backup" -A "$BACKUPDIR""$DATE"tacbackups.tar.gz $MAILER
else
	echo "Backups disabled by twotac.conf" >> $TACLOG
fi
