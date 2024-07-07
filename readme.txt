Release 1.11.0
- Created endpoints to test the token generation for Oauth and JWT. These endpoints will be created by default when installing the package and are stored in: /lib/ws/example-ws.json.
- Created page /admin/generate-token to generate a token for the user that is currently logged in, depending on the auth_type in the parameters.
- Updated the Access Denied messages in ctrl::oauth::check_auth_header to clarify what the problem is when the request is denied.
- Added a documentation file in the /www/doc/ directory that describes how to setup and use the tokens.
- Updated the option to delete requests to not cause issues with CSP.
- Updated SQL script to create the shib table if it doesnt exists. Also added the jwt table to the drop script.
- Updated the procedure to generate a token for a user. Added a parameter to override the token expiration time.

Release 1.12.0
- Fixed bug in override of expiration date when creating token manually.
- Added searching to the tokens datatable.
- Fixed bug in sorting by date in tokens datatable.
- Made the Tokens datatable more compact.
- Fixed error when entering \ in the audit logs.
- Updated the way errors are handled by letting the individual procedures do it. The field Procedure self handles the errors was added to the UI where new web services are created.

Release 2.0.0
- Updated code to adapt to openacs 5.10.0 and bootstrap 5.
  - Replaced "cache" procedure with "ns_cache" in the "ctrl::oauth::jwt_validate" procedure.
  - Replaced "$doc_elements(switches)" for "$doc_elements(switches0)" "ctrl::restful::process_request_url" procedure
  - Updated UI for Manage Tokens and JWT Setup to use bootstrap 5
- Added Creation Date for tokens.
- Fixed bug in sorting by data in tokens table.
- Fixed bug that didnt block the access of a JWT if it was disabled in the UI.
- Added filter to hide expired tokens and highlighted expired tokens in red.