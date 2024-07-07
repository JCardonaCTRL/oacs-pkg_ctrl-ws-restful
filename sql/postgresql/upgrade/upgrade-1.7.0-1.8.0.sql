create table ctrl_ws_restful_jwt_setup (
    client_id        varchar(40),
    jwt_type         varchar(20),
    client_key       varchar(64),
    private_key      varchar(200),
    public_key      varchar(200),
    jwt_alg          varchar(10),
    token_expiration integer,
    iss              varchar(200),
    sub              varchar(200),
    aud              varchar(200),
    package_id       integer not null,
    creation_date    timestamp default now(),
    last_modification_date    timestamp,
    unique (package_id)
);


-- Some instances of Ctrl-ws-restful do not have this table created in their older versions, 
-- so we create it if it doesnt exists

create table if not exists shib_login_oauth_tokens (
    token_id       integer primary key,
    package_id    integer not null,
    token_str        varchar (150) not null,
    token_label     varchar(200),
    valid_until       timestamp  not null,
    enable_p        char(1) default 't' ,
    for_user_id     integer ,
    jwt_token varchar(1000),
    unique (package_id, token_str)
);
create sequence if not exists shib_login_oauth_tokens_seq start with 1;
-- oauth
alter table users add if not exists last_ios_uuid  varchar(100);

alter table shib_login_oauth_tokens add if not exists jwt_token varchar(1000);