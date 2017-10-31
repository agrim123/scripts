# Capture Intruder

A small bash script that takes photo every time a wrong password is entered.  
Useful for someone trying to login into your laptop.

## Setup

- Clone the bash script

- Make it executable

```bash
$ chmod +x capture-intruder.sh
```

- Open up `common-auth` file

```bash
$ [sudo] vim /etc/pam.d/common-auth
```

- Find line 

```vim
auth    [success=1 default=ignore]      pam_unix.so nullok_secure
```

Change it to

```vim
auth    [success=2 default=ignore]      pam_unix.so nullok_secure
```

Add the following line just below it

```vim
auth    [default=ignore]                pam_exec.so seteuid path_to_sciprt/name_of_script
```
