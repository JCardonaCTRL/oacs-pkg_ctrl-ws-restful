<?xml version="1.0"?>

<queryset>
   <fullquery name="select_token">
      <querytext>
        select jwt_token
        from shib_login_oauth_tokens
        where token_id = :token_id
      </querytext>
   </fullquery>
</queryset>
