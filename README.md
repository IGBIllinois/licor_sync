# Licor Sync
[![Build Status](https://github.com/IGBIllinois/licor_sync/actions/workflows/main.yml/badge.svg)](https://github.com/IGBIllinois/licor_sync/actions/workflows/main.yml)

* Syncs data from Licor 7200 and 7500 devices to a linux server using rsync
* Automatically tar.gz the data by day
* Sends Email alerts if data is not syncing

## Requirements
* rsync
* Perl
  * Perl Yaml
  * Perl MIME-Lite
  * Perl String-Util
  * Email::MessageID
## Installation
* Download the latest tag released from https://github.com/IGBIllinois/licor_sync/releases or git clone the repository
```
git clone https://github.com/IGBIllinois/licor_sync.git
```
* Install Perl Modules using cpanm
```
cpanm --installdeps .
```

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

