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

function filter_allotment(){
    var useroot = $("#rootXPath").val();
    $("form#myForms").attr("action",useroot+"accomodation_allotment/search");
    $("form#myForms").submit();
}
function alertChecked(url){
    if( confirm("Are you sure want to cancel ?")){
        window.location = url
    }
}


    $("#aa_alotmentdate").click(function() {
       $(this).datepick({ dateFormat: "dd/mm/yyyy" }).datepick("show");
    });


    function get_all_sewadar_by_department(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var depcode  = $.trim( $("#al_depcode").val() );

             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'depcode': depcode,'identity':'Y'},
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

                                     $.each(vdata,function(key,led){
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

                                     }else if( types == 'sewadar'){
                                         $("#al_sewadarcode").val(sewcode);
                                        $(".my_dpeartmentname").html(resp.data[0].department);
                                        $(".myjoining_dated").html(resp.data[0].joiningdate);
                                        $(".mytotalworking_year").html(resp.data[0].sewduration);
                                        $(".mytotalout_standing").html(resp.data[0].outstatnding);
                                     }
                                 }else{
                                        $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                                        alert("No record(s) found.");
                                 }


                             },
                             error: function () {
                                       $(".my_dpeartmentname").html('');
                                        $(".myjoining_dated").html('');
                                        $(".mytotalworking_year").html('');
                                        $(".mytotalout_standing").html('');
                             },
                             cache: false
                 });
}

  function check_validities(){
            var al_depcode     = $.trim( $("#al_depcode").val() );
            var al_sewadarcode = $.trim( $("#al_sewadarcode").val() );
            var aa_address     = $.trim( $("#aa_address").val() );
            var counts = 0;
            if( al_depcode == ''){
                counts = 1
            }
            if( al_sewadarcode == ''){
                 counts = 1
            }
            if( aa_address == ''){
                counts = 1
            }          
           
          
            if( counts <=0 ){
                $(".process_save").hide();
            }

  }

   function get_accomodation_address(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var types    = $.trim( $("input[name='aa_addtype_1']:checked").val() );
            $("#aa_addtype").val(types);
            
             $.ajax({
                             url: usePath+"accomodation_allotment/ajax_process",
                             type: 'POST',
                             data: {'types': types,'identity':'Y'},
                             async: false,
                             success: function (resp) {
                                 var mhtml = '<option value="">-Select-</option>';
                                 if( resp.status ){
                                       var sdata = resp.data;
                                       
                                       var i = 1;
                                      if(sdata.length >0 ){
                                             $.each(sdata,function(key,leds){
                                                 mhtml +='<option value="'+leds.id+'">'+leds.ad_address+'</option>';
                                                 i++;
                                            });
                                      }
                                 }
                               $("#aa_address").html(mhtml);
                              
                             },
                             error: function () {

                             },
                             cache: false
                 });


}

function get_detail_accomodation_address(){
            var usePath  = $.trim( $("#rootXPath").val() );
            var adid     = $.trim( $("#aa_address").val() );
             $.ajax({
                             url: usePath+"accomodation_allotment/ajax_process",
                             type: 'POST',
                             data: {'adid': adid,'identity':'DDLIST'},
                             async: false,
                             success: function (resp) {
                                 if( resp.status ){
                                      var sdata = resp.data;
                                      $(".lb_accomtype").html(sdata[0].accomotype);
                                      $(".lb_city").html(sdata[0].districts);
                                      $(".lb_state").html(sdata[0].states);
                                      $(".lb_noofrooms").html(sdata[0].ad_noofrooms);
                                      $(".lb_kitchentype").html(sdata[0].ad_typeofkitechen);
                                      $(".lb_washeroomtype").html(sdata[0].ad_typeofwashroom);
                                      $(".process_show_address").removeClass("hidden");
                                     
                                 }else{
                                      $(".lb_accomtype").html('');
                                      $(".lb_city").html('');
                                      $(".lb_state").html('');
                                      $(".lb_noofrooms").html('');
                                      $(".lb_kitchentype").html('');
                                      $(".lb_washeroomtype").html('');
                                      $(".process_show_address").removeClass("hidden").addClass("hidden");
                                 }
                               

                             },
                             error: function () {
                                     $(".lb_accomtype").html('');
                                      $(".lb_city").html('');
                                      $(".lb_state").html('');
                                      $(".lb_noofrooms").html('');
                                      $(".lb_kitchentype").html('');
                                      $(".lb_washeroomtype").html('');
                                      $(".process_show_address").removeClass("hidden").addClass("hidden");
                             },
                             cache: false
                 });


}