create table shib_login_oauth_tokens (
	token_id       integer primary key,
	package_id    integer not null,
	token_str        varchar (150) not null,
	token_label 	varchar(200),
	valid_until       timestamp  not null,
	enable_p        char(1) default 't' ,
	for_user_id     integer ,
	unique (package_id, token_str)
);

create sequence shib_login_oauth_tokens_seq start with 1;