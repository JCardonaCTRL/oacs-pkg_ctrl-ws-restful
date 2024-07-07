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

alter table shib_login_oauth_tokens add column jwt_token varchar(1000);