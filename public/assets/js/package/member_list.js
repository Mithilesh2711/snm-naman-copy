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
function ValidateEmail(email) {
    var expr = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
    return expr.test(email);
}
function add_retirement_dated(){
    var usePath     = $.trim( $("#rootXPath").val() );
    var birthdate   = $.trim( $("#lds_dob").val() );

    $.ajax({
                    url: usePath+"sewadar_information/ajax_process",
                    type: 'POST',
                    data: {'birthdate': birthdate,'identity':'BIRTHCALC'},
                    async: false,
                    success: function (resp) {
                        if ( resp.status ){
                            var sdata = resp.data;
                            var sages = resp.ages.split(" ")
                            
                            if( parseInt(sages[0]) <18 || sages[0] == ''){
                                   alert("Age should be greater than or equal to 18 years");
                                   $("#lds_dob").val('');                                   
                                   $("#lds_dob").focus();
                                   return false;
                            }
                        }


                    },
                    error: function () {
                          
                    },
                    cache: false
        });
}

function validate_pan_adhaar(){
        var adhar = $.trim( $("#emp_adhar_no").val() );
        var pan   = $.trim( $("#emp_pano").val() );
        if( adhar !='' ){
            if( adhar.length <12 ){
                alert("Aadhaar number should be 12 digits.");
                return false;
            }
            
        }
        if( pan !='' ){
            if( pan.length <10 ){
                alert("PAN should be 10 digits.");
                return false;
            }
            
        }
}
function get_my_sub_location(){
    var usePath     = $.trim( $("#rootXPath").val() );
    var locations    = $.trim( $("#lds_location").val() );

    $.ajax({
                    url: usePath+"sewadar_information/ajax_process",
                    type: 'POST',
                    data: {'locations': locations,'identity':'SUBLOC'},
                    async: false,
                    success: function (resp) {
                         var vhtml = '<option value="">-Select-</option>';
                        if ( resp.status ){
                            var sdata = resp.data;
                            $.each(sdata,function(key,leds){
                                  vhtml +='<option value="'+leds.id+'">'+leds.sl_description+'</option>';
                            });
                        }
                        $("#lds_sublocation").html(vhtml);

                    },
                    error: function () {
                      $("#lds_sublocation").html('<option value="">-Select-</option>');
                    },
                    cache: false
        });
}
function get_source_image(){
//
//    var imgsrc = $("#item-img-output").attr("src");
//    $("#attachpropfile").val(imgsrc);
}
$(document).on("click","#myminus",function(){

       var id    = $(this).attr("rel");

       var filid = $.trim( $("#myreceivedocumentid"+id).val() );

       $("#duplicate"+id).addClass("hidden");

       $("#removefiles"+id).val(filid);

});
function filter_member_list(){
    var useroot = $("#userXRoot").val();
    var ldsmeb  = $("#newlds_type").val();   
    $("form#myforms").attr("action",useroot+"member_list/search?member="+ldsmeb);
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
$("#lds_dob").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){ add_retirement_dated();} }).datepick("show");
});
