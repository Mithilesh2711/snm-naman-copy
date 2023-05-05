function isFloatNegativeKey(e,vls){

	  if (e.charCode >= 32 && e.charCode < 127 && !/^-?\d*[.,]?\d*$/.test(vls + '' + String.fromCharCode(e.charCode)))
	  {
		return false;
	  }
	  return true;
}

function isNumberFloatKey(evt)
 {
	  var charCode = (evt.which) ? evt.which : evt.keyCode;
	  if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)){
		  return false;
	  }
	  return true;
   }

function isNumberKeys(evt) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    }
    return true;
}

function filter_approval_leaves(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"co_od/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function process_change_approved_status(empcode,leavecode,leavstatus,id){
    var usePath          = $.trim( $("#userXRoot").val() );
    var formData         = new FormData();    
    formData.append("identity", "CHANGESTATUS");
    formData.append("leavecode", leavecode);
    formData.append("sewadarcode", empcode);
    formData.append("leaveid", id);
    formData.append("leavestatus", leavstatus);

        $.ajax({
                     url: usePath+"request_co_od/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         if( resp.status){
                             if( leavstatus == 'P'){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-purple"></i> Pending ');
                                $("#changemy_status"+id).html('Pending');
                              }else if(  leavstatus == 'A'){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-success"></i> Approved ');
                                $("#changemy_status"+id).html('Approved');
                              }else if(  leavstatus == 'D'){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-danger"></i> Rejected ');
                                $("#changemy_status"+id).html('Rejected');
                              }else if(  leavstatus == ''){
                                $("#selected_status"+id).html('<i class="fa fa-dot-circle-o text-info"></i> Pending ');
                              }
                              alert(resp.message);
                         }else{
                              $("#selected_status"+id).html('Pending')
                              alert(resp.message);
                         }

                     },
                     error: function () {
                        $("#selected_status"+id).html('Pending')
                     },
                     cache: false
             });
}



 $("#search_fromdated").click(function() {
          $(this).datepick({ dateFormat: "dd/mm/yyyy" ,onSelect:function(evt){ } }).datepick("show");
       });

        $("#search_uptodated").click(function() {
           $(this).datepick({ dateFormat: "dd/mm/yyyy" ,onSelect:function(evt){} }).datepick("show");
       });

