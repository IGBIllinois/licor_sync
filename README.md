# Licor Sync
* Syncs data from Licor 7200 and 7500 devices to a linux server using rsync

# Configuration
* Download the repository
```
git clone https://github.com/IGBIllinois/licor_sync.git
```
## Syncing Data
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
* Add /bin/device_sync.pl to /etc/crontab
```
10 0-23/4 * * * root perl /usr/local/licorSync/bin/device_sync.pl
```

## Automatically Archiving Data
* This tar.gz the data by day
* Add /bin/daily_sort.pl to /etc/crontab
```
00 3 * * * root perl /usr/local/licorSync/bin/daily_sort.pl
```
