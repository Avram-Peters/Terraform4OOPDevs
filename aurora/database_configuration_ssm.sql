create role ro_role;
grant usage on schema public to ro_role;
grant select on all tables in schema public to ro_role;

create role rw_role;
grant usage on schema public to rw_role;
grant select,update,delete,insert on all tables in schema public to rw_role;

create user ro_abepeters with login;
alter user ro_abepeters password 'tempP@$$word';
grant ro_role to ro_abepeters;

create user rw_abepeters with login;
alter user rw_abepeters password 'tempP@$$word';
grant rw_role to rw_abepeters;


