#!/bin/bash

# name config, rename if you run more than one group
master_container="single_primary_mode_mysql-master_1"
slave_first="single_primary_mode_mysql-slave1_1"
slave_second="single_primary_mode_mysql-slave2_1"


# create user for slave in master
create_slave_request='create user "slave_user"@"%" identified by "slave_pass"; grant replication slave on *.* to "slave_user"@"%"; flush privileges;'
docker exec $master_container sh -c "mysql -u root -ppass -e '$create_slave_request '"
echo "slave_user was created"


check_privilege_request='select User, Repl_slave_priv from mysql.user where User="slave_user"'
docker exec $master_container sh -c "mysql -u root -ppass -e '$check_privilege_request '"
echo "slave_user privileged was set"

echo "waiting for 15 seconds, enable replication"
sleep 15

# get master status
ms_status=$(docker exec $master_container sh -c 'mysql -u root -ppass -e "SHOW MASTER STATUS"')
current_log=$(echo "$ms_status" | awk 'NR==2{print $1}')
current_pos=$(echo "$ms_status" | awk 'NR==2{print $2}')
echo "Current log file: $current_log"
echo "Current log pos: $current_pos"

# set slave
sql_set_master="change master to master_host='mysql-master',master_user='slave_user',master_password='slave_pass',master_log_file='$current_log',master_log_pos=$current_pos; start slave;"
docker exec $slave_first sh -c "mysql -u root -ppass -e \"$sql_set_master\""

docker exec $slave_first sh -c "mysql -u root -ppass -e 'SHOW SLAVE STATUS \G'"

# use for experiments with consistency
# docker exec $slave_first sh -c "mysql -u root -ppass -e 'stop slave;'"
# docker exec $slave_first sh -c "mysql -u root -ppass -e 'start slave;'"
