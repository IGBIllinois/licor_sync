# Configuration

## licor.yml - General config file
* Copy /etc/licor.yml.dist to /etc/licor.yml
* Edit /etc/licor.yml for your setup
```
local_data_dir:
backup_data_dir:
backup_server:
backup_user:
inactivity_threshold: 1209600 # 2 weeks
inactivity_email_to:
email_from:
smtp_host: localhost
smtp_port: 25
```
* local_data_dir - Directory where raw data resides
* backup_data_dir - Remote Directory to copy data too (Optional)
* backup_server - Remote Server ip address or hostname (Optional)
* backup_user - Remote Server username (Optional)
* inactivity_threshold - Number of seconds since last sycing of data.  Used to determine to send email alerts
* inactivity_email_to - comma seperate list of emails to send inactivity emails
* email_from - from email address
* smtp_host - hostname of smtp mail server
* smtp_port - smtp port


## licor_towers.yml - List of licor towers/devices to sync data from
* Copy /etc/licor_towers.yml.dist to /etc/licor_towers.yml
* Edit /etc/licor_towers.yml with the list of towers.  Add additional sections for each tower
```
- name:
  file_name:
  ip:
  data_dir:
  remove_old: false
  infrequent: false
```
* name - Common name for the tower
* file_name - Filename suffix for the .ghg files.  Files are in the format 2021-08-26T213000_[file_name].ghg
* ip - IP address of licor device
* data_dir - Directory on licor device where data is stored.  This is normally /home/licor/data/raw/
* remove_old - Boolean - Remove data from licor device
* infrequent - Boolean - Removes infrequent data

## licor_digest.yml - Sends email digest of data 
* Copy /etc/licor_digest.yml.dist to /etc/licor_digest.yml
* Edit /etc/licor_digest.yml
```
emails:
 -
columns:
 - column: 4
   round: 0
 - column: 5
   round: 0
 - column: 6
   round: -1
 - column: 7
   round: -1
 - column: 8
   round: 3
 - column: 9
   round: 3
 - column: 14
   round: 1
 - column: 15
   round: 1
 - column: 16
   round: 1
 - column: 17
   round: 1
 - column: 18
   round: 1
 - column: 19
   round: 1
 - column: 20
   round: 1
 - column: 22
   round: 1
 - column: 23
   round: 1
 - column: 24
   round: 1
 - column: 25
   round: 1
```
* emails - comma seperated list of emails to send digest to
* columns - list of columns
