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
function check_apply_educations(){
    var vls = ""
    if( $("input[name='foraccordingdate']").is(":checked") ){
        vls = $("input[name='foraccordingdate']:checked").val();
    }
   
    $("#requestaccording").val(vls);
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
   
    $("form#myForms").attr("action",useroot+"apply_educationaid/search");   
    $("form#myForms").submit();
}

function get_changes_onselected(){
    var names = $.trim( $("#ama_dependent option:selected").text() );
    $("#mydependentedlist").val(names);
    
}
function process_update_remarks(){
    var useroot  = $("#rootXPath").val();
    var status   = $("#aea_status").val();
    var rmks     = $.trim($("#aea_remark").val() );
    if( status == 'R'){
        if(rmks == ''){
            alert("Please enter remark");
            $("#aea_remark").focus(); 
            return false;
        }
    }
    $("#updateremark").val("RMK");
    $("form#myForms").attr("action",useroot+"apply_educationaid");
    $("form#myForms").submit();
}
function selected_education_option(){
        var useroot = $("#rootXPath").val();
        if( $("input[name='education_listed']").is(":checked") ){
         
            var opval =  $("input[name='education_listed']:checked").val();
            $("#filteroption").val(opval);
           
        }else{
            $("#filteroption").val('A'); 
        }
        // $("#search_from_date").val('');
        // $("#search_upto_date").val('');
        $("form#myForms").attr("action",useroot+"apply_educationaid/educationaid_list");
        $("form#myForms").submit();

}
function filter_education_listed(){
    var useroot = $("#rootXPath").val();
    $("form#myForms").attr("action",useroot+"apply_educationaid/educationaid_list");
    $("form#myForms").submit();
}

function validate_education_forms(){
    var ama_amount = $.trim( $("#aea_amount").val() ) ? $.trim( $("#aea_amount").val() ) : 0;
    var type   = $.trim( $("#ama_applyfor").val() );
    var depent = $.trim( $("#ama_dependent").val() );

    if( ama_amount <=0 ){
        alert("Amount is required");
        $("#aea_amount").focus()
        return false;
    }
    if( type == 'dependent' ){
        if( depent == ''){
            alert("Dependent name is required");
            $("#ama_dependent").focus()
            return false;
        }
        
    }
}
function exportApprovedEducation(tabled, filename){
    var downloadurl;
    var fileType    = 'application/vnd.ms-excel';
     var tableSelect = document.getElementById(tabled);
     var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
     filename        = filename?filename+'.xls':'approved_education.xls';
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


function print_salary_excel_register(newid){
   
    var usePath      = $.trim( $("#rootXPath").val() );   
    var printurl     = $.trim( $("#printexceled"+newid).attr("rel") );   
 
     $.ajax({
                 url: usePath+"all_formats/ajax_process",
                 type: 'POST',
                 data: { 'printsewacode':newid,'identity':'Y' },
                 async: false,
                 success: function (resp) {
                      if(resp.status){                     
                            window.open(usePath+printurl, '_blank');
                      }else{
                            alert("No record(s) found.");
                            return false;
                      }
                 },
                 error: function () {

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

function get_apply_aidamts(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var sewacode   = $.trim( $("#al_sewadarcode").val() );
    var types      = $.trim( $("#ama_applyfor").val() );
    var forclass   = $.trim( $("#aea_forclass").val() );
     $.ajax({
                     url: usePath+"apply_educationaid/ajax_process",
                     type: 'POST',
                     data: {'sewacode': sewacode,'types':types,'forclass':forclass,'identity':'Y'},
                     async: false,
                     success: function (resp) {
                        if ( resp.data !='' ){
                             $("#aea_amount").val(resp.data);
                        }else{
                              $("#aea_amount").val('');
                                if ( resp.catcode == 'VIT'){
                                    alert("Sewadar should be completed 3 years sewa for apply.");
                                }else if ( resp.catcode == 'SDP'){
                                     alert("Sewadar should be completed 1 year sewa for apply.");
                                }
                        }
                            
                        
                       
                     },
                     error: function () {
                        $("#aea_amount").val('');
                     },
                     cache: false
         });


}

function get_dependent_listed(){
    var usePath   = $.trim( $("#rootXPath").val() );
    var sewacode  = $.trim( $("#al_sewadarcode").val() );
    var type      = $.trim( $("#ama_applyfor").val() );

    
    $("#aea_amount").val('');
    $("#aea_forclass").val('');

    if( type == 'dependent' ){
        $("#ama_dependent").prop("required",true)
    }else{

        $("#ama_dependent").prop("required",false)
    }

    var mhtml     = '<option value="">-Select-</option>'; 
    if( type != 'dependent' ){
        $("#ama_dependent").html(mhtml);
        $(".mydependentlist").removeClass("hidden").addClass("hidden");
        return false;
    }else{
        $(".mydependentlist").removeClass("hidden");
    }
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'sewacode': sewacode,'type':type,'identity':'DEPEND'},
                     async: false,
                     success: function (resp) {
                                        
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


}


    function get_all_sewadar_by_department(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var depcode  = $.trim( $("#al_depcode").val() );
           
            $("#aea_amount").val('');
            $("#aea_forclass").val('');
            $("#ama_applyfor").val('');
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
            if( types == 'code'){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar'){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            $("#aea_amount").val('');
            $("#aea_forclass").val('');
            $("#ama_applyfor").val('');
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

  