# Configuration

## licor.yml
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


