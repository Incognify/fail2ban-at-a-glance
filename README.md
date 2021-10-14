# fail2ban-at-a-glance
Quickly check all available fail2ban jail statuses and recently banned IPs. Useful little tool for those with a lot of fail2ban jails and who are tired of checking their status individually.

Inspired by https://gist.github.com/kamermans/1076290 , all I did was add the recently banned IPs to the output and made the a repo for the little project. I'll probably add more to it as time goes on and I seek simple solutions to minor annoyances I'm experiencing. (Such as manually checking jails or logs for IP bans)

---

How to use:

`chmod 755 checkjails.sh`

`./checkjails.sh`

Boom. That's it.

---

Example output (IP's censored in the example, real world usage would show actual IP addresses):


```
####################
# Last 20 IP Bans: #
####################
2021-10-11 18:05:41,575 fail2ban.actions        [28354]: NOTICE  [nginx-noproxy] Ban 222.186.19.xxx
2021-10-11 22:26:30,830 fail2ban.actions        [28354]: NOTICE  [nginx-nohome] Ban 133.9.67.xxx
2021-10-11 22:44:44,688 fail2ban.observer       [28354]: INFO    [nginx-nohome] Found 133.9.67.xxx, bad - 2021-10-11 22:44:44, 1 # -> 2.0, Ban
2021-10-11 22:44:44,838 fail2ban.actions        [28354]: NOTICE  [nginx-nohome] Ban 133.9.67.xxx
2021-10-11 22:44:44,841 fail2ban.observer       [28354]: NOTICE  [nginx-nohome] Increase Ban 133.9.67.xxx (2 # 0:50:00 -> 2021-10-11 23:34:44)
2021-10-12 10:12:03,435 fail2ban.observer       [28354]: INFO    [nginx-nohome] Found 133.9.67.xxx, bad - 2021-10-12 10:12:02, 2 # -> 2, Ban
2021-10-12 10:12:03,436 fail2ban.observer       [28354]: INFO    [nginx-nohome] Found 133.9.67.xxx, bad - 2021-10-12 10:12:02, 2 # -> 2, Ban
2021-10-12 10:12:03,478 fail2ban.actions        [28354]: NOTICE  [nginx-nohome] Ban 133.9.67.xxx
2021-10-12 10:12:03,482 fail2ban.observer       [28354]: NOTICE  [nginx-nohome] Increase Ban 133.9.67.xxx (3 # 5:00:00 -> 2021-10-12 15:12:02)
2021-10-12 15:42:50,004 fail2ban.observer       [28354]: INFO    [nginx-nohome] Found 133.9.67.xxx, bad - 2021-10-12 15:42:49, 3 # -> 2, Ban
2021-10-12 15:42:50,006 fail2ban.observer       [28354]: INFO    [nginx-nohome] Found 133.9.67.xxx, bad - 2021-10-12 15:42:49, 3 # -> 2, Ban
2021-10-12 15:42:50,692 fail2ban.actions        [28354]: NOTICE  [nginx-nohome] Ban 133.9.67.xxx
2021-10-12 15:42:50,695 fail2ban.observer       [28354]: NOTICE  [nginx-nohome] Increase Ban 133.9.67.xxx (4 # 10:00:00 -> 2021-10-13 01:42:49)
2021-10-13 08:43:37,131 fail2ban.actions        [28354]: NOTICE  [nginx-noscript] Ban 118.123.1.xxx
2021-10-13 09:26:33,609 fail2ban.actions        [28354]: NOTICE  [nginx-noscript] Ban 118.123.1.xxx
2021-10-13 12:30:10,630 fail2ban.actions        [28354]: NOTICE  [nginx-noscript] Ban 139.59.98.xxx
2021-10-13 14:50:23,499 fail2ban.actions        [28354]: NOTICE  [nginx-noscript] Ban 165.22.107.xxx
2021-10-13 22:49:30,684 fail2ban.actions        [28354]: NOTICE  [nginx-noscript] Ban 100.25.158.xxx
##########################################
# Status Of All Enabled Fail2Ban Jails:  #
##########################################
Status for the jail: nginx-badbots
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/nginx/access.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	
Status for the jail: nginx-botsearch
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/nginx/error.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	
Status for the jail: nginx-http-auth
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/nginx/error.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	
Status for the jail: nginx-nohome
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	10
|  `- File list:	/var/log/nginx/access.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	4
   `- Banned IP list:	
Status for the jail: nginx-noproxy
|- Filter
|  |- Currently failed:	2
|  |- Total failed:	5
|  `- File list:	/var/log/nginx/access.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	1
   `- Banned IP list:	
Status for the jail: nginx-noscript
|- Filter
|  |- Currently failed:	6
|  |- Total failed:	193
|  `- File list:	/var/log/nginx/access.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	5
   `- Banned IP list:	
Status for the jail: php-url-fopen
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/nginx/host.access.log /var/log/nginx/access.log /var/log/apache2/other_vhosts_access.log /var/log/apache2/access.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	
Status for the jail: sshd
|- Filter
|  |- Currently failed:	0
|  |- Total failed:	0
|  `- File list:	/var/log/auth.log
`- Actions
   |- Currently banned:	0
   |- Total banned:	0
   `- Banned IP list:	

```
