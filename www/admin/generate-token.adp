<master>

Do you want to generate a token for the current user @first_names@ @last_name@?
<formtemplate id=token_form></formtemplate>


<if @access_token@ ne "">
	Access Token: @access_token@
</if>