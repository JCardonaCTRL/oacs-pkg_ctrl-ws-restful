#bgpd-x/packages/ctrl-digital-signs/www/admin/oauth-tokens-expire.tcl
ad_page_contract {
    Expires a token

    @author:  Juan Carlos Tapia (juancarlos@viaro.net)
   @creation-date: 2019-05-23
} {
	{token_id}
}

token::expire -token_id $token_id

doc_return 200 text/plain "ok"
