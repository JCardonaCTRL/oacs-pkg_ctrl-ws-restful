<?xml version="1.0"?>
<queryset>
    <fullquery name="selected_rows_to_display">
        <querytext>
            select x1.*
            from (
                select  ROW_NUMBER() OVER () as rn, x2.*
                from (
                    select  token_id   , 
                        package_id,
                        token_str ,
                        token_label,
                        creation_date,
                        to_char(creation_date, 'MM/DD/YYYY HH24:MI') as creation_date_pretty ,
                        valid_until,
                        to_char(valid_until, 'MM/DD/YYYY HH24:MI') as valid_until_pretty ,
                        enable_p,
                        case 
                        	when enable_p = 't' then 'Enabled'
                        	else 'Disabled'
                        end as status  ,
                        for_user_id as for_user,
                        jwt_token,
                        case 
                            when (valid_until > now()) then 'f' 
                            else 't'
                        end as expired_p
                    from shib_login_oauth_tokens t
                    where package_id = :this_package_id
                    $sql_where_filter
                    $sql_search_filter
                    $sql_order
                ) x2
              ) x1
              $sql_filter_row
        </querytext>
    </fullquery>
    

    <fullquery name="total_selected_rows">
        <querytext>
           select count(*)
           from shib_login_oauth_tokens t
           where package_id = :this_package_id
           $sql_search_filter
           $sql_where_filter
        </querytext>
    </fullquery>

    <fullquery name="total_rows">
        <querytext>
            select count(*)
            from shib_login_oauth_tokens t
            where package_id = :this_package_id
            $sql_where_filter
        </querytext>
    </fullquery>
</queryset>
