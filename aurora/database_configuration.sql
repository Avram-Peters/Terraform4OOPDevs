create role ro_role;
grant usage on schema public to ro_role;
grant select on all tables in schema public to ro_role;

create role rw_role;
grant usage on schema public to rw_role;
grant select,update,delete,insert on all tables in schema public to rw_role;

create user ro_abepeters with login;
grant rds_iam to ro_abepeters;
grant ro_role to ro_abepeters;

create user rw_abepeters with login;
grant rds_iam to rw_abepeters;
grant rw_role to rw_abepeters;


