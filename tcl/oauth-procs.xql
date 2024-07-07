<?xml version="1.0"?>
<queryset>
    <fullquery name="ctrl::oauth::authenicate_with_token.update_ios_uuid">
        <querytext>
             update users 
                  set last_ios_uuid = :uuid
             where user_id = :user_id
        </querytext>
    </fullquery>

     <fullquery name="ctrl::oauth::validate_access_token.get_user">
        <querytext>
            select for_user_id
            from shib_login_oauth_tokens
            where token_str = :access_token
        </querytext>
    </fullquery>

    <fullquery name="ctrl::oauth::jwt_check_oacs_fields.get_by_email">
        <querytext>
            select user_id
            from cc_users
            where lower(email) = lower(:value)
        </querytext>
    </fullquery>

    <fullquery name="ctrl::oauth::login.get_by_email">
        <querytext>
            select user_id
            from cc_users
            where lower(email) = lower(:email)
        </querytext>
    </fullquery>


</queryset>

