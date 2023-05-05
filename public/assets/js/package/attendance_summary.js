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


function get_selected_months_year(){
    var usePath    = $.trim( $("#rootXPath").val() );
    var years      = $.trim( $("#hph_years").val() );
    var months     = $.trim( $("#hph_months").val() );
        $.ajax({
                     url: usePath+"city/ajax_process",
                     type: 'POST',
                     data: {'years': years,'months':months,'identity':'DMY' },
                     async: false,
                     success: function (resp) {
                             if( resp.status ){
                                $("#uptodate").val(resp.enddated);
                                $("#fromdate").val(resp.startdated);
                             }else{
                                $("#uptodate").val('');
                                $("#fromdate").val('');
                             }               
                        
                     },
                     error: function () {

                     },
                     cache: false
         });


}

function printToExcel(tabled, filename){
    var downloadurl;
    var fileType    = 'application/vnd.ms-excel';
     var tableSelect = document.getElementById(tabled);
     var dataHTML    = tableSelect.outerHTML.replace(/ /g, '%20');
     filename        = filename?filename+'.xls':'attendance_summary_report.xls';
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
function posting_attendance_summary(){
    var useroot = $("#rootXPath").val();
    $("#postdata").val("Y");
    $(".notprocessdone").removeClass("hidden");
    $(".processdone").removeClass("hidden").addClass("hidden");
    $("form#myforms").attr("action",useroot+"attendance_summary/search");   
    $("form#myforms").submit();
}
function filter_attendance_summary(){
    var useroot = $("#rootXPath").val();
    var d1      = $("#fromdate").val();
    var d2      = $("#uptodate").val();
    $("#postdata").val("");
    var depcdoe = $("#sewadar_departments").val();
    if( depcdoe == ''){
        alert("Department is required.");
        $("#sewadar_departments").focus();
        return false;  
    }
    if( d1 == ''){
        alert("From date is required.");
        $("#fromdate").focus();
        return false;
    }
    if( d2 == ''){
        alert("Upto date is required.");
        $("#uptodate").focus();
        return false;
    }
    var date1 = new Date(d1);
    var date2 = new Date(d2);
    if( date1 >date2 ){
        $("#uptodate").val('');
        $("#uptodate").focus();
        alert("Upto date should be greater than from date");
        return false;
    }
    $("form#myforms").attr("action",useroot+"attendance_summary/search");   
    $("form#myforms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function get_districtcode_by_states(){
            var usePath    = $.trim( $("#rootXPath").val() );
            var statecode  = $.trim( $("#ct_statecode").val() );

             $.ajax({
                             url: usePath+"city/ajax_process",
                             type: 'POST',
                             data: {'statecode': statecode,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.dts_districtcode+'">'+leds.dts_districtcode+'</option>';
                                         i++;
                                    });
                              }
                              $("#ct_districtcode").html(mhtml);
                             },
                             error: function () {
                                 
                             },
                             cache: false
                 });

    
}

// $("#fromdate").click(function() {
//     $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
//  });

//  $("#uptodate").click(function() {
//     $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
//  });

 function get_all_sewadar_by_department(){
    var usePath  = $.trim( $("#rootXPath").val() );
    var depcode  = $.trim( $("#sewadar_departments").val() );
   
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'depcode': depcode,'loantype':'ATDNC','identity':'Y'},
                     async: false,
                     success: function (resp) {
                       var sdata = resp.data;
                       var vdata = resp.sedarname
                       var mhtml  = '<option value="">-Select-</option>';
                       var vhtml  = '<option value="">-Select-</option>';

                       var i = 1;
                      if(sdata.length >0 ){
                             $.each(sdata,function(key,leds){
                                 mhtml +='<option value="'+leds.sw_sewcode+'">'+leds.sw_sewcode+' ('+leds.sw_sewcode+') </option>';
                                 i++;
                            });

                             $.each(sdata,function(key,led){
                                 vhtml +='<option value="'+led.sw_sewcode+'">'+led.sw_sewadar_name+' ('+led.sw_sewcode+') </option>';
                                 
                            });
                      }
                       $("#al_sewadarcode").html(mhtml);
                       $("#myemployee").html(vhtml);
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