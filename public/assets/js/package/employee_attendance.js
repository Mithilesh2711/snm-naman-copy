
function fill_from_sewadar_listed_fillcode(){

    var empcode  = $.trim( $("#emp_listed option:selected").val() );
    var names    = $.trim( $("#emp_listed option:selected").text() );
   
    $("#myselected_codes").html(empcode);
    $("#myselected_names").html(names);

}





function search_employee_attendance(){
    var usePath = $.trim( $("#rootXPath").val() );
    var selectemp = $.trim( $("#emp_listed").val() );
    var department = $.trim( $("#emp_department").val() );
    var frmdate   = $.trim( $("#from_dates").val() );
    var uptodate  = $.trim( $("#upto_dates").val() );

    if( department == ''){
        alert("Department is required.");
        $("#emp_department").focus() ;
        return false;
     }else if( selectemp == ''){
        alert("Sewadar name is required.");
        $("#emp_listed").focus() ;
        return false;    
    }else if( frmdate == '' ) {
        alert("From Date is required.");
        $("#from_dates").focus() ;
        return false; 
    }else if( uptodate == ''){
        alert("Upto date is required.");
        $("#upto_dates").focus() ;
        return false;
    }
    $("form#myForms").attr('action',usePath+"employee_attendance/search");
    $("form#myForms").submit();
 }
 function process_attend_dashboard_summary(){
    var usePath   = $.trim( $("#rootXPath").val() );
       var vls    = ""
       if( $("input[name='radiodetail']").is(":checked") ){
         vls = $("input[name='radiodetail']:checked").val();
       }
       $("#processdetail").val(vls);
       $("form#myForms").attr("action",usePath+"employee_attendance/search");
       $("form#myForms").submit();

}
 function get_all_sewadar_by_department(){
    var usePath  = $.trim( $("#rootXPath").val() );
    var depcode  = $.trim( $("#emp_department").val() );

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
                       $("#emp_listed").html(vhtml);
                     },
                     error: function () {

                     },
                     cache: false
         });


}



function fill_from_sewadar_listed(types){
    var usePath  = $.trim( $("#rootXPath").val() );
    var sewcode  = ""
    if( types == 'code' ){
        sewcode = $.trim( $("#al_sewadarcode").val() );
    }else if( types == 'sewadar'){
         sewcode = $.trim( $("#emp_listed").val() );
    }
    
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'sewcode': sewcode,'identity':'SWCD'},
                     async: false,
                     success: function (resp) {
                         if(resp.status){
                             if( types == 'code'){
                                $("#emp_listed").val(sewcode);                                
                             }else if( types == 'sewadar'){
                                $("#al_sewadarcode").val(sewcode);
                                $(".my_dpeartmentname").html(resp.data[0].department);
                                
                               
                                
                             }
                         }else{
                                $(".my_dpeartmentname").html('');
                                $(".myjoining_dated").html('');
                                $(".mytotalworking_year").html('');
                                $(".mytotalout_standing").html('');
                                $("#myjoining_dated").val('');
                                $("#ls_referencecode").val('');                               
                                alert("No record(s) found.");
                         }


                     },
                     error: function () {
                               $(".my_dpeartmentname").html('');
                                $(".myjoining_dated").html('');
                                $(".mytotalworking_year").html('');
                                $(".mytotalout_standing").html('');
                                $("#myjoining_dated").val('');
                                $("#ls_referencecode").val('');
                     },
                     cache: false
         });
}

$("#from_dates").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});
$("#upto_dates").click(function() {

    $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

});