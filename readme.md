# Mysql replication

* [Single-Primary Mode](https://dev.mysql.com/doc/refman/8.0/en/group-replication-single-primary-mode.html)
* [Multi-Primary Mode](https://dev.mysql.com/doc/refman/8.0/en/group-replication-multi-primary-mode.html)

## Run single primary mode


```bash
cd single_primary_mode
docker-compose up -d
```


## Run multi primary mode

```bash
cd multi_primary_mode
docker-compose up -d
```


# Experiment

## Create account table 
    
    ```sql
create table ewallet.account
(
username  int not null,
balance_micro long null,
updated_at datetime default current_timestamp on update current_timestamp
);
```