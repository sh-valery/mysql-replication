# ddl
create database ewallet;
create table ewallet.account
(
    username  varchar(64) not null,
    balance_micro long null,
    updated_at datetime default current_timestamp on update current_timestamp
);



# insert data
insert into ewallet.account (username, balance_micro) values ('alice', 1000000000);
insert into ewallet.account (username, balance_micro) values ('bob', 0);
insert into ewallet.account (username, balance_micro) values ('charlie', 0);

# make transaction from alice to bob
start transaction;
set @all_money = 1000000000;
select * from ewallet.account;
update ewallet.account set  balance_micro = balance_micro - @all_money where username = 'alice';
update ewallet.account set  balance_micro = balance_micro + @all_money where username = 'bob';
select * from ewallet.account;
commit;

# run in another session, make transaction from alice to charlie simultaneously
start transaction;
select * from ewallet.account;
set @all_money = 1000000000;
update ewallet.account set  balance_micro = balance_micro - @all_money where username = 'alice';
update ewallet.account set  balance_micro = balance_micro + @all_money where username = 'charlie';
select * from ewallet.account;
commit;