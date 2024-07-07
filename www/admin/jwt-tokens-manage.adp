<master>

<h3> JWT Tokens Setup </h3>

<formtemplate id=jwt_token_form>
    <div class="row form-group">
        <label for="client_id" class="col-sm-2 col-form-label">Client ID: *</label>
        <div class="col-sm-6"><formwidget id="client_id"></div>
    </div>
    <div class="row form-group">
        <label for="jwt_type" class="col-sm-2 col-form-label">JWT Type: *</label>
        <formgroup id="jwt_type">
            <div class="col-sm-3">@formgroup.widget;noquote@ @formgroup.label;noquote@</div>
        </formgroup>
    </div>

    <div id="shared_secret_section">
        <div class="row form-group">
            <label for="client_key" class="col-sm-2 col-form-label">Client Key: *</label>
            <div class="col-sm-8"><formwidget id="client_key"></div>
        </div>
    </div>

    <div id="dual_key_section">
        <div class="row form-group">
            <label for="public_key" class="col-sm-2 col-form-label">Public Key: *</label>
            <div class="col-sm-6"><formwidget id="public_key"></div>
        </div>
        <div class="row form-group">
            <label for="private_key" class="col-sm-2 col-form-label">Private Key:</label>
            <div class="col-sm-6"><formwidget id="private_key"></div>
        </div>
    </div>

    <div class="row form-group">
        <label for="jwt_alg" class="col-sm-2 col-form-label">JWT Algorithm: *</label>
        <div class="col-sm-6"><formwidget id="jwt_alg"></div>
    </div>

    <div class="row form-group">
        <label for="token_expiration" class="col-sm-2 col-form-label">Token Expiration Default (In Seconds): *</label>
        <div class="col-sm-6"><formwidget id="token_expiration"></div>
    </div>

    <h4>Registered Claims</h4>
    <div class="row form-group">
        <label for="iss" class="col-sm-2 col-form-label">Issuer (iss):</label>
        <div class="col-sm-6"><formwidget id="iss"></div>
    </div>
    <div class="row form-group">
        <label for="sub" class="col-sm-2 col-form-label">Subject (sub):</label>
        <div class="col-sm-6"><formwidget id="sub"></div>
    </div>
    <div class="row form-group">
        <label for="aud" class="col-sm-2 col-form-label">Audience (aud):</label>
        <div class="col-sm-6"><formwidget id="aud"></div>
    </div>
    <div class="row form-group">
        <div class="col-sm-8" style="text-align: center;">
            <input type="submit" id="btn_jwt_setup" class="btn btn-info" value="Save">
        </div>
    </div>
</formtemplate>

<script type="text/javascript"  <if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>
    $(document).ready(function() {

        showKeys('@jwt_type@');
        showAlgs('@jwt_type@', 0);

        $("#jwt_token_form").validate({
            errorClass: "form-required-mark",
            errorElement: "span",
            rules: {
                client_id:          { required: true },
                jwt_type:           { required: true},
                jwt_alg:            { required: true},
                token_expiration:   { required: true},
                client_key:         { requiredSharedSecret: true},
                public_key:         { requiredDualKeys: true}
            }
        });
        $.validator.messages.required = "* Required";

        jQuery.validator.addMethod("requiredSharedSecret", function(value, element) {
            var jwt_type = $('input[name=jwt_type]:checked').val();

            if (jwt_type == 'shared_secret' && value == '') {
                return false
            }

            return true;
        }, "Required");

        jQuery.validator.addMethod("requiredDualKeys", function(value, element) {
            var jwt_type = $('input[name=jwt_type]:checked').val();

            if (jwt_type == 'public_private_key' && value == '') {
                return false
            }

            return true;
        }, "Required");


        $('input[name=jwt_type]').on('change', function() {
            var value = $(this).val();
            showKeys(value);
            showAlgs(value, 1);
        });

        function showKeys (jwt_type) {
            switch(jwt_type) {
                case 'shared_secret':
                    $('#shared_secret_section').show();
                    $('#dual_key_section').hide();
                    break;
                case 'public_private_key':
                    $('#shared_secret_section').hide();
                    $('#dual_key_section').show();
                    break;
                default:
                    $('#shared_secret_section').hide();
                    $('#dual_key_section').hide();
            }
        }

        function showAlgs (jwt_type, unselect_p) {
            switch(jwt_type) {
                case 'shared_secret':
                    $("select[name=jwt_alg] option:contains(HS)").show();
                    $("select[name=jwt_alg] option:contains(RS)").hide();
                    break;
                case 'public_private_key':
                    $("select[name=jwt_alg] option:contains(HS)").hide();
                    $("select[name=jwt_alg] option:contains(RS)").show();
                    break;
                default:
                    $("select[name=jwt_alg] option:contains(HS)").hide();
                    $("select[name=jwt_alg] option:contains(RS)").hide();       
            }

            if (unselect_p) {
                $("select[name=jwt_alg]").val('');
            }
        }

    });
</script>