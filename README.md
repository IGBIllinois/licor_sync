[![Build Status](https://github.com/IGBIllinois/licor_sync/actions/workflows/main.yml/badge.svg)](https://github.com/IGBIllinois/licor_sync/actions/workflows/main.yml)

# Licor Sync
* Syncs data from Licor 7200 and 7500 devices to a linux server using rsync
* Automatically tar.gz the data by day
* Sends Email alerts if data is not syncing

## Requirements
* rsync
* Perl
  * YAML
  * MIME-Lite
  * String-Util
  * Email::MessageID
  * File::Find::Rule
  * FindBin
## Installation
* Download the latest tag released from https://github.com/IGBIllinois/licor_sync/releases or git clone the repository
```
git clone https://github.com/IGBIllinois/licor_sync.git
```
* Install Perl Modules using cpanm
```
cpanm --installdeps .
```
* Install Perl Modules with yum/dnf
```
dnf -y install perl-YAML perl-MIME-Lite perl-String-Util perl-Email-MessageID perl-File-Find-Rule perl-FindBin
```
* If installing on Rocky Linux 8 or 9, the ssh cipher settings need changing.  Create the file ~/.ssh/config with the following.  Change HOSTNAME to the IP address of the licor device
<pre>
Host HOSTNAME
        KexAlgorithms +diffie-hellman-group1-sha1
        Ciphers +aes128-cbc
        HostKeyAlgorithms +ssh-rsa
        PubkeyAcceptedKeyTypes +ssh-rsa
        RSAMinSize 1024
        SetEnv TERM=vt100
</pre>
* Change the SSH Cipher settings to LEGACY
<pre>
update-crypto-policies --set LEGACY
</pre>

### Configuration
How to setup config files is at [docs/config.md](docs/config.md)

* On linux server, create ssh keys to login to the licor devices without a password
```shell
ssh-copy-id licor@192.168.0.100
```

### Setup Cron
* An example cron file is at etc/cron.dist.  Copy etc/cron.dist to etc/cron
```shell
cp etc/cron.dist etc/cron
```
* Edit etc/cron to suit the times you want the data to sync and be compressed.
* Create symlink of etc/cron to /etc/cron.d/licorsync
* Below are the list of scripts that can be added to cron
* device_sync.pl - Rsyncs data from licor devices to local directory
* daily_sort.pl - Script to archive licor data from the previous day
* daily_sort_batch.pl - Script to archive licor data older than a day 
* fileserver_sync.pl - syncs data from the local folders to the file-server
* remote_delete.pl - Script to remotely delete data older than 6 months from licor devices

