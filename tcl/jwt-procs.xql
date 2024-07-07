<?xml version="1.0"?>
<queryset>

	<fullquery name="ctrl::restful::jwt::get_setup.select">
	 	<querytext>
			select *
			from ctrl_ws_restful_jwt_setup
			where package_id = :package_id
		</querytext>
	</fullquery>

	<fullquery name="ctrl::restful::jwt::new_setup.insert">
	 	<querytext>
			insert into ctrl_ws_restful_jwt_setup (
				client_id, jwt_type, client_key, public_key, private_key, jwt_alg, token_expiration, iss, sub, aud, package_id, creation_date
			) values (
				:client_id, :jwt_type, :client_key, :public_key, :private_key, :jwt_alg, :token_expiration, :iss, :sub, :aud, :package_id, now()
			)
		</querytext>
	</fullquery>

	<fullquery name="ctrl::restful::jwt::edit_setup.update">
	 	<querytext>
			update ctrl_ws_restful_jwt_setup
			set last_modification_date = now(),
			$sql_update
			where package_id = :package_id
		</querytext>
	</fullquery>
</queryset>