# pgbackup
Postgres windows cmd backup and restore script, before usage you need to put correct variables at start of script, bin paths, username, password, etc...


Allowed commands: 

  backup database [sql]                     - for backup database in custom format, 
                                              use sql option for plain sql backup

  restore database dumpfilename [overwrite] - for restore database from backup
                                              use overwrite option for silently 
                                              overwrite existing database

   clean                                    - for clean old backup files
   
   
   
