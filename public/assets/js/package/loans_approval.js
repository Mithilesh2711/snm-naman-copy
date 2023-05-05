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

function filter_loans_approval(){
    var useroot = $("#userXRoot").val();
    var approvedby = $("#approvedby").val();
    var deptcode   = $("#voucher_department").val();
  
    if( approvedby != '' ){
        if( deptcode == '' ){
          alert("Department is required");
          return false;
        }
     }
    $("form#myForms").attr("action",useroot+"loans_approval/search");
    $("form#myForms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function process_approval_request(requestno,postatus){
              var usePath  = $.trim( $("#rootXPath").val() );
              var myremark = $.trim( $("#my_selected_remark"+requestno).val() );
              var ishod    = $.trim( $("#approvedby").val() );
              if( postatus == 'R'){
                  if( myremark == ''){
                      alert("Remark is required.");
                      $("#my_selected_remark"+requestno).focus();
                      return false;
                  }
              }
             
              $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'requestno':requestno,'myremark':myremark,'postatus':postatus,'identity':'LOANREQT'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                    alert(resp.message);
                                    if( ishod =='ec' || ishod =='cod' ){
                                        if( postatus == 'H' ){
                                            $("#requestloanid"+requestno).html('<i class="fa fa-dot-circle-o text-purple"></i> Hold')
                                        }else if( postatus == 'A'){
                                            $("#requestloanid"+requestno).html('<i class="fa fa-dot-circle-o text-success"></i> Forward To HR')
                                        }else if( postatus == 'R'){
                                            $("#requestloanid"+requestno).html(' <i class="fa fa-dot-circle-o text-danger"></i> Reject')
                                        }

                                   }else{
                                        if( postatus == 'H' ){
                                            $("#requestloanid"+requestno).html('<i class="fa fa-dot-circle-o text-purple"></i> Hold')
                                        }else if( postatus == 'A'){
                                            $("#requestloanid"+requestno).html('<i class="fa fa-dot-circle-o text-success"></i> Approve')
                                        }else if( postatus == 'R'){
                                            $("#requestloanid"+requestno).html(' <i class="fa fa-dot-circle-o text-danger"></i> Reject')
                                        }
                                    }    
                                    
                                 }else{
                                      alert(resp.message);
                                 }
                                 

                             },
                             error: function () {
                                      
                             },
                             cache: false
                 });
}


   