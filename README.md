# Licor Sync
* Syncs data from Licor 7200 and 7500 devices to a linux server using rsync

## Requirements
* rsync
* Perl
* Perl Yaml
* Perl Data-Dumper
* Perl MIME-Lite

## Installation
* Download the repository
```
git clone https://github.com/IGBIllinois/licor_sync.git
```
### Syncing Data
* Copy /etc/licor_towers.yml.dist to /etc/licor_towers.yml
* Edit /etc/licor_towers.yml for each device to sync
    * name: name of the folder to place the data in
    * file_name: is the file name suffix on the data on the licor device
    * ip: IP address of the device
    * data_dir: full path to the raw data on the device
    * remove_source_files: true/false - delete the data from the device
```
- name: tower_1
  file_name: AIU-0468
  ip: 192.168.0.100
  data_dir: /home/licor/data/raw/
  remove_source_files: true
```
* On linux server, create ssh keys to login to the licor devices without a password
```
ssh-copy-id licor@192.168.0.100
```

### Setup Cron
* An example cron file is at etc/cron.dist.  Copy etc/cron.dist to etc/cron
```
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

