## Restrict SSH

restrict_ssh.sh is a bash script which restricts ssh for a user to a set of (flexible) commands via .ssh/authorized_keys, and log it verbosely.

### Purpose

I have a web application which needs to do some things over ssh on a server. It runs as a seperate user, and this script allows me to restrict the commands it can execute as well. It however does allow regexes so filenames can be passed. It also logs the commands and session info.

### Installation / Usage

Download the script from github, or clone the repository.

Put this script in the users home directory, or a directory which is accessible by that user.

Edit the `allowed_commands` array:

    declare -a allowed_commands=('^ls -[l|d|a]$' 'ls -la' 'w' 'uptime' 'pwd' 'uname -a') 

Make sure that there are no comma's (`,`) between the options, otherwise it will fail.

Make it executable for that user: `chown user:usergroup /home/user/restrict_ssh.sh` and/or `chmod +x /home/user/restrict_ssh.sh`.

Modify the users `~/.ssh/authorized_keys` file, and before the ssh key(s) put the line `command="/home/user/restrict_ssh.sh"` before the key. Like so:

    command="/home/remy/restrict_ssh.sh" ssh-rsa AAAAB[...]X9t remy@macbookpro.raymii.nl

Optional: Disable password login for that user, edit `/etc/ssh/sshd_config` and add the following:

    Match User remy
        PasswordAuthentication no

This will disable password logins only for user `remy`.

### Regexing / Safety

The default setup has a regex command allowed. It is the `ls` command, and the regex allows either `ls -l`, `ls -d` or `ls -a`. If you know basic Perl style regexes you can be very creative with this, for example `^ping -c 4 [a-zA-Z0-9]{2,20}.(com|org|net)$` allows the command ping to be executed for any 2 to 20 character .com, .net or .org domain. domain and nothing else.

*BE CAREFULL WITH THIS. IF YOU CONFIGURE IT WRONG USER MAY BE ABLE TO GET A SHELL (vim, :!bash) OR OVERWRITE THE .ssh/authorized_keys FILE. IF YOU ARE NOT SURE, THEN DO NOT USE IT AT ALL!*

Also, if you allow `vim`, `less`, `man`, or any other program, a user might get a shell. If the program you allow includes the possibility to run a shell, this script/restriction is of no use.

### Logging

By default it logs lines like these to syslog:

    Jan 20 20:39:23 vps11 RESTRICTED_SSH[9015]: INFO: SSH Connection: 'x.x.x.x 32309 x.x.x.x 22'
    Jan 20 20:39:23 vps11 RESTRICTED_SSH[9014]: INFO: SSH Client: 'x.x.x.x 32309 22'
    Jan 20 20:39:23 vps11 RESTRICTED_SSH[9017]: INFO: SSH Username: 'remy'
    Jan 20 20:39:23 vps11 RESTRICTED_SSH[9016]: INFO: SSH Shell: '/bin/bash'
    Jan 20 20:39:23 vps11 RESTRICTED_SSH[9013]: INFO: Sent SSH command: 'vim'
    Jan 20 20:39:23 vps11 RESTRICTED_SSH[9018]: ERROR: Command "vim" is not allowed.

### Other info

I think it requires `Bash 4+` because of the array search function. I have no bash lower than v4 to test it with.

### Links

[https://raymii.org/s/software/Restrict_SSH.html](https://raymii.org/s/software/Restrict_SSH.html)  
[https://github.com/RaymiiOrg/restrict_ssh](https://github.com/RaymiiOrg/restrict_ssh)