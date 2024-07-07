ad_library {

    Test cases for JWT

    @author juan.tapia@nexadevs.com
    @cvs-id $Id$
    @creation-date 2020-08-31
}


aa_register_case -cats {api db} -procs {ctrl::restful::jwt::new_setup ctrl::restful::jwt::edit_setup \
	ctrl::restful::jwt::get_setup} jwt_setup_api {

   	JWT Setup API

} {

    aa_run_with_teardown -rollback -test_code {
    	set package_id [ad_conn package_id]
    	set client_id [ad_generate_random_string 39]
    	set client_key "[ad_generate_random_string 39][ad_generate_random_string 23]"
    	set jwt_type "shared_secret"
    	set jwt_alg "HS256"
    	set token_expiration 100
    	set iss "iss"
    	set sub "subject"
    	set aud "audience"
    	set public_key "/jwt/public.key"
    	set private_key "/jwt/private.key"

    	set success_p [ctrl::restful::jwt::new_setup -package_id $package_id \
				    	    -client_id $client_id \
				    	    -jwt_type $jwt_type \
				    	    -client_key $client_key \
				    	    -public_key $public_key \
				    	    -private_key $private_key \
				    	    -jwt_alg $jwt_alg \
				    	    -token_expiration $token_expiration \
				    	    -iss $iss \
				    	    -sub $sub \
				    	    -aud $aud]

		aa_true "Check if JWT Setup was created" {![empty_string_p $success_p] && ($success_p > 0)}
		
		# -- Check if we can get setup
		set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]
		set client_id_2 $setup_info(client_id)
		aa_true "Check if data from the JWT Setup can be retrieved" {$exists_p && $client_id eq $client_id_2}


		# Update one of the fields in the  setup
		set client_id_update [ad_generate_random_string 39]

		ctrl::restful::jwt::edit_setup -package_id $package_id \
		    -client_id $client_id_update \
		    -jwt_type $jwt_type \
		    -client_key $client_key \
		    -public_key $public_key \
		    -private_key $private_key \
		    -jwt_alg $jwt_alg \
		    -token_expiration $token_expiration \
		    -iss $iss \
		    -sub $sub \
		    -aud $aud

		# -- Check if we can get setup to see if the fueld was updated
		set exists_p [ctrl::restful::jwt::get_setup -package_id $package_id -column_array "setup_info"]
		set client_id_update_2 $setup_info(client_id)
		aa_true "Check if data can be edited in the JWT Setup" {$client_id_update eq $client_id_update_2}

    }

}


aa_register_case -cats {api db} -procs {ctrl::restful::jwt::new_setup ctrl::restful::jwt::generate_token \
		ctrl::jwt::cjwt_decode_token ctrl::oauth::jwt_check_email} jwt_generate_api {

   	JWT Generate API

} {

    aa_run_with_teardown -rollback -test_code {
    	set package_id [ad_conn package_id]
    	set client_id [ad_generate_random_string 39]
    	set client_key "[ad_generate_random_string 39][ad_generate_random_string 23]"
    	set jwt_type "shared_secret"
    	set jwt_alg "HS256"
    	set token_expiration 100
    	set iss "iss"
    	set sub "subject"
    	set aud "audience"
    	set public_key "/jwt/public.key"
    	set private_key "/jwt/private.key"

    	set success_p [ctrl::restful::jwt::new_setup -package_id $package_id \
				    	    -client_id $client_id \
				    	    -jwt_type $jwt_type \
				    	    -client_key $client_key \
				    	    -public_key $public_key \
				    	    -private_key $private_key \
				    	    -jwt_alg $jwt_alg \
				    	    -token_expiration $token_expiration \
				    	    -iss $iss \
				    	    -sub $sub \
				    	    -aud $aud]

		aa_true "Check if JWT Setup was created" {![empty_string_p $success_p] && ($success_p > 0)}
		
		set user_id [ad_conn user_id] 
		set jwt_token [ctrl::restful::jwt::generate_token -package_id $package_id \
						-user_id $user_id \
						-field "email" \
						-field_type_label "email"]

		set decode_success_p 1
		if { [catch {set jwtTokenObject [ctrl::jwt::cjwt_decode_token -jwt_token $jwt_token \
		                -secret $client_key]} fid] } {
		    set decode_success_p 0
		}
		
		set sub ""
		set valid_p 0
		if {$decode_success_p} {
			set claims_list [$jwtTokenObject set getClaimList]
	        set valid_p [$jwtTokenObject set isValid]
	        set invalid_code [$jwtTokenObject set invalidCode]

	        set sub_pos [lsearch $claims_list "sub"]
	        if {$sub_pos > -1} {
	            # Get the value next to the client_id tag
	            set sub [lindex $claims_list [expr {$sub_pos + 1}]]
	        }
	    }

	    aa_true "Check if JWT was decoded and is valid" {$decode_success_p && $valid_p}

	    # Check if the user id obtained from the jwt is the same used to generate it
	    set decoded_user_id [ctrl::oauth::jwt_check_email -sub_value $sub]
	    aa_true "Check if the user id obtained from the jwt is the same used to generate it" {$user_id eq $decoded_user_id}


	    # Try decoding with a different client key
	    set wrong_client_key [ad_generate_random_string 39]
    	set decode_success_p 1
    	if { [catch {set jwtTokenObject [ctrl::jwt::cjwt_decode_token -jwt_token $jwt_token \
    	                -secret $wrong_client_key]} fid] } {
    	    set decode_success_p 0
    	}
    	
    	set valid_p 0
    	set invalid_code ""
    	if {$decode_success_p} {
    		set claims_list [$jwtTokenObject set getClaimList]
            set valid_p [$jwtTokenObject set isValid]
            set invalid_code [$jwtTokenObject set invalidCode]
        }

        aa_true "Check if the token generated with the wrong key is not valid" {!$valid_p && $invalid_code eq "INV"}
    }

}