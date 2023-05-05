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

$("#search_from_date").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
 });

  $("#search_upto_date").click(function() {
     $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){} }).datepick("show");
 });
function filter_approval(){
    var useroot = $("#rootXPath").val();
    var approvedby = $("#approvedby").val();
    var deptcode   = $("#voucher_department").val();
    var userslogin = $("#userslogin").val();    
    $("form#myForms").attr("action",useroot+"apply_marriageaid/search");   
    $("form#myForms").submit();
}

function process_update_remarks(){
    var useroot = $("#rootXPath").val();
    $("#updateremark").val("RMK");
    $("form#myForms").attr("action",useroot+"apply_marriageaid");
    $("form#myForms").submit();
}

function get_apply_aidamts(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var sewacode   = $.trim( $("#al_sewadarcode").val() );
    var types      = $.trim( $("#ama_applyfor").val() );
    var dependent  = $.trim( $("#ama_dependent").val() );
  
     $.ajax({
                     url: usePath+"apply_marriageaid/ajax_process",
                     type: 'POST',
                     data: {'sewacode': sewacode,'types':types,'dependentcode': dependent,'identity':'Y'},
                     async: false,
                     success: function (resp) {
                        if ( resp.data !=''){
                            $("#ama_amount").val(resp.data);
                        }else{
                            $("#ama_amount").val('');
                        }
                        if( resp.message !=""){
                            alert(resp.message);
                            $("#ama_applyfor").val('');
                        }
                       
                     },
                     error: function () {
                        $("#ama_amount").val('');
                     },
                     cache: false
         });


}




function filter_loan_advance(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"loans_advance/search");
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to cancel ?")){
        window.location = url
    }
}
function selected_education_option(){
    var useroot = $("#rootXPath").val();
    if( $("input[name='education_listed']").is(":checked") ){     
        var opval =  $("input[name='education_listed']:checked").val();
        $("#filteroption").val(opval);       
    }else{
        $("#filteroption").val('all'); 
    }
    $("form#myForms").attr("action",useroot+"apply_marriageaid/marriageaid_list");
    $("form#myForms").submit();

}
function get_dependent_listed(){
    var usePath   = $.trim( $("#rootXPath").val() );
    var sewacode  = $.trim( $("#al_sewadarcode").val() );
    var type      = $.trim( $("#ama_applyfor").val() );
    
    if( type == 'dependent' ){
        $("#ama_dependent").prop("required",true);
        
    }else{

        $("#ama_dependent").prop("required",false)
    }

    var mhtml     = '<option value="">-Select-</option>'; 
    if( type != 'dependent' ){
        $("#ama_dependent").html(mhtml);
        $(".mydependentlist").removeClass("hidden").addClass("hidden");
        get_apply_aidamts();
        return false;
    }else{
        $(".mydependentlist").removeClass("hidden");
    }
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'sewacode': sewacode,'type':type,'mariagetpe':'Y','identity':'DEPEND'},
                     async: false,
                     success: function (resp) {
                        $("#ama_amount").val('');                
                       var i      = 1;
                       if( resp.status ){
                       var sdata = resp.data;
                        if(sdata.length >0 ){
                                $.each(sdata,function(key,leds){
                                    mhtml +='<option value="'+leds.id+'">'+leds.skf_dependent+'</option>';
                                    i++;
                                });

                           }
                         }
                        
                       $("#ama_dependent").html(mhtml);
                       
                     },
                     error: function () {

                     },
                     cache: false
         });
        // get_apply_aidamts();

}


    function get_all_sewadar_by_department(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var depcode  = $.trim( $("#al_depcode").val() );

             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'depcode': depcode,'loantype':'MAPED','identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var vdata = resp.sedarname
                               var mhtml  = '<option value="">-Select-</option>';
                               var vhtml  = '<option value="">-Select-</option>';

                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewcode+'</option>';
                                         i++;
                                    });

                                     $.each(sdata,function(key,led){
                                         vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+'</option>';
                                         
                                    });
                              }
                               $("#al_sewadarcode").html(mhtml);
                               $("#alsewdarname").html(vhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });


}

function fill_from_sewadar_listed(types){
            var usePath  = $.trim( $("#rootXPath").val() );
            var sewcode  = ""
            var chtml  = '<option value="">-Select-</option>';
            if( types == 'code'){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar'){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            $("#ama_applyfor").val('');
            $("#ama_dependent").html(chtml);
            $("#ama_amount").val('');
            $("#ama_remark").val('');
             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'identity':'SWCD'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                     if( types == 'code'){
                                        $("#alsewdarname").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);

                                     }else if( types == 'sewadar'){
                                         $("#al_sewadarcode").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                        $("#myjoining_dated").val(resp.data[0].joiningdate);
                                     }
                                 }else{
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                                        alert("No record(s) found.");
                                 }
                              
                               
                             },
                             error: function () {
                                       $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        $("#myjoining_dated").val('');
                             },
                             cache: false
                 });
}



function exportDataToExcel(tabled, filename){
          var downloadurl;
          var fileType    = 'application/vnd.ms-excel';
           var tableSelect = document.getElementById(tabled);
           var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
           filename        = filename?filename+'.xls':'advance_loan_request.xls';
           downloadurl     = document.createElement("a");
           document.body.appendChild(downloadurl);

            if(navigator.msSaveOrOpenBlob){
                         var blob = new Blob(['\ufeff', dataHTML],{type:  fileType });
                         navigator.msSaveOrOpenBlob( blob, filename);
                }else
                  {
                           downloadurl.href = 'data:' + fileType + ', ' + dataHTML;
                           downloadurl.download = filename;
                           downloadurl.click();
                  }

  }
