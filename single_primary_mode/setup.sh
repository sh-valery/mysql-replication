#!/bin/bash

# name config, rename if you run more than one group
master_container="single_primary_mode_mysql-master_1"
slave_first="single_primary_mode_mysql-slave1_1"
slave_second="single_primary_mode_mysql-slave2_1"

# check master is available
check_availability_request='select 1'
master_status=`docker exec $master_container sh -c "mysql -u root -ppass -s -e '$check_availability_request'"`
if [ "master_status" != "1" ]; then
    echo "Master is not available"
    exit 1
fi

# create user for slave in master
create_slave_request='CREATE USER "slave_user"@"%" IDENTIFIED BY "slave_pass"; GRANT REPLICATION SLAVE ON *.* TO "slave_user"@"%"; FLUSH PRIVILEGES;'

docker exec $master_container sh -c "mysql -u root -ppass -e '$create_slave_request '"

check_privilege_request='select User, Repl_slave_priv from mysql.user where User="slave_user"'
docker exec $master_container sh -c "mysql -u root -ppass -e '$check_privilege_request '"

# get master status
MS_STATUS=`docker exec $master_container sh -c 'mysql -u root -ppass -e "SHOW MASTER STATUS"'`
CURRENT_LOG=`echo $MS_STATUS | awk 'NR==2{print $1}'`
CURRENT_POS=`echo $MS_STATUS | awk 'NR==2{print $2}'`

# set slave
sql_set_master="CHANGE MASTER TO MASTER_HOST='mysql-master',MASTER_USER='slave_user',MASTER_PASSWORD='slave_pass',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
docker exec $slave_first sh -c "mysql -u root -ppass -e \"$sql_set_master\""

docker exec $slave_first sh -c "mysql -u root -ppass -e 'SHOW SLAVE STATUS \G'"