#bgpd-x/packages/ctrl-digital-signs/www/admin/oauth-tokens-status-updates.tcl
ad_page_contract {
    Disables or enables a token

    @author:  Juan Carlos Tapia (juancarlos@viaro.net)
   @creation-date: 2019-05-23
} {
	{token_id}
	{enable_p}
}

token::setStatus -token_id $token_id -enable_p $enable_p

doc_return 200 text/plain "ok"
