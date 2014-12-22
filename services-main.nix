{pkgs, config, ...}:
{
    httpd = import /etc/nixos/configurations/misc/raskin/httpd.nix {inherit pkgs config;};
    bind = import /etc/nixos/configurations/misc/raskin/bind.nix {inherit pkgs config;};

    openssh = {
      enable = true;
      extraConfig = ''
        VersionAddendum raskin.401a0bf1.ignorelist.com
      '';
    };


    ntp = {
	# Not a good idea unless you sync however else.
	# But I keep my clock ahead by 7 minutes.
      enable = false;															
    };
    samba = {
      enable = true;
      extraConfig = ''
      '';
    };
    gogoclient = {
      enable = true;

	# I failed to make tunnel really reliable with
	# double NAT, so I just have a script to control 
	# it. Works in some other places, though.
      autorun = false;																
      
      username = (import /root/nix-sysconfig/gw6c.nix).new_freenet6.username;
      password = "/root/nix-sysconfig/gw6c.pass";
      server   = (import /root/nix-sysconfig/gw6c.nix).new_freenet6.server;
    };
    postgresql = (import ./postgresql.nix) {inherit pkgs;};
    mysql = {
      enable=true;
      package = pkgs.mysql55;
    };
    udev = {
    };
    locate = {
      enable = true;
    };
    ejabberd = {
      enable = true;
      virtualHosts = "\"localhost\", \"401a0bf1.ignorelist.com\"";
    };
    vsftpd = {
      enable = true;
      anonymousUser = true;
      anonymousUserHome = "/home/ftp/";
      writeEnable = true;
      anonymousMkdirEnable = true;
      anonymousUploadEnable = true;
      anonymousUmask = "0002";
      #rsaCertFile="/var/certs/www/host.cert";
      #sslEnable = false;
    };
    printing = {
      enable = true;
      drivers = [pkgs.hplip pkgs.foo2zjs pkgs.foomatic_filters 
		];
    };
    mingetty = {
      helpLine = ''
      0123456789 !@#$%^&*() -=\_+|
      abcdefghijklmnopqrstuvwxyz
      ABCDEFGHIJKLMNOPQRSTUVWXYZ
      []{};:'",./<>?~`
      '';
    };
    gpm = {
      enable = true;
    };
    postfix = {
      enable = true;
      domain = "${config.networking.hostName}.${config.networking.domain}";
      sslCert = /var/certs/smtp/postfix.pem;
      sslCACert = /var/certs/ca-cert.pem;
      sslKey = /var/certs/smtp/postfix.key;
      recipientDelimiter = "+";
    };

    cron = {
      systemCronJobs = [
#	in local time
	"44 4 * * * root [ -e /dev/sdb5 ] && ! [ -d /media/sdb5 ] && pmount /dev/sdb5 && ([ -f /media/sdb5/backup/auto-backup-here ] && backup_notebook /media/sdb5/backup ; ) ; sync && pumount /dev/sdb5 "
	"29 4 * * * root [ -e /dev/sdb1 ] && ! [ -d /media/sdb1 ] && pmount /dev/sdb1 && ([ -f /media/sdb1/backup/auto-backup-here ] && backup_notebook /media/sdb1/backup ; ) ; sync && pumount /dev/sdb1 "
	"14 4 * * * root sh -c 'PATH=$PATH:/root/script/; ensure-nas-backup-mount ; mount; ls /tmp/backup/backup ; [ -f /tmp/backup/backup/auto-backup-here ] ; echo $? ; ([ -f /tmp/backup/backup/auto-backup-here ] && /root/script/backup_notebook /tmp/backup/backup ; sync ) && umount /tmp/backup' &> /var/log/nas-backup.log"
	"5-59/30 * * * * root cd /root && nice -n 10 ionice -c 3 /home/raskin/script/mtn-pending-changes > /root/.mtn-pending-changes"
	"0-59/30 * * * * raskin export PATH=$PATH:/home/raskin/script ; cd /home/raskin && nice -n 10 ionice -c 3 mtn-pending-changes > /home/raskin/.mtn-pending-changes; cd rc && kill-gajim-passwords && purge-from-pending"
	"30 5 * * * root /var/run/current-system/sw/bin/nix-instantiate /home/raskin/.nix-personal/personal.nix"
	"45 5 * * * raskin cd /home/raskin && /home/raskin/script/dev-sync && /home/raskin/script/public-sync && /home/raskin/script/gh-sync"
##	in UTC
#	"44 0 * * * root [ -e /dev/sdb5 ] && ! [ -d /media/sdb5 ] && pmount /dev/sdb5 && ([ -f /media/sdb5/backup/auto-backup-here ] && backup_notebook /media/sdb5/backup ; ) ; sync && pumount /dev/sdb5 "
#	"29 0 * * * root [ -e /dev/sdb1 ] && ! [ -d /media/sdb1 ] && pmount /dev/sdb1 && ([ -f /media/sdb1/backup/auto-backup-here ] && backup_notebook /media/sdb1/backup ; ) ; sync && pumount /dev/sdb1 "
#	"14 0 * * * root sh -c 'PATH=$PATH:/root/script/; ensure-nas-backup-mount ; mount; ls /tmp/backup/backup ; [ -f /tmp/backup/backup/auto-backup-here ] ; echo $? ; ([ -f /tmp/backup/backup/auto-backup-here ] && /root/script/backup_notebook /tmp/backup/backup ; sync ) && umount /tmp/backup' &> /var/log/nas-backup.log"
#	"5-59/15 * * * * root cd /root && nice -n 10 ionice -c 3 /home/raskin/script/mtn-pending-changes > /root/.mtn-pending-changes"
#	"0-59/15 * * * * raskin export PATH=$PATH:/home/raskin/script ; cd /home/raskin && nice -n 10 ionice -c 3 mtn-pending-changes > /home/raskin/.mtn-pending-changes; cd rc && kill-gajim-passwords && purge-from-pending"
#	"30 1 * * * root /var/run/current-system/sw/bin/nix-instantiate /home/raskin/.nix-personal/personal.nix"
#	"45 1 * * * raskin cd /home/raskin && /home/raskin/script/dev-sync && /home/raskin/script/public-sync && /home/raskin/script/gh-sync"
      ];
    };
    
    atd = {
      allowEveryone = true;
    };

    nixosManual.enable = false;

    avahi = {
      enable = true;
      hostName = "401a0bf1";
    };

    nfs = {
      server = {
        enable = true;
	exports = ''
	  /var/nfs *(ro,insecure,all_squash)
	'';
      };
    };

    logind.extraConfig=''
      HandleLidSwitch=ignore
      HandlePowerKey=ignore
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandlePowerKey=ignore
    '';

    nscd.enable = false;
}