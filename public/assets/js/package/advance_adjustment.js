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

$("#trns_dated").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){} }).datepick("show");
});
function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function check_total_outstanding(){
    var ajustment      = $.trim( $("#trns_change").val() ) !='' ?  $.trim( $("#trns_change").val() ) : 0;
    var curoutstanding = $.trim( $("#trns_old").val() ) !='' ? $.trim( $("#trns_old").val() ) : 0;
    if( parseFloat(ajustment) >parseFloat(curoutstanding) && parseFloat(ajustment) >0 ){
        alert("Adjustment amount should not be greater than current outstanding amount.");
        $("#trns_change").val('');
        $("#trns_change").focus();  
        return false;
    }
}

function get_installment_amount(){
    var usePath     = $.trim( $("#rootXPath").val() );
    var empcode     = $.trim( $("#al_sewadarcode").val() );
    var requestno   = $.trim( $("#trns_type").val() );

    $.ajax({
                 url: usePath+"advance_adjustment/ajax_process",
                 type: 'POST',
                 data: {'empcode': empcode,'requestno':requestno,'identity':'COAMT'},
                 async: false,
                 success: function (resp) {
                   var sdata = resp.data;                     
                   if( resp.status ){
                       $("#trns_old").val(sdata.al_balances);
                   }else{
                       $("#trns_old").val(''); 
                   }
                   
                 },
                 error: function () {
                     $("#trns_old").val(''); 
                 },
                 cache: false
     });


}


function get_all_sewadar_requestno(){
        var usePath  = $.trim( $("#rootXPath").val() );
        var empcode  = $.trim( $("#al_sewadarcode").val() );

        $.ajax({
                     url: usePath+"advance_adjustment/ajax_process",
                     type: 'POST',
                     data: {'empcode': empcode,'identity':'REQNO'},
                     async: false,
                     success: function (resp) {
                       var sdata = resp.data;                     
                       var mhtml = '<option value="">-Select-</option>';                 

                       var i = 1;
                      if(sdata.length >0 ){
                             $.each(sdata,function(key,leds){
                                 mhtml +='<option value="'+leds.al_requestno+'">'+leds.al_requestno+'</option>';
                                 i++;
                            });

                      }
                       $("#trns_type").html(mhtml);
                       
                     },
                     error: function () {

                     },
                     cache: false
         });


}
function filter_installment(){
    var useroot = $("#rootXPath").val();
    $("form#myforms").attr("action",useroot+"advance_adjustment/search");   
    $("form#myforms").submit();
}

function get_common_option_listed(){
    var usePath  = $.trim( $("#rootXPath").val() );
    var sewcode  = $.trim( $("#al_sewadarcode").val() );
    var types    = $.trim( $("#trns_type").val() );
    if( types == 'Extension' ){
        $(".extenstion").removeClass("hidden");
        $(".othertextenstion").removeClass("hidden").addClass("hidden");
    }else{
        $("#extenstion").val('');
        $(".extenstion").removeClass("hidden").addClass("hidden");
        $(".othertextenstion").removeClass("hidden");
    }
     $.ajax({
                     url: usePath+"transactions/ajax_process",
                     type: 'POST',
                     data: {'sewcode': sewcode,"type":types,'identity':'Y'},
                     async: false,
                     success: function (resp) {
                         var nhtml = '<option value="">-Select -</option>';
                         if(resp.status){
                              var sdata = resp.data;
                                if( types == 'Department' ){
                                    if(sdata.length >0 ){
                                        $.each(sdata,function(key,leds){
                                            nhtml +='<option value="'+leds.departCode+'">'+leds.departDescription+'</option>';
                                           
                                       });
                                    }
                                    $("#trns_old").val(resp.department);
                                }else if( types == 'Designation' ){
                                    if(sdata.length >0 ){
                                        $.each(sdata,function(key,leds){
                                            nhtml +='<option value="'+leds.desicode+'">'+leds.ds_description+'</option>';
                                           
                                       });
                                    }
                                    $("#trns_old").val(resp.designation);
                                    
                                }else if( types == 'Category' ){
                                    if(sdata.length >0 ){
                                        $.each(sdata,function(key,leds){
                                            nhtml +='<option value="'+leds.sc_catcode+'">'+leds.sc_name+'</option>';
                                           
                                       });
                                    }                             
                                    $("#trns_old").val(resp.category);
                                }else if(  types == 'Extension' ){
                                   
                                    $("#trns_old").val(resp.superannuat);
                                    
                                }
                                
                                $("#trns_change").html(nhtml);
                         }else{
                                $("#trns_change").html('<option value="">-Select -</option>');
                                $("#trns_old").val('');
                                
                         }


                     },
                     error: function () {
                        $("#trns_old").val('');
                        $("#trns_change").html('<option value="">-Select -</option>');     
                     },
                     cache: false
         });
}


function print_salary_excel_register(){
   
    var usePath      = $.trim( $("#userXRoot").val() );
    var years        = '';
    var months       = '';
    var sedep        = $.trim( $("#sewadar_departments").val() );
    var sewcatg      = '';
    var refecoename  = '';
    var sewsearches  = '';
    var printurl     = $.trim( $("#printexceled").attr("rel") );
    var types        = $("input[name='monthly_deduction']:checked").val();
    var sewacode     =  $.trim( $("#alsewdarname").val() );
    if( sewacode == ''){
        alert("Please select sewadar name or code");
        $("#alsewdarname").focus();
        return false;
    }
     $.ajax({
                 url: usePath+"all_formats/ajax_process",
                 type: 'POST',
                 data: {'sewacode':sewacode,'years': years,'months':months,'types':types,'sedep':sedep,'sewcatg':sewcatg,'refecoename':refecoename,'sewsearches':sewsearches,'identity':'Y'},
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
            if( types == 'code' ){
                sewcode = $.trim( $("#al_sewadarcode").val() );
            }else if( types == 'sewadar'){
                 sewcode = $.trim( $("#alsewdarname").val() );
            }
            var catname  = '';
             var result  = '';
             var catcode = '';
             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'identity':'SWCD'},
                             async: false,
                             success: function (resp) {
                                 if(resp.status){
                                     if( types == 'code'){
                                        $("#alsewdarname").val(sewcode);
                                       
                                     }else if( types == 'sewadar'){
                                        $("#al_sewadarcode").val(sewcode);
                                       
                                        
                                     }
                                 }else{
                                   
                                        alert("No record(s) found.");
                                 }


                             },
                             error: function () {
                                      
                             },
                             cache: false
                 });
                 setTimeout(function(){ get_all_sewadar_requestno();},500);
}

function selectedSubjectName() {
    var subjectIdNode = $("#trns_type").val();
    $(".change_detail").text(subjectIdNode);
    get_common_option_listed();
   
 }
