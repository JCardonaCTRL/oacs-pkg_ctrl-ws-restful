<?xml version="1.0"?>
<queryset>
    <fullquery name="token::new.insert">
        <querytext>
            insert into shib_login_oauth_tokens (
                token_id, token_str, token_label, creation_date, valid_until, enable_p, for_user_id, package_id, jwt_token
            ) values (
                :token_id, :token_str, :token_label, now(), to_timestamp(:valid_until, 'MM/DD/YYYY HH24:MI'), :enable_p, :for_user_id, :package_id, :jwt_token
            )
        </querytext>
   </fullquery>

    <fullquery name="token::setStatus.update">
        <querytext>
            update shib_login_oauth_tokens
            set enable_p = :enable_p
            where token_id = :token_id
        </querytext>
   </fullquery>

   <fullquery name="token::expire.update">
        <querytext>
            update shib_login_oauth_tokens
            set valid_until = now()
            where token_id = :token_id
        </querytext>
   </fullquery>

    <fullquery name="token::isValid.get_token_p">
        <querytext>
            select 1
            from shib_login_oauth_tokens
            where token_str = :token_str
                and package_id = :package_id
                and enable_p = 't'
                and valid_until > now()
        </querytext>
   </fullquery>

   <fullquery name="token::exists.get_token_p">
        <querytext>
            select 1
            from shib_login_oauth_tokens
            where token_str = :token_str
                and package_id = :package_id
        </querytext>
    </fullquery>
</queryset>
