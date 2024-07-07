<master>

<style type="text/css">
    td {
        overflow-wrap: break-word;
    }
    .row-expired {
        background-color: #ffb6b9 !important;
    }
</style>

<h3> Manage OAuth Tokens </h3>

<br>

<button type="button" class="newBtn btn btn-success btn-sm">New Token</button>
  
<!-- Modal -->
<div class="modal" id="addTokenModal" tabindex="-1" role="dialog" aria-labelledby="addTokenModalLabel">
	<div class="modal-dialog" role="document" style="min-width: 600px;">
		<div class="modal-content">
			<div class="modal-header">
				<h4 class="modal-title" id="addTokenModalLabel">Add Token</h4>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
			</div>
			<div id="oat-modal-body" class="modal-body">
			</div>
			<div class="modal-footer">
				<button type="button" class="saveBtn btn btn-primary">Save changes</button>
				<button type="button" class="closeBtn btn btn-light" data-bs-dismiss="modal">Close</button>
			</div>
		</div>
	</div>
</div>

<br>
<div class="row">
    <div class="col-sm-2"></div>
    <div class="col-sm-4">
        <input type="checkbox" id="show_expired_tokens" name="show_expired_tokens" value="t" checked> Show Expired Tokens
    </div>
</div>

<table id="oauth-token-table" class="table table-hover table-striped" width="100%"></table>


<script type="text/javascript"  <if @::__csp_nonce@ not nil> nonce="@::__csp_nonce;literal@"</if>>
	jQuery.globalEval = function(){};
	$(document).ready(function() {

        $('#show_expired_tokens').on('change', function(event) {
            $('#oauth-token-table').DataTable().ajax.reload();
        });
        
	    $('#oauth-token-table').DataTable({
	        processing  : true,
	        serverSide  : true,
	        pageLength: 25,
            stateSave   : false,
	        ajax: {
	             "url": "@ajax_url;noquote@",
	             "method": "post",
	         },
	        columns: [
	            { "data": "token_str", "title": "Token String", "class":"center"},
	            { "data": "token_label", "title": "Token Label", "class":"center"},
                { "data": "creation_date_pretty", "title": "Creation Date", "class":"center"},
	            { "data": "valid_until_pretty", "title": "Valid Until", "class":"center"},
	            { "data": "status", "title": "Status", "class":"center"},
                <if @auth_type@ eq "jwt">
                { "data": "jwt_token", "title": "JWT Token", "class":"center"},
                </if>
	            { "data": "for_user", "title": "For User", "class":"center"},
	            { "data": "actions", "title": "Actions", "class":"center" , "orderable":false},
                { "data": "expired_p", "title": "Expired", "visible":false , "orderable":false}
	        ],
	        "order"     : [[2,"desc"], [3,"desc"]],
	        "searching"     : true,
            "createdRow": function(row, data){
                $('td:eq(0)', row).css('max-width', '200px');
                <if @auth_type@ eq "jwt">
                    $('td:eq(5)', row).css('max-width', '400px');
                </if>

                if (data.expired_p == "t") {
                    $(row).addClass( 'row-expired' );
                }
            },
            "drawCallback": function() {
                            taskNewBtn();
                            taskStatusBtn();
                            taskExpireBtn();
                            taskJWTBtn();
                            $('#addTokenModal').on('hidden.bs.modal', function (e) {
                                    $('#displayLayoutLabel').empty();
                                    $('.saveBtn').unbind();
                            });
            }
	    }).on('preXhr.dt', function ( e, settings, data ){
            var show_expired_tokens_p = 'f';
            if ($('#show_expired_tokens').is(':checked')) {
                show_expired_tokens_p = 't';
            }
            data.show_expired_tokens_p = show_expired_tokens_p;

        });   
	});

    function taskDateTime() {
        new tempusDominus.TempusDominus(document.getElementById('valid_until'), {
            display: {
                sideBySide: true
            }
        });
    }

    function taskValidate() {
       $("#oauth_token_form").validate({
            errorClass: "form-required-mark",
            errorElement: "span",
            rules: {
                token_str:           { required: true },
                valid_until:         { required: true},
                <if @auth_type@ eq "jwt">user_field: { required: true},</if>
                enable_p:           { required: true}
            }
        });
        $.validator.messages.required = "* Required";
    }

    function taskNewBtn() {
        $('.newBtn').off('click');
        $('.newBtn').click(function() {
            var addTokenModal = new bootstrap.Modal(document.getElementById('addTokenModal'))
            addTokenModal.show();

            $('#addTokenModalLabel').html("Add Token")
            $("#oat-modal-body").html("");
            $("#oat-modal-body").load("@add_url;noquote@", function() {
                taskDateTime();
            });
            $(".saveBtn").empty().append('Add');
            $(".saveBtn").show();
            $('.saveBtn').unbind();
            $('.saveBtn').click(function () {
                taskValidate();

                var tokenForm = document.getElementById('oauth_token_form');
                if (!tokenForm.checkValidity()) {
                    tokenForm.classList.add('was-validated')
                } else {
                    $.ajax({
                        method: "POST",
                        url: "@add_url;noquote@",
                        data: $('#oauth_token_form').serialize()
                    }).done(function () {
                        window.location.reload();
                    });
                }
            });

        });
    }

    function taskStatusBtn() {
        $('.statusBtn').off('click');
        $('.statusBtn').click(function() {
            var addTokenModal = new bootstrap.Modal(document.getElementById('addTokenModal'))
            addTokenModal.show();

            var id = $(this).attr('id');
            var enable_p = $(this).data('enable_p');

            var status = "Disable"
            if (enable_p == 't') {
                status = "Enable"
            }

            $('#addTokenModalLabel').html(status+" Token")
            $('#oat-modal-body').html("Are you sure you want to "+status+" this token?");
            $(".saveBtn").empty().append(status);
            $(".saveBtn").show();
            $('.saveBtn').unbind();
            $('.saveBtn').click(function () {
                $.ajax({
                   method: "POST",
                   url: "@status_url;noquote@",
                   data: {
                       "token_id": id,
                       "enable_p" : enable_p
                    }
                }).done(function () {
                    $('.saveBtn').unbind();
                    $('#addTokenModal').modal('hide');
                    $('#oauth-token-table').DataTable().ajax.reload();
                });

            });
        });
    }

    function taskExpireBtn() {
        $('.expireBtn').off('click');
        $('.expireBtn').click(function() {
            var addTokenModal = new bootstrap.Modal(document.getElementById('addTokenModal'))
            addTokenModal.show();

            var id = $(this).attr('id');

            $('#addTokenModalLabel').html("Expire Token")
            $('#oat-modal-body').html("Are you sure you want to Expire this token?");
            $(".saveBtn").empty().append("Expire");
            $(".saveBtn").show();
            $('.saveBtn').unbind();
            $('.saveBtn').click(function () {
                $.ajax({
                    method: "POST",
                    url: "@expire_url;noquote@",
                    data: {
                        "token_id": id
                    }
                }).done(function () {
                    $('.saveBtn').unbind();
                    $('#addTokenModal').modal('hide');
                    $('#oauth-token-table').DataTable().ajax.reload();
                });

            });

        });
    }

    function taskJWTBtn() {
        $('.jwtBtn').off('click');
        $('.jwtBtn').click(function() {
            var addTokenModal = new bootstrap.Modal(document.getElementById('addTokenModal'))
            addTokenModal.show();
            var id = $(this).attr('id');
            $('#addTokenModalLabel').html("View JWT")
            $("#oat-modal-body").load("@jwt_view_url;noquote@", {token_id:  id});
            $(".saveBtn").hide();
        });
    }
</script>  
