# Nagios setup notes

## Finish nagios install

### Copy all check files to nagios libexec:
`sudo cp check* /usr/local/nagios/libexec/`

Make sure they are 775 root nagios permissions

### Important:  Setup "Cross Data Center" firewall policy from IL1

### Update SUDOERS USING visudo!!
`visudo`

Update NAGIOS ALL to:
`nagios ALL=(ALL) NOPASSWD: /usr/local/nagios/libexec/,/ext/telos-build/eos/,/usr/bin/,/ext/telos-build/eos/build/bin/,/ext/config`

### Update NRPE.cfg
`/usr/local/nagios/etc/nrpe.cfg`

Add:
```command[check_block_produce]=/usr/local/nagios/libexec/check_block_produce
command[check_bp_rank]=/usr/local/nagios/libexec/check_bp_rank
command[check_is_active]=/usr/local/nagios/libexec/check_is_active```

### Restart xinetd
`/etc/init.d/xinetd restart`

## Troubleshooting

### Troubleshoot XINETD
look at the xinetd conf:
`sudo vi /etc/xinetd.d/nrpe`

Make sure Nagios server IP is listed:
`	only_from       = 127.0.0.1 64.74.98.106 10.91.176.13`

then:
`service xinetd restart`

### Local NRPE test
`/usr/local/nagios/libexec/check_nrpe -H localhost`

### Local plug-in tests:
```sudo /usr/local/nagios/libexec/check_is_active
sudo /usr/local/nagios/libexec/check_bp_rank
sudo /usr/local/nagios/libexec/check_block_produce```

