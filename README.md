# fail2ban-at-a-glance
Updated: 10/08/2023!

Description: Quickly check all available fail2ban jail statuses and recently banned IPs. Useful little tool for those with a lot of fail2ban jails and who are tired of checking their status individually. **NEW**: Menu driven navigation, IP unblocker.

---

How to use:

`chmod 755 checkjails.sh`

`./checkjails.sh`

Boom. That's it.

---


Example output (IP's partially censored in example only):


```
[you@yourserver ~]# ./checkjails.sh
1. Show last N IP bans
2. Show status of all enabled jails
3. Show bans for a specific jail
4. Unban an IP
5. Exit

```


```
[you@yourserver ~]# ./checkjails.sh
1. Show last N IP bans
2. Show status of all enabled jails
3. Show bans for a specific jail
4. Unban an IP
5. Exit
Choose an option: 1
How many last bans to display? 10
####################
# Last 10 IP Bans: #
####################
/var/log/fail2ban.log.2.gz:2023-09-30 23:31:59,632 fail2ban.actions        [3229217]: NOTICE  [sshd] Ban 123.58.204.x
/var/log/fail2ban.log.2.gz:2023-09-30 23:31:59,633 fail2ban.observer       [3229217]: NOTICE  [sshd] Increase Ban 123.58.204.x (2 # 7:57:25 -> 2023-10-01 07:29:23)
/var/log/fail2ban.log.2.gz:2023-09-30 23:33:27,953 fail2ban.actions        [3229217]: NOTICE  [sshd] Ban 82.156.125.x
/var/log/fail2ban.log.2.gz:2023-09-30 23:33:27,954 fail2ban.observer       [3229217]: NOTICE  [sshd] Increase Ban 82.156.125.x (2 # 9:24:44 -> 2023-10-01 08:58:11)
/var/log/fail2ban.log.2.gz:2023-09-30 23:37:13,464 fail2ban.actions        [3229217]: NOTICE  [sshd] Ban 211.112.187.x
/var/log/fail2ban.log.2.gz:2023-09-30 23:37:13,465 fail2ban.observer       [3229217]: NOTICE  [sshd] Increase Ban 211.112.187.x (3 # 7:43:33 -> 2023-10-01 07:20:46)
/var/log/fail2ban.log.2.gz:2023-09-30 23:40:59,572 fail2ban.actions        [3229217]: NOTICE  [sshd] Ban 185.239.106.x
/var/log/fail2ban.log.2.gz:2023-09-30 23:40:59,572 fail2ban.observer       [3229217]: NOTICE  [sshd] Increase Ban 185.239.106.x (2 # 7:05:21 -> 2023-10-01 06:46:20)
/var/log/fail2ban.log.2.gz:2023-09-30 23:41:36,241 fail2ban.actions        [3229217]: NOTICE  [sshd] Ban 43.154.143.x
/var/log/fail2ban.log.2.gz:2023-09-30 23:41:36,241 fail2ban.observer       [3229217]: NOTICE  [sshd] Increase Ban 43.154.143.x (2 # 9:09:40 -> 2023-10-01 08:51:15)
1. Show last N IP bans
2. Show status of all enabled jails
3. Show bans for a specific jail
4. Unban an IP
5. Exit
Choose an option: 2
##########################################
# Status Of All Enabled Fail2Ban Jails:  #
##########################################
Status for the jail: nginx-badbots
|- Filter
|  |- Currently failed: 0
|  |- Total failed:  0
|  `- File list:  /var/log/nginx/access.log
`- Actions
   |- Currently banned: 0
   |- Total banned:  0
   `- Banned IP list:   
Status for the jail: nginx-botsearch
|- Filter
|  |- Currently failed: 0
|  |- Total failed:  0
|  `- File list:  /var/log/nginx/error.log
`- Actions
   |- Currently banned: 0
   |- Total banned:  0
   `- Banned IP list:   
Status for the jail: nginx-http-auth
|- Filter
|  |- Currently failed: 0
|  |- Total failed:  0
|  `- File list:  /var/log/nginx/error.log
`- Actions
   |- Currently banned: 0
   |- Total banned:  0
   `- Banned IP list:   
Status for the jail: nginx-nohome
|- Filter
|  |- Currently failed: 0
|  |- Total failed:  10
|  `- File list:  /var/log/nginx/access.log
`- Actions
   |- Currently banned: 0
   |- Total banned:  4
   `- Banned IP list:   
Status for the jail: nginx-noproxy
|- Filter
|  |- Currently failed: 2
|  |- Total failed:  5
|  `- File list:  /var/log/nginx/access.log
`- Actions
   |- Currently banned: 0
   |- Total banned:  1
   `- Banned IP list:   
Status for the jail: nginx-noscript
|- Filter
|  |- Currently failed: 6
|  |- Total failed:  193
|  `- File list:  /var/log/nginx/access.log
`- Actions
   |- Currently banned: 0
   |- Total banned:  5
   `- Banned IP list:   
Status for the jail: sshd
|- Filter
|  |- Currently failed: 2
|  |- Total failed: 21512
|  `- File list:    /var/log/auth.log
`- Actions
   |- Currently banned: 31
   |- Total banned: 4067
   `- Banned IP list:   43.156.14.x 120.48.250.x 43.136.79.x 8.217.78.x 50.110.97.x 220.167.103.x 49.231.241.x 154.221.19.x 159.89.238.x 62.99.74.x 124.220.165.x 49.232.242.x 119.5.157.x 43.156.68.x 102.220.23.x 103.176.78.x 222.252.21.x 1.214.214.x 103.79.142.x 184.168.123.x 191.34.101.x 103.144.244.x 185.43.255.x 186.206.171.x 190.35.38.x 14.116.196.x 20.230.32.x 103.144.2.x 5.34.201.x 113.161.194.x 118.122.93.x
1. Show last N IP bans
2. Show status of all enabled jails
3. Show bans for a specific jail
4. Unban an IP
5. Exit
Choose an option: 5
Exiting.
[you@yourserver ~]#

```

Original inspiration by https://gist.github.com/kamermans/1076290 
