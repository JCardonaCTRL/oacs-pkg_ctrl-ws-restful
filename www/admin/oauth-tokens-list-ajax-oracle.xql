<?xml version="1.0"?>
<queryset>
    <fullquery name="selected_rows_to_display">
        <querytext>
            select x1.*
            from (
                select  rownum as rn, x2.*
                from (
                    select  token_id   , 
                        package_id,
                        token_str ,
                        token_label,
                        to_char(valid_until, 'MM/DD/YYYY HH24:MI') as valid_until ,
                        enable_p,
                        case 
                        	when enable_p = 't' then 'Enabled'
                        	else 'Disabled'
                        end as status  ,
                        for_user_id as for_user,
                        jwt_token
                    from shib_login_oauth_tokens t
                    where package_id = :this_package_id
                    $sql_order
                ) x2
              ) x1
        </querytext>
    </fullquery>
    

    <fullquery name="total_selected_rows">
        <querytext>
           select count(*)
           from shib_login_oauth_tokens t
           where package_id = :this_package_id
        </querytext>
    </fullquery>

    <fullquery name="total_rows">
        <querytext>
            select count(*)
            from shib_login_oauth_tokens t
            where package_id = :this_package_id
        </querytext>
    </fullquery>
</queryset>
