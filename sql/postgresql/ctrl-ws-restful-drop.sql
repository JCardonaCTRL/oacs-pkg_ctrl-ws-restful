alter table users drop column last_ios_uuid;
drop sequence shib_login_oauth_tokens_seq;
drop table shib_login_oauth_tokens;
drop table ctrl_ws_restful_jwt_setup;