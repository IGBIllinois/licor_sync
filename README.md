[![Build Status](https://travis-ci.com/IGBIllinois/licor_sync.svg?branch=master)](https://travis-ci.com/IGBIllinois/licor_sync)

# Licor Sync
* Syncs data from Licor 7200 and 7500 devices to a linux server using rsync
* Automatically tar.gz the data by day
* Sends Email alerts if data is not syncing

## Requirements
* rsync
* Perl
  * Perl Yaml
  * Perl Data-Dumper
  * Perl MIME-Lite
  * Perl String-Util
  * Perl Email::MIME

## Installation
* Download the repository or download a tag release
```
git clone https://github.com/IGBIllinois/licor_sync.git
```
* Install Perl Modules using cpanm
```
cpanm --installdeps .
```

### Syncing Data
* Copy /etc/licor.yml.dist to /etc/licor.yml
* Edit /etc/licor.yml
  * local_data_dir: the local folder to sync tower data to
  * backup_server: the hostname of the server to backup compressed data to
  * backup_data_dir: the folder on the backup server to send data to
  * inactivity_threshold: how long before a tower is considered inactive, in seconds
  * inactivity_email_to: recipients to notify about inactive tower(s)
  * inactivity_email_from: email address from which to send notifications
* Copy /etc/licor_towers.yml.dist to /etc/licor_towers.yml
* Edit /etc/licor_towers.yml for each device to sync
  * name: name of the folder to place the data in
  * file_name: is the file name suffix on the data on the licor device
  * ip: IP address of the device
  * data_dir: full path to the raw data on the device
  * remove_source_files: true/false - delete the data from the device
```yaml
- name: tower_1
  file_name: AIU-0468
  ip: 192.168.0.100
  data_dir: /home/licor/data/raw/
  remove_source_files: true
```
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

