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

function check_student_unversity(){
    var types = $.trim( $("#skf_occupation1").val() );
    
    if( types == 'STUDENT' ){
        $(".selecteduniversity").removeClass("hidden");
       
    }else{
        $("#skf_university1").val('');
        $(".selecteduniversity").removeClass("hidden").addClass("hidden");
     }
}

function get_accomodation_addresstype(){
    var accomodtype = $.trim( $("#sk_accomodations").val() );
    if( accomodtype == 'Y' ){
        $(".allowaccommodatype").removeClass("hidden");
    }else{
         $("#sk_accomotype").val('');
        $(".allowaccommodatype").removeClass("hidden").addClass("hidden"); 
    }
}

function change_selected_health_policy(){
   var vls =  $("#so_healthinsurances").val();
   if( vls == 'N'){
        $("#so_healthslab").val('');
   }
}

function check_isfamily_related_sewadar(vl){
    var vls = $.trim( $("#skf_sewadar_code_prev").val() );
    if( vl == 'Y' ){
        $(".my_selected_sewadar").removeClass("hidden");
        $("#skf_sewadar_code_1").val(vls);
    }else{
        $("#skf_sewadar_code_1").val('');
        $(".my_selected_sewadar").removeClass("hidden").addClass("hidden");
    }
    
}

function ValidateEmail(email) {
        var expr = /^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/;
        return expr.test(email);
   }
   function check_email_validation(email,id){
       if (!ValidateEmail(email )) {
            alert("Invalid email address.");
            $("#"+id).val('');
            $("#"+id).focus();
        }else {
            
        }
   }
   function set_last_focus(id){
       $("#"+id).focus();
   }
   function check_electric_meters(){
	   var types     = $.trim( $("#sk_electricconsumption").val() );
	   var prvsmeter = $.trim( $("#previous_meterno").val() );
	   if( types == 'Y'){
		   $(".process_electric_meter").removeClass("hidden");
		   $("#sw_meterno").val(prvsmeter);
	   }else{
		   $(".process_electric_meter").removeClass("hidden").addClass("hidden");
		   $("#sw_meterno").val('');
	   }
   }

 $("#sw_date_of_birth").ready(function() {
        $(window).keydown(function(event){     
            if(event.keyCode == 13) {           
                add_retirement_dated();
            }
        });
  });
  
function process_on_changed(){
     add_retirement_dated();
}

function check_numbers_myset(numbers,type,id){
        if( type == 'P' ){
            if( numbers.length <10 ){
                alert("Pan number should be equal to 10 digits.");
                setTimeout(function(){set_last_focus(id);},500);
                return false;
            }
        }else if( type == 'A' ){
            if( numbers.length <12 ){
                alert("Aadhaar number should be equal to 12 digits.");
                setTimeout(function(){set_last_focus(id);},500);
                return false;
            }
        }
}
function reset_familiy_contents_rowise(){
        $("#familyfooterid1").val('');
        $("#skf_dependent1").val('');
        $("#skf_relation1").val('') ;
        $("#skf_gender1").val('') ;
        $("#skf_datebirth1").val('');
        $("#skf_occupation1").val('');
        $("#skf_optedpolicy1").val('');
        $("#skf_pannumber1").val('') ;
        $("#skf_attachment1").val('') ;
        $("#currattachment1").val('');
        $("#skf_percentage1").val('');
        $("#skf_nominee1").val('N');
        $("#skf_nomineebank1").val('');
        $("#oldestpercentage1").val('');
        $("#oldestnomineebank1").val('');
        $("#skf_married_status1").val('');
        $("#skf_working_with_snm1").val('');
        $("#skf_sewadar_code1").val('') ;
        $("#skf_family_dependent1").val('');
        $("#skf_others1").val('');
        $("#skf_university1").val('');
        $(".relatioship_others").removeClass("hidden").addClass("hidden");
        $(".my_selected_sewadar").removeClass("hidden").addClass("hidden");
        $("#skf_sewadar_code_prev").val('');
        $(".process_familylst_save").show();
}
function get_edited_family_list_detail(id){
        var mid               = $.trim( $("#familyfooterid"+id).val() );
        var skf_dependent1    = $.trim( $("#skf_dependent"+id).val() );
        var skf_relation1     = $.trim( $("#skf_relation"+id).val() );
        var skf_gender1       = $.trim( $("#skf_gender"+id).val() );
        var skf_datebirth1    = $.trim( $("#skf_datebirth"+id).val() );
        var skf_occupation1   = $.trim( $("#skf_occupation"+id).val() );
        var skf_optedpolicy1  = $.trim( $("#skf_optedpolicy"+id).val() );
        var skf_pannumber1    = $.trim( $("#skf_pannumber"+id).val() );
        var currattachment1   = $.trim( $("#currattachment"+id).val() );
        var skf_percentage1   = $.trim( $("#skf_percentage"+id).val() );
        var skf_nominee1      = $.trim( $("#skf_nominee"+id).val() );
        var skf_nomineebank1  = $.trim( $("#skf_nomineebank"+id).val() );

        var skf_married_status1    = $.trim( $("#skf_married_snmstatus"+id).val() );
        var skf_working_with_snm1  = $.trim( $("#skf_workingwith_snm"+id).val() );
        var skf_sewadar_code1      = $.trim( $("#skf_sewadar_snmcode"+id).val() );
         var skf_family_depends    = $.trim( $("#skf_family_depends"+id).val() );   
         var skf_familyothers      = $.trim( $("#skf_familyothers"+id).val() );   
         var skf_university        = $.trim( $("#skf_university"+id).val() );
         var types                 = $.trim( $("#skf_occupation"+id).val() );
        if( skf_nominee1 == 'Y' ){
                $("#skf_percentage1").removeAttr("readonly");
                $("#skf_nomineebank1").removeAttr("readonly");
                $("#skf_percentage1").removeClass("input_read");
                $("#skf_nomineebank1").removeClass("input_read");
        }else{
             $("#skf_percentage1").attr("readonly",true);
             $("#skf_nomineebank1").attr("readonly",true)
             $("#skf_percentage1").removeClass("input_read").addClass("input_read");
             $("#skf_nomineebank1").removeClass("input_read").addClass("input_read");
        }
        $("#familyfooterid1").val(mid);
        $("#skf_dependent1").val(skf_dependent1);
        $("#skf_relation1").val(skf_relation1) ;
        $("#skf_gender1").val(skf_gender1) ;
        $("#skf_datebirth1").val(skf_datebirth1);
        $("#skf_occupation1").val(skf_occupation1);
        $("#skf_optedpolicy1").val(skf_optedpolicy1);
        $("#skf_pannumber1").val(skf_pannumber1) ;
        $("#currattachment1").val(currattachment1);
        $("#skf_percentage1").val(skf_percentage1);
        $("#skf_nominee1").val(skf_nominee1);
        $("#skf_nomineebank1").val(skf_nomineebank1);
        $("#oldestpercentage1").val(skf_percentage1);
        $("#oldestnomineebank1").val(skf_nomineebank1);
        
    
        if( types == 'STUDENT' ){
            $("#skf_university1").val(skf_university); 
            $(".selecteduniversity").removeClass("hidden");           
        }else{
            $("#skf_university1").val('');
            $(".selecteduniversity").removeClass("hidden").addClass("hidden");
         }

             
        $("#skf_married_status1").val(skf_married_status1);
        $("#skf_working_with_snm1").val(skf_working_with_snm1);
        $("#skf_sewadar_code1").val(skf_sewadar_code1);
        $("#skf_family_dependent1").val(skf_family_depends);
        $("#skf_others1").val(skf_familyothers);
        if( skf_relation1 == 'Other' ){
            $(".relatioship_others ").removeClass("hidden");
        }else{
            $(".relatioship_others ").removeClass("hidden").addClass("hidden");
        }

        if( skf_working_with_snm1 == 'Y' ){
            $(".my_selected_sewadar ").removeClass("hidden");
        }else{
            $(".my_selected_sewadar ").removeClass("hidden").addClass("hidden");
        }
		$("#skf_sewadar_code_prev").val(skf_sewadar_code1);


}

function process_save_family_detail_rowise(){
        var usePath           = $.trim( $("#rootXPath").val() );
        var formData          = new FormData();
        var sewcode           = $.trim( $("#sw_sewcode").val() );
        var mid               = $.trim( $("#familyfooterid1").val() );
        var skf_dependent1    = $.trim( $("#skf_dependent1").val() );
        var skf_relation1     = $.trim( $("#skf_relation1").val() );
        var skf_gender1       = $.trim( $("#skf_gender1").val() );
        var skf_datebirth1    = $.trim( $("#skf_datebirth1").val() );
        var skf_occupation1   = $.trim( $("#skf_occupation1").val() );
        var skf_optedpolicy1  = $.trim( $("#skf_optedpolicy1").val() );
        var skf_pannumber1    = $.trim( $("#skf_pannumber1").val() );
        var skf_attachment1   = $('#skf_attachment1').get(0).files[0]; ;
        var currattachment1   = $.trim( $("#currattachment1").val() );
        var skf_percentage1   = $.trim( $("#skf_percentage1").val() );
        var skf_nominee1      = $.trim( $("#skf_nominee1").val() );
        var skf_nomineebank1  = $.trim( $("#skf_nomineebank1").val() );

        var marriedstatus         = $.trim( $("#skf_married_status1").val() );
        var workingwthsnm         = $.trim( $("#skf_working_with_snm1").val() );
        var workingseacode        = $.trim( $("#skf_sewadar_code1").val() );
        var skf_family_dependent  = $.trim( $("#skf_family_dependent1").val() );
        var skf_others            = $.trim( $("#skf_others1").val() );
        var skf_university        = $.trim( $("#skf_university1").val() );

        if( skf_pannumber1 !='' ){
            if( skf_pannumber1.length <12 ){
                $("#skf_pannumber1").focus();
                alert("Aadhaar number should be 12 digits.");
                return false;
            }
        }
        
        if( sewcode == ''){
            alert("Sewadar code is required");
            $("#sw_sewcode").focus()
            return false;
        }else if( skf_dependent1 == ''){
             alert("Family dependent is required");
              $("#skf_dependent1").focus()
             return false;
        }
        if( skf_relation1 == 'Other' ){
            if( skf_others == '' ){
                alert("Other relation is required");
                $("#skf_others1").focus() 
                return false;
            }
        }
        formData.append("identity", "ADDFML");
        formData.append("familyfooterid", mid);
        formData.append("sewcode", sewcode);        
        formData.append("skf_dependent", skf_dependent1);
        formData.append("skf_relation", skf_relation1);
        formData.append("skf_gender", skf_gender1);
        formData.append("skf_datebirth", skf_datebirth1);
        formData.append("skf_occupation", skf_occupation1);
        formData.append("skf_optedpolicy", skf_optedpolicy1);
        formData.append("skf_pannumber", skf_pannumber1);
        formData.append("currattachment", currattachment1);
         if( typeof(skf_attachment1) != "undefined" ){
                 formData.append("skf_attachment", skf_attachment1);
         }else{
               formData.append("skf_attachment", '');
         }
         
        formData.append("skf_percentage", skf_percentage1);
        formData.append("skf_nominee", skf_nominee1);
        formData.append("skf_nomineebank", skf_nomineebank1);
        formData.append("marriedstatus", marriedstatus);
        formData.append("workingwthsnm", workingwthsnm);
        formData.append("workingseacode", workingseacode);
        formData.append("skf_family_dependent", skf_family_dependent);
        formData.append("skf_others", skf_others);
        formData.append("skf_university", skf_university); 
        
        

        
        $(".process_familylst_save").hide();
              $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                          var vhtml = '';
                         var typex = "'FML'";
                        if( resp.status ){
                               alert(resp.message);
                                var sdata = resp.data;
                                var i = 2
                                $.each(sdata,function(key,familydetail){
                                    var attacheds = ""
                                    if( familydetail.skf_attachment !=''){
                                        attacheds = "Attached";
                                    }
                                   vhtml +='<tr class="new_familydetail">';
                                     vhtml +='<input type="hidden" class="form-control-sm " id="familyfooterid'+i+'" value="'+familydetail.id+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " maxlength="250" id="skf_address'+i+'" value="'+familydetail.skf_address+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " id="currattachment'+i+'" value="'+familydetail.skf_attachment+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm" maxlength="50" id="skf_dependent'+i+'" value="'+familydetail.skf_dependent+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm" maxlength="50" id="skf_relation'+i+'" value="'+familydetail.skf_relation+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm" readonly maxlength="10" id="skf_gender'+i+'" value="'+familydetail.skf_gender+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " autocomplete="off"  id="skf_datebirth'+i+'" value="'+familydetail.bdate2+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " autocomplete="off"  id="skf_occupation'+i+'" value="'+familydetail.skf_occupation+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " autocomplete="off"  id="skf_optedpolicy'+i+'" value="'+familydetail.skf_optedpolicy+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " id="skf_pannumber'+i+'" value="'+familydetail.skf_pannumber+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " id="skf_nominee'+i+'" value="'+familydetail.skf_nominee+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " id="skf_percentage'+i+'" value="'+familydetail.skf_percentage+'"/>';
                                     vhtml +='<input type="hidden" class="form-control-sm " maxlength="140"  id="skf_nomineebank'+i+'" value="'+familydetail.skf_nomineebank+'"/>';
                                     
                                     
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="skf_married_snmstatus'+i+'" value="'+familydetail.skf_married_status+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="skf_workingwith_snm'+i+'" value="'+familydetail.skf_working_withsnm+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="skf_sewadar_snmcode'+i+'" value="'+familydetail.skf_working_sewacode+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="skf_university'+i+'" value="'+familydetail.skf_university+'"/>';

                                     
                                     vhtml +='<td>'+familydetail.skf_dependent+'</td>';
                                     vhtml +='<td>'+familydetail.skf_relation+'</td>';
                                     vhtml +='<td>'+familydetail.skf_otherrelation+'</td>';                                     
                                     vhtml +='<td>'+familydetail.skf_gender+'</td>';
                                     vhtml +='<td>'+familydetail.bdate2+'</td>';
                                     vhtml +='<td>'+familydetail.skf_occupation+'</td>';
                                     vhtml +='<td>'+familydetail.university+'</td>';
                                     vhtml +='<td>'+familydetail.skf_optedpolicy+'</td>';
                                     vhtml +='<td>'+familydetail.skf_working_withsnm+'</td>';
                                     vhtml +='<td>'+familydetail.skf_working_sewacode+'</td>';
                                     vhtml +='<td>'+familydetail.skf_family_dependent+'</td>';
                                     vhtml +='<td>'+familydetail.skf_pannumber+'</td>';
                                     vhtml +='<td>'+attacheds+'</td>';
                                     vhtml +='<td>'+familydetail.skf_nominee+'</td>';
                                     vhtml +='<td>'+familydetail.skf_percentage+'</td>';
                                     vhtml +='<td>'+familydetail.skf_nomineebank+'</td>';
                                     vhtml +='<td><a href="javascript:;" onclick="get_edited_family_list_detail('+i+');">Edit</a></td>';
                                     vhtml +='<td><a href="javascript:;" onclick="delete_common_items('+typex+','+familydetail.id+');">Delete</a></td>';
                                     vhtml +='</tr>';
                                    i++;
                                });
                                 $("#process_canidate_families").html(vhtml);
                                 setTimeout(function(){ reset_familiy_contents_rowise();},500);
                        }else{
                            $(".process_familylst_save").show();
                           alert(resp.message);
                        }

                     },
                     error: function () {
                         $(".process_familylst_save").show();
                     },
                     cache: false
             });
}

function reset_work_experience_items(){
        $("#workexpfooterid1").val('') ;
        $("#swe_employer1").val('') ;
        $("#swe_designation1").val('') ;
        $("#swe_responsiblity1").val('');
        $("#swe_from1").val('') ;
        $("#swe_to1").val('');
        $("#swe_reasonleaving1").val('');
        $("#swe_retirebenfit1").val('Y');
        $("#swe_gettingpension1").val('Y');
        $("#swe_medicalfacilities1").val('Y');
        $(".process_workexp_save").show();
}
function process_wrokexp_edited(id){
        var mid                    = $.trim( $("#workexpfooterid"+id).val() );
        var swe_employer1          = $.trim( $("#swe_employer"+id).val() );
        var swe_designation1       = $.trim( $("#swe_designation"+id).val() );
        var swe_responsiblity1     = $.trim( $("#swe_responsiblity"+id).val() );
        var swe_from1              = $.trim( $("#swe_from"+id).val() );
        var swe_to1                = $.trim( $("#swe_to"+id).val() );
        var swe_reasonleaving1     = $.trim( $("#swe_reasonleaving"+id).val() );
        var swe_retirebenfit1      = $.trim( $("#swe_retirebenfit"+id).val() );
        var swe_gettingpension1    = $.trim( $("#swe_gettingpension"+id).val() );
        var swe_medicalfacilities1 = $.trim( $("#swe_medicalfacilities"+id).val() );
        
        $("#workexpfooterid1").val(mid) ;
        $("#swe_employer1").val(swe_employer1) ;
        $("#swe_designation1").val(swe_designation1) ;
        $("#swe_responsiblity1").val(swe_responsiblity1);
        $("#swe_from1").val(swe_from1) ;
        $("#swe_to1").val(swe_to1);
        $("#swe_reasonleaving1").val(swe_reasonleaving1);
        $("#swe_retirebenfit1").val(swe_retirebenfit1);
        $("#swe_gettingpension1").val(swe_gettingpension1);
        $("#swe_medicalfacilities1").val(swe_medicalfacilities1);
}
function process_save_work_experience(){
        var usePath    = $.trim( $("#rootXPath").val() );
         var formData             = new FormData();
         var mid                  = $.trim( $("#workexpfooterid1").val() );
        var sewcode   = $.trim( $("#sw_sewcode").val() );
        var swe_employer1 = $.trim( $("#swe_employer1").val() );
        var swe_designation1 = $.trim( $("#swe_designation1").val() );
        var swe_responsiblity1 = $.trim( $("#swe_responsiblity1").val() );
        var swe_from1 = $.trim( $("#swe_from1").val() );
        var swe_to1 = $.trim( $("#swe_to1").val() );
        var swe_reasonleaving1 = $.trim( $("#swe_reasonleaving1").val() );
        var swe_retirebenfit1 = $.trim( $("#swe_retirebenfit1").val() );
        var swe_gettingpension1 = $.trim( $("#swe_gettingpension1").val() );
        var swe_medicalfacilities1 = $.trim( $("#swe_medicalfacilities1").val() );
        if( sewcode == ''){
            alert("Sewadar code is required");
            $("#sw_sewcode").focus()
            return false;
        }else if( swe_employer1 == ''){
            alert("Employer name is required");
             $("#swe_employer1").focus()
            return false;
        }
        formData.append("identity", "ADDWKEXP");
        formData.append("workexpfooterid", mid);
        formData.append("sewcode", sewcode);
        formData.append("swe_employer", swe_employer1);
        formData.append("swe_designation", swe_designation1);
        formData.append("swe_responsiblity", swe_responsiblity1);
        formData.append("swe_from", swe_from1);
        formData.append("swe_to", swe_to1);
        formData.append("swe_reasonleaving", swe_reasonleaving1);
        formData.append("swe_retirebenfit", swe_retirebenfit1);
        formData.append("swe_gettingpension", swe_gettingpension1);
        formData.append("swe_medicalfacilities", swe_medicalfacilities1);

        $(".process_workexp_save").hide();
              $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                          var vhtml = '';
                         var typex = "'WEP'";
                        if( resp.status ){
                               alert(resp.message);
                                var sdata = resp.data;
                                var i = 2
                                $.each(sdata,function(key,expwrk){
                                    vhtml +='<tr class="new_workexperience">';
                                    vhtml +='<input type="hidden" class="form-control" id="workexpfooterid'+i+'" value="'+expwrk.id+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"  maxlength="50"  id="swe_designation'+i+'" value="'+expwrk.swe_designation+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" maxlength="50"  id="swe_employer'+i+'" value="'+expwrk.swe_employer+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"  maxlength="200" id="swe_responsiblity'+i+'" value="'+expwrk.swe_responsiblity+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"  maxlength="15" id="swe_from'+i+'" value="'+expwrk.swe_from+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"  maxlength="15" id="swe_to'+i+'" value="'+expwrk.swe_to+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="swe_reasonleaving'+i+'" value="'+expwrk.swe_reasonleaving+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="swe_retirebenfit'+i+'" value="'+expwrk.swe_retirebenfit+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="swe_gettingpension'+i+'" value="'+expwrk.swe_gettingpension+'"/>';
                                    vhtml +='<input type="hidden" class="form-control" autocomplete="off"   maxlength="200" id="swe_medicalfacilities'+i+'" value="'+expwrk.swe_medicalfacilities+'"/>';
                                  
                                    vhtml +='<td >'+expwrk.swe_employer+'</td>';
                                    vhtml +='<td>'+expwrk.swe_designation+'</td>';
                                    vhtml +='<td>'+expwrk.swe_responsiblity+'</td>';
                                    vhtml +='<td>'+expwrk.swe_from+'</td>';
                                    vhtml +='<td>'+expwrk.swe_to+'</td>';
                                    vhtml +='<td>'+expwrk.swe_reasonleaving+'</td>';
                                    vhtml +='<td>'+expwrk.swe_retirebenfit+'</td>';
                                    vhtml +='<td>'+expwrk.swe_gettingpension+'</td>';
                                    vhtml +='<td>'+expwrk.swe_medicalfacilities+'</td>';
                                    vhtml +='<td><a href="javascript:;" onclick="process_wrokexp_edited('+i+')"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                    vhtml +='<td><a href="javascript:;" onclick="delete_common_items('+typex+','+expwrk.id+');"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                    vhtml +='</tr>';
                                    i++;
                                });
                                 $("#process_canidate_workexp").html(vhtml);
                                 setTimeout(function(){ reset_work_experience_items();},500);
                        }else{
                            $(".process_workexp_save").show();
                           alert(resp.message);
                        }

                     },
                     error: function () {
                         $(".process_workexp_save").show();
                     },
                     cache: false
             });
                     

}
function copy_all_permanent_detail(){
    var sp_perma_houseaddress = $.trim( $("#sp_perma_houseaddress").val() );
    var sp_perma_state        = $.trim( $("#sp_perma_state option:selected").val() );
    var sp_perma_distcity     = $.trim( $("#sp_perma_distcity option:selected").val() );
    var statename             = $.trim( $("#sp_perma_state option:selected").text() );
    var districtname          = $.trim( $("#sp_perma_distcity option:selected").text() );
    var sp_perma_pincode      = $.trim( $("#sp_perma_pincode").val() ); 
    var current_addresss      = $.trim( $("#current_pres_houseaddress").val() );
    
   
    var current_pres_pincode  = $.trim( $("#current_pres_pincode").val() );


    if( $("input[name='mypermanent_address']").is(":checked") ){
            $("#sp_pres_houseaddress").val(sp_perma_houseaddress);
            $("#sp_pres_state").html('<option value="'+sp_perma_state+'">'+statename+'</option>');
            $("#sp_pres_distcity").html('<option value="'+sp_perma_distcity+'">'+districtname+'</option>');
            $("#sp_pres_pincode").val(sp_perma_pincode);
    }else{
             setTimeout(function(){ get_district_states('PS');},500);
             var current_pres_state    = $.trim( $("#current_pres_state option:selected").val() );
             setTimeout(function(){ load_on_settimeout(current_addresss,current_pres_state,current_pres_pincode);},500);
             setTimeout(function(){ get_district_city('PS');},500);
             var current_pres_distcity = $.trim( $("#current_pres_distcity option:selected").val() );
             setTimeout(function(){ $("#sp_pres_distcity").val(current_pres_distcity);},500);
    }
}

function load_on_settimeout(current_addresss,current_pres_state,current_pres_pincode){
            $("#sp_pres_houseaddress").val(current_addresss);
            $("#sp_pres_state").val(current_pres_state);            
            $("#sp_pres_pincode").val(current_pres_pincode);
}

function change_nominee_user(id){
    var nomee            =  $.trim( $("#skf_nominee"+id).val() );
    var skf_percentage1  =  $.trim( $("#oldestpercentage1").val() );
    var skf_nomineebank1 =  $.trim( $("#oldestnomineebank1").val() );
    
    if( nomee == 'Y' ){
        $("#skf_percentage"+id).removeAttr("readonly");
        $("#skf_nomineebank"+id).removeAttr("readonly");
        $("#skf_percentage"+id).removeClass("input_read");
        $("#skf_nomineebank"+id).removeClass("input_read");
        $("#skf_percentage"+id).val(skf_percentage1);
        $("#skf_nomineebank"+id).val(skf_nomineebank1);
    }else{
        $("#skf_percentage"+id).attr("readonly",true);
        $("#skf_nomineebank"+id).attr("readonly",true);
        $("#skf_percentage"+id).val('');
        $("#skf_nomineebank"+id).val('');
        $("#skf_percentage"+id).removeClass("input_read").addClass("input_read");
        $("#skf_nomineebank"+id).removeClass("input_read").addClass("input_read");
    }
}

function get_change_selected_spouse(id){
        var sw_gender =  $.trim( $("#sw_gender").val() );
        var relas     =  $.trim( $("#skf_relation"+id).val() );       
        if( relas == 'Spouse'){
            if( sw_gender == 'M' ){
                $("#skf_gender"+id).val('Female');
            }else if( sw_gender == 'F'  ){
                $("#skf_gender"+id).val('Male');
            }
        }else if( relas ==  'Son'){
             $("#skf_gender"+id).val('Male');
        }else if( relas ==  'Daughter'){
             $("#skf_gender"+id).val('Female');
        }else if( relas ==  'Brother'){
             $("#skf_gender"+id).val('Male');
        }else if( relas ==  'Sister'){
             $("#skf_gender"+id).val('Female');
        }else if( relas ==  'Mother'){
             $("#skf_gender"+id).val('Female');
        }else if( relas ==  'Father'){
             $("#skf_gender"+id).val('Male');
        }else if( relas ==  'Mother in Law'){
             $("#skf_gender"+id).val('Female');
        }else if( relas ==  'Father in Law'){
             $("#skf_gender"+id).val('Male');
        }
        if( relas ==  'Other' ){
            $(".relatioship_others").removeClass("hidden");
            $("#skf_others1").focus();
        }else{
            $(".relatioship_others").removeClass("hidden").addClass("hidden");
        }
}

function check_father_husband(){
     var martistatus = $("#sw_maritalstatus").val();
     var gender      = $("#sw_gender").val();
     if( martistatus == 'Y' && gender == 'F' ){
         //$("#changefathernames").html("Husband's Name");
         $(".process_husband").removeClass("hidden");
     }else{
          $(".process_husband").removeClass("hidden").addClass("hidden");
         //$("#changefathernames").html("Father's Name");
     }
    
    
}

function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}
function delete_common_items(type,id){
             var usePath    = $.trim( $("#rootXPath").val() );
             var sewcode   = $.trim( $("#sw_sewcode").val() );
             if( confirm("Are you sure want to delete this?" )){
                  $.ajax({
                             url: usePath+"sewadar_information/ajax_process",
                             type: 'POST',
                             data: {'sewcode': sewcode,'types':type,'delid':id,'identity':'DELETEEACH'},
                             async: false,
                             success: function (resp) {
                                 var vhtml = "";
                                 if( resp.status ){
                                      var sdata = resp.data;
                                      var i     = 2
                                      var typex = "'"+type+"'"
                                    if( type == 'QLF'){

                                                $.each(sdata,function(key,qualif){
                                                var attached = ""
                                                 if ( qualif && qualif.skq_attach !='' ){
                                                   attached = "Attached";
                                                 }
                                                var myqualifcation = "";
                                                if( qualif.skq_qualtype == 'No Schooling'){
                                                    myqualifcation ="hidden"
                                                }else if( qualif.skq_qualtype == 'Non Matric'){
                                                    myqualifcation ="hidden"
                                                }
                                                vhtml +='<tr class="new_qualification">';
                                                vhtml +='<input type="hidden" class="form-control-sm"  id="qualiffooterid'+i+'" value="'+qualif.id+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm"  id="cur_qlf_attch'+i+'" value="'+qualif.skq_attach+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm"  id="skq_qualtype'+i+'" value="'+qualif.skq_qualtype+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm"  id="skq_universityboard'+i+'" value="'+qualif.skq_universityboard+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm"  id="skq_degreedip'+i+'" value="'+qualif.skq_degreedip+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm " id="skq_passingyear'+i+'" value="'+qualif.skq_passingyear+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm " id="skq_duration'+i+'"   value="'+qualif.skq_duration+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm " id="skq_percenatge'+i+'" value="'+qualif.skq_percenatge+'"/>';
                                                vhtml +='<td  width="23%">'+qualif.skq_qualtype+'</td>';
                                                vhtml +='<td  width="40%" class="process_visibility_2 ">'+qualif.universityboard+'</td>';
                                                vhtml +='<td  width="40%" class="process_visibility_2 ">'+qualif.degreedip+'</td>';
                                                vhtml +='<td  width="10%"  class="process_visibility_2 ">'+qualif.skq_passingyear+'</td>';
                                                vhtml +='<td  width="10%"  class="process_visibility_2 ">'+qualif.skq_duration+'</td>';
                                                vhtml +='<td  width="10%"  class="process_visibility_2 ">'+qualif.skq_percenatge+'</td>';
                                                vhtml +='<td class="process_visibility_2 ">'+attached+'</td>';
                                                vhtml +='<td class="process_visibility_2 "><a href="javascript:;" onclick="process_qualif_edit('+i+');"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                                vhtml +='<td class="process_visibility_2 "><a href="javascript:;" onclick="delete_common_items('+typex+','+qualif.id+');"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                                vhtml +='</tr>';
                                                i++;
                                            });
                                            alert(resp.message);
                                            $("#process_canidate_qulif").html(vhtml);
                                          }else if( type == 'WEP'){
                                             $.each(sdata,function(key,expwrk){
                                                vhtml +='<tr class="new_workexperience">';
                                                vhtml +='<input type="hidden" class="form-control-sm" id="workexpfooterid'+i+'" value="'+expwrk.id+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" autocomplete="off"  maxlength="50"  id="swe_designation'+i+'" value="'+expwrk.swe_designation+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" maxlength="50"  id="swe_employer'+i+'" value="'+expwrk.swe_employer+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" autocomplete="off"  maxlength="200" id="swe_responsiblity'+i+'" value="'+expwrk.swe_responsiblity+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm wd100" autocomplete="off"  maxlength="15" id="swe_from'+i+'" value="'+expwrk.swe_from+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm wd100" autocomplete="off"  maxlength="15" id="swe_to'+i+'" value="'+expwrk.swe_to+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" autocomplete="off"   maxlength="200" id="swe_reasonleaving'+i+'" value="'+expwrk.swe_reasonleaving+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" autocomplete="off"   maxlength="200" id="swe_retirebenfit'+i+'" value="'+expwrk.swe_retirebenfit+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" autocomplete="off"   maxlength="200" id="swe_gettingpension'+i+'" value="'+expwrk.swe_gettingpension+'"/>';
                                                vhtml +='<input type="hidden" class="form-control-sm" autocomplete="off"   maxlength="200" id="swe_medicalfacilities'+i+'" value="'+expwrk.swe_medicalfacilities+'"/>';
                                                vhtml +='<td>'+expwrk.swe_employer+'</td>';
                                                vhtml +='<td>'+expwrk.swe_designation+'</td>';
                                                vhtml +='<td>'+expwrk.swe_responsiblity+'</td>';
                                                vhtml +='<td>'+expwrk.swe_from+'</td>';
                                                vhtml +='<td>'+expwrk.swe_to+'</td>';
                                                vhtml +='<td>'+expwrk.swe_reasonleaving+'</td>';
                                                vhtml +='<td>'+expwrk.swe_retirebenfit+'</td>';
                                                vhtml +='<td>'+expwrk.swe_gettingpension+'</td>';
                                                vhtml +='<td>'+expwrk.swe_medicalfacilities+'</td>';
                                                vhtml +='<td><a href="javascript:;" onclick="process_wrokexp_edited('+i+')"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                                vhtml +='<td><a href="javascript:;" onclick="delete_common_items('+typex+','+expwrk.id+');"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                                vhtml +='</tr>';
                                                i++;
                                            });
                                             $("#process_canidate_workexp").html(vhtml);
                                             setTimeout(function(){ reset_work_experience_items();},500);

                                          }else if(  type == 'FML' ){

                                               $.each(sdata,function(key,familydetail){
                                                var attacheds = ""
                                                if( familydetail.skf_attachment !=''){
                                                    attacheds = "Attached";
                                                }
                                                 vhtml +='<tr class="new_familydetail">';
                                                 vhtml +='<input type="hidden" class="form-control-sm " id="familyfooterid'+i+'" value="'+familydetail.id+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " maxlength="250" id="skf_address'+i+'" value="'+familydetail.skf_address+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " id="currattachment'+i+'" value="'+familydetail.skf_attachment+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm" maxlength="50" id="skf_dependent'+i+'" value="'+familydetail.skf_dependent+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm" maxlength="50" id="skf_relation'+i+'" value="'+familydetail.skf_relation+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm" readonly maxlength="10" id="skf_gender'+i+'" value="'+familydetail.skf_gender+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " autocomplete="off"  id="skf_datebirth'+i+'" value="'+familydetail.skf_datebirth+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " autocomplete="off"  id="skf_occupation'+i+'" value="'+familydetail.skf_occupation+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " autocomplete="off"  id="skf_optedpolicy'+i+'" value="'+familydetail.skf_optedpolicy+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " id="skf_pannumber'+i+'" value="'+familydetail.skf_pannumber+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " id="skf_nominee'+i+'" value="'+familydetail.skf_nominee+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " id="skf_percentage'+i+'" value="'+familydetail.skf_percentage+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm " maxlength="140"  id="skf_nomineebank'+i+'" value="'+familydetail.skf_nomineebank+'"/>';
                                                 vhtml +='<input type="hidden" class="form-control-sm"  id="skf_university'+i+'" value="'+familydetail.skf_university+'"/>';

                                                 vhtml +='<td>'+familydetail.skf_dependent+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_relation+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_gender+'</td>';
                                                 vhtml +='<td>'+familydetail.bdate1+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_occupation+'</td>';
                                                 vhtml +='<td>'+familydetail.university+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_optedpolicy+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_pannumber+'</td>';
                                                 vhtml +='<td>'+attacheds+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_nominee+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_percentage+'</td>';
                                                 vhtml +='<td>'+familydetail.skf_nomineebank+'</td>';
                                                 vhtml +='<td><a href="javascript:;" onclick="get_edited_family_list_detail('+i+');"><i class="fa fa-pencil m-r-5"></i></a></td>';
                                                 vhtml +='<td><a href="javascript:;" onclick="delete_common_items('+typex+','+familydetail.id+');"><i class="fa fa-trash-o m-r-5"></i></a></td>';
                                                 vhtml +='</tr>';
                                                i++;
                                            });
                                             $("#process_canidate_families").html(vhtml);
                                             setTimeout(function(){ reset_familiy_contents_rowise();},500);


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

}
function fill_my_qulification_data(id){
    var qualiffooterid1      =  $("#qualiffooterid"+id).val();
    var cur_qlf_attch1       =  $("#cur_qlf_attch"+id).val();
    var skq_universityboard1 =  $("#skq_universityboard"+id).val();   
    var skq_degreedip1       =  $("#skq_degreedip"+id).val();
    var skq_passingyear1     =  $("#skq_passingyear"+id).val();
    var skq_duration1        =  $("#skq_duration"+id).val();
    var skq_percenatge1      =  $("#skq_percenatge"+id).val();
    $("#qualiffooterid1").val(qualiffooterid1);
    $("#cur_qlf_attch1").val(cur_qlf_attch1);
    $("#skq_universityboard1").val(skq_universityboard1)    
    $("#skq_degreedip1").val(skq_degreedip1) ;
    $("#skq_passingyear1").val(skq_passingyear1);
    $("#skq_duration1").val(skq_duration1);
    $("#skq_percenatge1").val(skq_percenatge1);
    $(".process_qualif_save").show();
}

function process_qualif_edit(id){
    var skq_qualtype1        =  $("#skq_qualtype"+id).val();
    $(".process_qualif_save").hide();
     $("#skq_qualtype1").val(skq_qualtype1);
    setTimeout(function(){ get_university_qualf_list('1'); },500);
    setTimeout(function(){ fill_my_qulification_data(id); },500);
   
}
function reset_qualification_afteradd(){
    $("#qualiffooterid1").val('');
    $("#skq_universityboard1").val('')
    $("#skq_qualtype1").val('');
    $("#skq_degreedip1").val('') ;
    $("#skq_passingyear1").val('');
    $("#skq_duration1").val('');
    $("#skq_percenatge1").val('');
    $('#skq_attach1').val('');
    $(".process_qualif_save").show();
}

function process_my_qualification(){
            var usePath              = $.trim( $("#rootXPath").val() );
            var formData             = new FormData();
            var mid                  = $.trim( $("#qualiffooterid1").val() );
            var skq_universityboard1 = $.trim( $("#skq_universityboard1").val() );
            var skq_qualtype1        = $.trim( $("#skq_qualtype1").val() );
            var skq_degreedip1       = $.trim( $("#skq_degreedip1").val() );
            var skq_passingyear1     = $.trim( $("#skq_passingyear1").val() );
            var skq_duration1        = $.trim( $("#skq_duration1").val() );
            var skq_percenatge1      = $.trim( $("#skq_percenatge1").val() );
            var skq_attach1          = $('#skq_attach1').get(0).files[0]; 
            var sewcode              = $.trim( $("#sw_sewcode").val() );
            var cur_qlf_attch1       = $.trim( $("#cur_qlf_attch1").val() );
            if( sewcode == ''){
                alert("Sewadar code is required");
                return false;
            }else if( skq_qualtype1 == ''){
                alert("Qualification type is required");
                return false;
            }
            formData.append("identity", "ADDQUALF");
            formData.append("qualiffooterid", mid);
            formData.append("sewcode", sewcode);
            formData.append("skq_universityboard", skq_universityboard1);
            formData.append("skq_qualtype", skq_qualtype1);
            formData.append("skq_degreedip", skq_degreedip1);
            formData.append("skq_passingyear", skq_passingyear1);
            formData.append("skq_duration", skq_duration1);
            formData.append("skq_percenatge", skq_percenatge1);
            formData.append("cur_qlf_attch", cur_qlf_attch1);
            
            if( typeof(skq_attach1) != "undefined" ){
                 formData.append("skq_attach", skq_attach1);
             }else{
                  formData.append("skq_attach", '');
             }
            
             $(".process_qualif_save").hide();
              $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                          var vhtml = '';
                         var typex = "'QLF'";
                        if( resp.status ){
                               alert(resp.message);
                                var sdata = resp.data;
                                var i = 2
                                $.each(sdata,function(key,qualif){
                                    var attached = ""
                                     if ( qualif && qualif.skq_attach !='' ){
                                       attached = "Attached";
                                     }
                                    var myqualifcation = "";
                                    if( qualif.skq_qualtype == 'No Schooling'){
                                        myqualifcation ="hidden"
                                    }else if( qualif.skq_qualtype == 'Non Matric'){
                                        myqualifcation ="hidden"
                                    }
                                    vhtml +='<tr class="new_qualification">';
                                    vhtml +='<input type="hidden" class="form-control-sm"  id="qualiffooterid'+i+'" value="'+qualif.id+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm"  id="cur_qlf_attch'+i+'" value="'+qualif.skq_attach+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm"  id="skq_qualtype'+i+'" value="'+qualif.skq_qualtype+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm"  id="skq_universityboard'+i+'" value="'+qualif.skq_universityboard+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm"  id="skq_degreedip'+i+'" value="'+qualif.skq_degreedip+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm " id="skq_passingyear'+i+'" value="'+qualif.skq_passingyear+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm " id="skq_duration'+i+'"   value="'+qualif.skq_duration+'"/>';
                                    vhtml +='<input type="hidden" class="form-control-sm " id="skq_percenatge'+i+'" value="'+qualif.skq_percenatge+'"/>';
                                    vhtml +='<td  width="23%">'+qualif.skq_qualtype+'</td>';
                                    vhtml +='<td  width="40%" class="process_visibility_2 ">'+qualif.universityboard+'</td>';
                                    vhtml +='<td  width="40%" class="process_visibility_2 ">'+qualif.degreedip+'</td>';
                                    vhtml +='<td  width="10%"  class="process_visibility_2 ">'+qualif.skq_passingyear+'</td>';
                                    vhtml +='<td  width="10%"  class="process_visibility_2 ">'+qualif.skq_duration+'</td>';
                                    vhtml +='<td  width="10%"  class="process_visibility_2 ">'+qualif.skq_percenatge+'</td>';
                                    vhtml +='<td class="process_visibility_2 ">'+attached+'</td>';
                                    vhtml +='<td class="process_visibility_2 "><a href="javascript:;" onclick="process_qualif_edit('+i+');">Edit</a></td>';
                                    vhtml +='<td class="process_visibility_2 "><a href="javascript:;" onclick="delete_common_items('+typex+','+qualif.id+');">Delete</a></td>';
                                    vhtml +='</tr>';
                                    i++;
                                });
                                 $("#process_canidate_qulif").html(vhtml);
                                 setTimeout(function(){ reset_qualification_afteradd();},500);
                        }else{
                            $(".process_qualif_save").show();
                           alert(resp.message);
                        }

                     },
                     error: function () {
                         $(".process_qualif_save").show();
                     },
                     cache: false
             });
}

function get_zone_branches(){
            var usePath    = $.trim( $("#rootXPath").val() );
            var zonecode  = $.trim( $("#so_zone").val() );

             $.ajax({
                             url: usePath+"branch/ajax_process",
                             type: 'POST',
                             data: {'zonecode': zonecode,'identity':'BRCH'},
                             async: false,
                             success: function (resp) {
                               var sdata = resp.data;
                               var mhtml  = '<option value="">-Select-</option>';
                               var i = 1;
                              if(sdata.length >0 ){
                                     $.each(sdata,function(key,leds){
                                         mhtml +='<option value="'+leds.bch_branchcode+'">'+leds.bch_branchname+'</option>';
                                         i++;
                                    });
                              }
                              $("#so_branch").html(mhtml);
                             },
                             error: function () {

                             },
                             cache: false
                 });


}
function get_my_sub_location(){
         var usePath     = $.trim( $("#rootXPath").val() );
         var locations    = $.trim( $("#sw_location").val() );

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
                             $("#so_sublocation").html(vhtml);

                         },
                         error: function () {
                           $("#so_sublocation").html('<option value="">-Select-</option>');
                         },
                         cache: false
             });
}
function get_my_sub_department(){
         var usePath     = $.trim( $("#rootXPath").val() );
         var departcode  = $.trim( $("#so_deprtcode").val() );
         
         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'departcode': departcode,'identity':'SUBDEPART'},
                         async: false,
                         success: function (resp) {
                              var vhtml = '<option value="">-Select-</option>';
                             if ( resp.status ){
                                 var sdata = resp.data;
                                 $.each(sdata,function(key,leds){
                                       vhtml +='<option value="'+leds.departCode+'">'+leds.departDescription+'</option>';
                                 });
                             }
                             $("#so_subdepartment").html(vhtml);

                         },
                         error: function () {

                         },
                         cache: false
             });
}


function get_durations(id){
        var usePath        = $.trim( $("#rootXPath").val() );
        var qualification  = $.trim( $("#skq_degreedip"+id).val() );

         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'qualification': qualification,'identity':'DURTN'},
                         async: false,
                         success: function (resp) {
                             if ( resp.status ){
                                 var udata = resp.data;
                                 $("#skq_duration"+id).val(udata);
                             }else{
                                 $("#skq_duration"+id).val('');
                             }


                         },
                         error: function () {
                                $("#skq_duration"+id).val('');
                         },
                         cache: false
             });
}

function get_university_qualf_list(id){
        var usePath        = $.trim( $("#rootXPath").val() );
        var qualification  = $.trim( $("#skq_qualtype"+id).val() );
        if( qualification == 'No Schooling'){
            $(".process_visibility").removeClass("hidden").addClass("hidden");
        }else if( qualification == 'Non Matric' ){
            $(".process_visibility").removeClass("hidden").addClass("hidden");
        }else{
             $(".process_visibility").removeClass("hidden");
        }
         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'qualification': qualification,'identity':'QLFUNV'},
                         async: false,
                         success: function (resp) {
                             if ( resp.status ){
                                 var udata = resp.undata;
                                 var qdata = resp.qldata;
                                 $("#skq_universityboard"+id).html(udata);
                                 $("#skq_degreedip"+id).html(qdata);
                             }else{
                                 $("#skq_universityboard"+id).html('<option value="">-Select-</option>');
                                 $("#skq_degreedip"+id).html('<option value="">-Select-</option>');
                             }


                         },
                         error: function () {
                                 $("#skq_universityboard"+id).html('<option value="">-Select-</option>');
                                 $("#skq_degreedip"+id).html('<option value="">-Select-</option>');
                         },
                         cache: false
             });
}

function get_district_city(types){
         var usePath     = $.trim( $("#rootXPath").val() );
         var dstcity     = ""
         if( types == 'PM'){
             dstcity     = $.trim( $("#sp_perma_state").val() );
         }else if(types == 'PS'){
             dstcity     = $.trim( $("#sp_pres_state").val() );
            
         }
         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'dstcity': dstcity,'identity':'DISTCITY'},
                         async: false,
                         success: function (resp) {
                              var vhtml = '<option value="">-Select-</option>';
                             if ( resp.status ){
                                 var sdata = resp.data;
                                 $.each(sdata,function(key,leds){
                                       vhtml +='<option value="'+leds.dts_districtcode+'">'+leds.dts_description+'</option>';
                                 });
                             }
                             if( types == 'PM' ){
                                 $("#sp_perma_distcity").html(vhtml);
                             }else if(types == 'PS'){
                                 $("#sp_pres_distcity").html(vhtml);
                             }

                         },
                         error: function () {
                               
                         },
                         cache: false
             });
}

function get_district_states(types){
         var usePath     = $.trim( $("#rootXPath").val() );
         var dstcity     = ""
         if( types == 'PM'){
             dstcity     = $.trim( $("#sp_perma_state").val() );
         }else if(types == 'PS'){
             dstcity     = $.trim( $("#sp_pres_state").val() );
         }
         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'dstcity': dstcity,'identity':'DISTSTATES'},
                         async: false,
                         success: function (resp) {
                              var vhtml = '<option value="">-Select-</option>';
                             if ( resp.status ){
                                 var sdata = resp.data;
                                 $.each(sdata,function(key,leds){
                                       vhtml +='<option value="'+leds.sts_code+'">'+leds.sts_description+'</option>';
                                 });
                             }
                             if(types == 'PS'){
                                 $("#sp_pres_state").html(vhtml);
                             }

                         },
                         error: function () {

                         },
                         cache: false
             });
}

function add_retirement_dated(){
         var usePath     = $.trim( $("#rootXPath").val() );
         var birthdate   = $.trim( $("#sw_date_of_birth").val() );

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
                                        $("#sw_date_of_birth").val('');
                                        $(".age_calcualted").html('');
                                        $("#sw_date_of_birth").focus();
                                        return false;
                                 }else{
                                         $("#so_superannuationdate").val(sdata);
                                         $(".age_calcualted").html(resp.ages);
                                         $("#mytotal_sewleft").html(resp.leftsewa);
                                 }
                             }else{
                                  $("#so_superannuationdate").val('');
                                  $(".age_calcualted").html('');
                                  $("#mytotal_sewleft").html('');
                             }


                         },
                         error: function () {
                                $("#so_superannuationdate").val('');
                                 $(".age_calcualted").html('');
                                  $("#mytotal_sewleft").html('');
                         },
                         cache: false
             });
}


function get_total_sewa_dated(){
         var usePath     = $.trim( $("#rootXPath").val() );
         var birthdate   = $.trim( $("#so_joiningdate").val() );

         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'joiningdated': birthdate,'identity':'TOTALSEWA'},
                         async: false,
                         success: function (resp) {
                             if ( resp.status ){
                                 var sdata = resp.data;                                 
                                 $("#mytotal_sewa").html(sdata);
                                
                             }else{
                                  $("#mytotal_sewa").html('');
                             }


                         },
                         error: function () {
                               $("#mytotal_sewa").html('');
                         },
                         cache: false
             });
}
function get_sewadar_series_bycategory(){
         var usePath    = $.trim( $("#rootXPath").val() );
         var catname    = $.trim( $("#sw_catgeory option:selected").text() );
         var catcodes   = $.trim( $("#sw_catgeory option:selected").val() );
        
         $.ajax({
                         url: usePath+"sewadar_information/ajax_process",
                         type: 'POST',
                         data: {'catname': catname,'catcodes':catcodes,'identity':'GS'},
                         async: false,
                         success: function (resp) {
                             if ( resp.status ){
                                 var sdata = resp.data;
                                 $("#sw_sewcode").val(sdata);
                             }
                           
                          
                         },
                         error: function () {

                         },
                         cache: false
             });
}

function process_clickable_continue(){
        var usePath   = $.trim( $("#rootXPath").val() );
        var classname = $.trim( $("#myselected_classname").val() );
        var usertype  = $.trim( $("#authorizeduser").val() );
        var kycuser   = $.trim( $("#my_kyc_users").val() );
      
        $("#process_message").modal("hide");
        $(".process_save").show();
        if ( usertype == 'swd' ){
              if( kycuser == 'kyc'){
                 window.location = usePath+"sewadar_dashboard"
              }else{
                 $("."+classname).trigger('click');
              }

        }else{
              if( classname == 'mymaintain' ){
                    window.location = usePath+"sewadar_information";
              }else{
                  $("."+classname).trigger('click');
              }
             
        }
        
        
}
function handelled_error(){
        $("#error_process_message").modal("hide");
        $("#pull_error_messages").html("");
        $(".process_save").show();
}

function create_sewdar_header(){
    var usePath           = $.trim( $("#rootXPath").val() );
    var formData          = new FormData();
    var image_file        = $('#item-img-output').attr("src");
    var other_data        = $('form#emp_profile_forms').serializeArray();
    var mid               = $.trim( $("#mid").val() );
    var sw_branchtype     = $.trim( $("input[name='sw_branchtype']:checked").val() );
    var sw_catgeory       = $.trim( $("#sw_catgeory").val() );
   
    var sw_sewcode        = $.trim( $("#sw_sewcode").val() );
    var sw_sewadar_prefix = $.trim( $("#sw_sewadar_prefix").val() );
    var sw_sewadar_name   = $.trim( $("#sw_sewadar_name").val() );
    var sw_father_prefix  = $.trim( $("#sw_father_prefix").val() );
    var sw_father_name    = $.trim( $("#sw_father_name").val() );
    var sw_date_of_birth  = $.trim( $("#sw_date_of_birth").val() );
    var sw_maritalstatus  = $.trim( $("#sw_maritalstatus").val() );
    var sw_gender         = $.trim( $("#sw_gender").val() );
    var sw_location       = $.trim( $("#sw_location").val() );
    var myattachpropfile  = $.trim( $("#myattachpropfile").val() );
    var sw_husbprefix     = $.trim( $("#sw_husbprefix").val() );
    var sw_husbandname    = $.trim( $("#sw_husbandname").val() );
    var currentimg        = $.trim( $("#currentimg").val() );
    if( sw_catgeory == ''){
        alert("Category is required.");
        $("#sw_catgeory").focus();
        return false;
    }else if( sw_sewcode == ''){
        alert("sewadar code is required.");
        $("#sw_type").focus();
        return false;
    }else if( sw_sewadar_name == ''){
        alert("sewadar name is required.");
        $("#sw_sewadar_name").focus();
        return false;
    }else if( sw_date_of_birth == ''){
        alert("sewadar date of birth is required.");
        $("#sw_date_of_birth").focus();
        return false;
    }
    formData.append("identity", "Y");
    formData.append("mid", mid);
    formData.append("sw_branchtype", sw_branchtype);
    formData.append("sw_catgeory", sw_catgeory);
    formData.append("myattachpropfile", myattachpropfile);
    
    formData.append("sw_sewcode", sw_sewcode);
    formData.append("sw_sewadar_prefix", sw_sewadar_prefix);
    formData.append("sw_sewadar_name", sw_sewadar_name);
    formData.append("sw_father_prefix", sw_father_prefix);
    formData.append("sw_father_name", sw_father_name);
    formData.append("sw_date_of_birth", sw_date_of_birth);
    formData.append("sw_maritalstatus", sw_maritalstatus);
    formData.append("sw_gender", sw_gender);
    formData.append("sw_location", sw_location);
    formData.append("sw_husbprefix", sw_husbprefix);
    formData.append("sw_husbandname", sw_husbandname);
    if( typeof(image_file) != "undefined" || image_file !='' ){
        formData.append("sw_image", image_file);
    }else{
        formData.append("sw_image", "");
    }

    formData.append("currentimgs", currentimg);   
   var file_data = $('.new_qualification input[type="file"]')

        for (var i = 0; i < file_data.length; i++) {

            if( typeof(file_data[i].files[0]) !='undefined' ){
                formData.append("skq_attach[]", file_data[i].files[0]);
            }else{
                formData.append("skq_attach[]", '');
            }

        }
    $.each(other_data,function(key,input){
        formData.append(input.name,input.value);
    });
    $(".process_save").hide();
    $("#myselected_classname").val('emp_office');
           $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         
                        if( resp.status ){
                             
                               $("#pull_messages").html(resp.message);
                               $("#process_message").modal("show");
                               $("#mid").val(resp.data);
                               $("#currentimg").val(resp.myimgs);                               
                               
                        }else{
                            $(".process_save").show();
                            $("#pull_error_messages").html(resp.message);
                            $("#error_process_message").modal("show");
                        }

                     },
                     error: function () {
                         $(".process_save").show();
                     },
                     cache: false
             });

}

function change_mandal_residencial_type(type){
    /*
    if( type == 'Mandal'){
      $(".mandal_code").removeClass("hidden").addClass("hidden");
      $(".nomandal_code").removeClass("hidden").addClass("hidden");;
    }else{
       $(".mandal_code").removeClass("hidden");
      $(".nomandal_code").removeClass("hidden").addClass("hidden");
    }*/
}

function basic_hra_calculation(){
    var so_basic      = $.trim( $("#so_basic").val() ) !='' ? $.trim( $("#so_basic").val() ) : 0;
    var so_hra        = $.trim( $("#so_hra").val() ) !='' ? $.trim( $("#so_hra").val() ) : 0;
    var so_conveyance = $.trim( $("#so_conveyance").val() ) !='' ? $.trim( $("#so_conveyance").val() ) : 0;
    var total         = eval(so_basic)+eval(so_hra)+eval(so_conveyance);
    total              = parseFloat(total).toFixed(2);
    $("#so_totalgross").val(total);
}
function process_sewadar_office(){
    var usePath           = $.trim( $("#rootXPath").val() );
    var formData          = new FormData();
    var other_data        = $('form#emp_office').serializeArray();
    var sw_sewcode        = $.trim( $("#sw_sewcode").val() );
    var hqoffice          = ""
    if(  $("input[name='sw_branchtype']").is(":checked") ){
        hqoffice          = $("input[name='sw_branchtype']:checked").val();
    }
    if( hqoffice == "" ){
        alert("Please select head office or branch");
        return false;
    }

    formData.append("identity", "OFFICE");
    formData.append("sewcode", sw_sewcode);
    $.each(other_data,function(key,input){
        formData.append(input.name,input.value);
    });
     $(".process_save").hide();
     $("#myselected_classname").val('emp_kyc');
     
    $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                        
                        if( resp.status ){
                                nsdata = resp.infodata
                                $("#InnoteHr").html("<p>"+nsdata.so_innote_hr+"</p>"); 
                                $("#OutnoteSewdar").html("<p>"+nsdata.so_outnote_sewdar+"</p>");  
                                $("#pull_messages").html(resp.message);
                                $("#process_message").modal("show");
                                $("#so_innote_hr").val('');
                                $("#so_outnote_sewdar").val('');
                               
                        }else{                           
                            $("#pull_error_messages").html(resp.message);
                            $("#error_process_message").modal("show");
                            $("#InnoteHr").html(''); 
                            $("#OutnoteSewdar").html('');  
                            
                        }

                     },
                     error: function () {
                        $("#InnoteHr").html(''); 
                        $("#OutnoteSewdar").html('');     
                         $(".process_save").show();
                     },
                     cache: false
             });
}

function prvious_back_action(id){
   
        $("."+id).trigger('click');
}

function change_row_qualification(id){
    var nhtml  = '';
    var val    = $('.new_qualification select[name="skq_universityboard[]"]:last').prop("value");
    
    var lstid  = $('.new_qualification select[name="skq_universityboard[]"]:last').prop("id");
    var nid    = lstid.replace ( /[^\d.]/g, '' );
    
    var issm   = eval(nid)+eval(1);    
    var i      = issm;    
    //if( val != '' ){
        nhtml += '<tr class="new_qualification">';
        nhtml += '<input type="hidden" class="form-control-sm" name="qualiffooterid[]" id="qualiffooterid'+i+'" value=""/>';
        nhtml += '<input type="hidden" class="form-control-sm" name="cur_qlf_attch[]" id="cur_qlf_attch'+i+'" value=""/>';
        nhtml += '<td>';
        nhtml += '<select class="form-control" name="skq_qualtype[]" id="skq_qualtype'+i+'" onchange="get_university_qualf_list('+i+');">';
        nhtml += '<option value="">-Select-</option>';
        nhtml += '<option value="No Schooling"  >No Schooling</option>';
        nhtml += '<option value="Non Matric" >Non Matric</option>';
        nhtml += '<option value="High School/Matric/Secondary" >High School/Matric/Secondary</option>';
        nhtml += '<option value="Intermediate/10+2/Higher Secondary" >Intermediate/10+2/Higher Secondary</option>';
        nhtml += '<option value="Graduate" >Graduate</option>';
        nhtml += '<option value="Post Graduate" >Post Graduate</option>';
        nhtml += '<option value="Doctorate" >Doctorate</option>';
        nhtml += '<option value="Certificate"  >Certificate</option>';
        nhtml += '<option value="Diploma" >Diploma</option>';
        nhtml += '<option value="Training/Others" >Training/Others</option>';
        nhtml += '</select>';
        nhtml += '</td>';
        nhtml += '<td>';
        nhtml += '<select class="form-control" name="skq_universityboard[]" id="skq_universityboard'+i+'" >';
        nhtml += '<option value="">-Select</option>';
        nhtml += '</select>';
        nhtml += '</td>';
        nhtml += '<td>';
        nhtml += '<select class="form-control" name="skq_degreedip[]" id="skq_degreedip'+i+'" onchange="get_durations('+i+');">';
        nhtml += '<option value="">-Select</option>';
        nhtml += '</select>';
        nhtml += '</td>';
        

        nhtml += '<td><input type="text" class="form-control-sm " onkeypress="return isNumberKeys(event);" maxlength="4" name="skq_passingyear[]" id="skq_passingyear'+i+'" value=""/></td>';
        nhtml += '<td><input type="text" class="form-control-sm " onkeypress="return isNumberKeys(event);" maxlength="2" name="skq_duration[]" id="skq_duration'+i+'" value=""/></td>';
        nhtml += '<td><input type="text" class="form-control-sm " onkeypress="return isNumberFloatKey(event);" maxlength="10" name="skq_percenatge[]" id="skq_percenatge'+i+'" value=""/></td>';
        nhtml += '<td><input type="file" name="skq_attach[]" id="skq_attach'+i+'"/></td>';
        nhtml += '</tr>';
        $(".new_qualification:last").after(nhtml);
   
    
}


function process_new_family_rows(){
    var nhtml  = '';
    var val    = $('.new_familydetail select[id^="skf_relation"]:last').prop("value");
    var lstid  = $('.new_familydetail select[id^="skf_relation"]:last').prop("id");
    var nid    = lstid.replace ( /[^\d.]/g, '' );
    var issm   = eval(nid)+eval(1);
    var i      = issm;
   
    
        nhtml +='<tr class="new_familydetail">';
        nhtml +='<input type="hidden" name="familyfooterid[]" id="familyfooterid'+i+'" value=""/>';
        nhtml +='<input type="hidden" class="form-control-sm " maxlength="250"  name="skf_address[]" id="skf_address'+i+'" value=""/>';
        nhtml +='<input type="hidden" name="currattachment[]" id="currattachment'+i+'" value=""/>';
        nhtml +='<td><input type="text" class="form-control-sm" maxlength="50" name="skf_dependent[]" id="skf_dependent'+i+'" value=""/></td>';        
        nhtml +='<td><select class="form-control wd150" name="skf_relation[]" id="skf_relation'+i+'" onchange="get_change_selected_spouse('+i+');">';
        nhtml +='<option value="">-Select-</option>';
        nhtml +='<option value="Spouse">Spouse</option>';
        nhtml +='<option value="Son">Son</option>';
        nhtml +='<option value="Daughter">Daughter</option>';
        nhtml +='<option value="Brother">Brother</option>';
        nhtml +='<option value="Sister">Sister</option>';
        nhtml +='<option value="Mother">Mother</option>';
        nhtml +='<option value="Father">Father</option>';
        nhtml +='<option value="Mother in Law">Mother in Law</option>';
        nhtml +='<option value="Father in Law">Father in Law</option>';
        nhtml +='</select></td>';
        nhtml +='<td>';
        nhtml +='<input type="text" class="form-control-sm input_read wd100" readonly maxlength="10" name="skf_gender[]" id="skf_gender'+i+'" value=""/>';
        nhtml +='</td>';
        nhtml +='<td><input type="text" autocomplete="off" class="form-control-sm" name="skf_datebirth[]" id="skf_datebirth'+i+'" value=""/></td>';
        nhtml +='<td><select class="form-control-sm" name="skf_occupation[]" id="skf_occupation'+i+'" >';
        nhtml +='<option value="">-Select-</option>';
        nhtml +='<option value="Self Employee">Self Employee</option>';
        nhtml +='<option value="Salaried">Salaried</option>';
        nhtml +='<option value="Student">Student</option>';
        nhtml +='<option value="House Wife">House Wife</option>';
        nhtml +='<option value="Un Employee">Un Employee</option>';
        nhtml +='</select></td>';      
        
       
        nhtml +='<td><select class="form-control" name="skf_optedpolicy[]" id="skf_optedpolicy'+i+'">'
        nhtml +='<option value="N">N</option>';
        nhtml +='<option value="Y">Y</option>';        
        nhtml +='</select></td>';
        var typex  = "'A'";
        var ids  = "'skf_pannumber"+i+"'";
       
        nhtml +='<td><input type="text" onchange="check_numbers_myset(this.value,'+typex+','+ids+')"  onkeypress="return isNumberKeys(event);" maxlength="12" class="form-control-sm wd150" name="skf_pannumber[]" id="skf_pannumber'+i+'" value=""/></td>';
        nhtml +='<td><input type="file" class="form-control-sm" name="skf_attachment[]" id="skf_attachment'+i+'" /></td>';
        nhtml +='<td><select class="form-control" name="skf_nominee[]" id="skf_nominee'+i+'" onchange="change_nominee_user('+i+');">';
        nhtml +='<option value="N">N</option>';
        nhtml +='<option value="Y">Y</option>';
        nhtml +='</select></td>';
        nhtml +='<td><input readonly type="text" class="form-control-sm input_read twd100" onkeypress="return isNumberFloatKey(event);" maxlength="10" name="skf_percentage[]" id="skf_percentage'+i+'"/></td>';
        nhtml +='<td><input readonlytype="text" class="form-control-sm input_read" maxlength="140" name="skf_nomineebank[]" id="skf_nomineebank'+i+'"/></td>';
        nhtml +='</tr>';        
        $(".new_familydetail:last").after(nhtml);
   

}



    function add_work_experience(){
    var nhtml  = '';
    var val    = $('.new_workexperience input[id^="swe_designation"]:last').prop("value");
    var lstid  = $('.new_workexperience input[id^="swe_designation"]:last').prop("id");
    var nid    = lstid.replace ( /[^\d.]/g, '' );
    var issm   = eval(nid)+eval(1);
    var i      = issm;

    //if( val != '' ){
       
        nhtml +='<tr class="new_workexperience">';
        nhtml +='<input type="hidden" class="form-control-sm"  name="workexpfooterid[]" id="workexpfooterid'+i+'" value=""/>';
        nhtml +='<td><input type="text" class="form-control-sm" maxlength="50" name="swe_employer[]" id="swe_employer'+i+'" value=""/></td>';
        nhtml +='<td><input type="text" class="form-control-sm" maxlength="50" name="swe_designation[]" id="swe_designation'+i+'" value=""/></td>';
        nhtml +='<td><input type="text" class="form-control-sm" maxlength="200" name="swe_responsiblity[]" id="swe_responsiblity'+i+'" value=""/></td>';
        nhtml +='<td><input type="text" class="form-control-sm wd100 datetimepicker" maxlength="15" name="swe_from[]" id="swe_from'+i+'" value=""/></td>';
        nhtml +='<td><input type="text" class="form-control-sm wd100 datetimepicker" maxlength="15" name="swe_to[]" id="swe_to'+i+'" value=""/></td>';
        nhtml +='<td><input type="text" class="form-control-sm"  maxlength="200" name="swe_reasonleaving[]" id="swe_reasonleaving'+i+'" value=""/></td>';
        nhtml +='<td><select class="form-control" name="swe_retirebenfit[]" id="swe_retirebenfit'+i+'">';
        nhtml +='<option value="Y">Y</option>';
        nhtml +='<option value="N">N</option>';
        nhtml +='</select></td>';
        nhtml +='<td><select class="form-control" name="swe_gettingpension[]" id="swe_gettingpension'+i+'">';
        nhtml +='<option value="Y">Y</option>';
        nhtml +='<option value="N">N</option>';
        nhtml +='</select></td>';
        nhtml +='<td><select class="form-control" name="swe_medicalfacilities[]" id="swe_medicalfacilities'+i+'">';
        nhtml +='<option value="Y">Y</option>';
        nhtml +='<option value="N">N</option>';
        nhtml +='</select></td>';
        nhtml +='</tr>';
       
        $(".new_workexperience:last").after(nhtml);
      


    }


function process_sewadar_kyc(){
    var usePath           = $.trim( $("#rootXPath").val() );
    var formData          = new FormData();
    var other_data        = $('form#emp_kyc').serializeArray();
    var sw_sewcode        = $.trim( $("#sw_sewcode").val() );
    var skadhar           = $('#sk_adhar').get(0).files[0];
    var skpan             = $('#sk_pan').get(0).files[0];
    var skdlfile          = $('#sk_drivelicence').get(0).files[0];
    var skothdoc          = $('#sk_otherdoc').get(0).files[0];
    var skothdoc2         = $('#sk_otherdoc2').get(0).files[0];
    var usertype          = $.trim( $("#authorizeduser").val() );
    var sk_adharno        = $.trim( $("#sk_adharno").val() );
    var sk_panno          = $.trim( $("#sk_panno").val() );
    if( sk_adharno != '' ){
        if( sk_adharno.length <12){
            alert("Aadhaar number should be 12 digits.");
            $("#sk_adharno").focus()
            return false;
        }        
    }
    if( sk_panno != '' ){
        if( sk_panno.length <10){
            alert("PAN should be 10 digits.");
            $("#sk_panno").focus()
            return false;
        }        
    }
    if( typeof(skadhar) != "undefined" ){
          formData.append("skadhar", skadhar);
      }else{
          formData.append("skadhar", '');
      }

      if( typeof(skpan) != "undefined" ){
          formData.append("skpan", skpan);
      }else{
          formData.append("skpan", '');
      }
      if( typeof(skdlfile) != "undefined" ){
          formData.append("skdlfile", skdlfile);
      }else{
          formData.append("skdlfile", '');
      }
      if( typeof(skothdoc) != "undefined" ){
          formData.append("skothdoc", skothdoc);
      }else{
          formData.append("skothdoc", '');
      }
      if( typeof(skothdoc2) != "undefined" ){
          formData.append("skothdoc2", skothdoc2);
      }else{
          formData.append("skothdoc2", '');
      }
       
        formData.append("identity", "KYC");
        formData.append("sewcode", sw_sewcode);
        
        var file_data = $('.new_familydetail input[type="file"]');
        for (var i = 0; i < file_data.length; i++) {
            if( typeof(file_data[i].files[0]) !='undefined' ){
                formData.append("skf_attachment[]", file_data[i].files[0]);
            }else{
                formData.append("skf_attachment[]", '');
            }

        }
        $.each(other_data,function(key,input){
            formData.append(input.name,input.value);
        });

    
     $("#myselected_classname").val('maintain');
     $(".process_save").hide();
     $("#my_kyc_users").val('kyc');
    $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         
                        if( resp.status ){
                               $("#pull_messages").html(resp.message);
                               $("#process_message").modal("show");                               
                               
                        }else{
                                $("#pull_error_messages").html(resp.message);
                                $("#error_process_message").modal("show");
                                $("#my_kyc_users").val('');
                        }

                     },
                     error: function () {
                         $(".process_save").show();
                         $("#my_kyc_users").val('');
                     },
                     cache: false
             });
}


function process_work_experience(){
    var usePath           = $.trim( $("#rootXPath").val() );
    var formData          = new FormData();
    var other_data        = $('form#emp_work').serializeArray();
    var sw_sewcode        = $.trim( $("#sw_sewcode").val() );
    formData.append("identity", "WRKEXP");
    formData.append("sewcode", sw_sewcode);
    $.each(other_data,function(key,input){
        formData.append(input.name,input.value);
    });
     $(".process_save").hide();
    $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         $(".process_save").show();
                        if( resp.status ){
                               alert(resp.message);
                               window.location = usePath+"sewadar_information"
                               //$(".emp_kyc").trigger('click');
                        }else{

                            alert(resp.message);
                        }

                     },
                     error: function () {
                         $(".process_save").show();
                     },
                     cache: false
             });
}

function process_sewadar_facility(){
    var usePath           = $.trim( $("#rootXPath").val() );
    var formData          = new FormData();
    var other_data        = $('form#facility').serializeArray();
    var sw_sewcode        = $.trim( $("#sw_sewcode").val() );
    formData.append("identity", "FCLT");
    formData.append("sewcode", sw_sewcode);
    $.each(other_data,function(key,input){
        formData.append(input.name,input.value);
    });
     $(".process_save").hide();
    $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                         $(".process_save").show();
                        if( resp.status ){
                               alert(resp.message);
                               $(".maintain").trigger('click');
                        }else{

                            alert(resp.message);
                        }

                     },
                     error: function () {
                         $(".process_save").show();
                     },
                     cache: false
             });
}
function process_branch_headoffices(types){
        if( types == 'Head Office' ){
            $("#sw_location").show();
             $("#sw_brnchs").hide();
             $(".sewa_location").removeClass("hidden");
             $(".sewa_zones").removeClass("hidden").addClass("hidden");
        }else{
             $("#sw_brnchs").show();
             $("#sw_location").hide();
             $(".sewa_zones").removeClass("hidden");
             $(".sewa_location").removeClass("hidden").addClass("hidden");
        }
}

function process_sewadar_maintaince(){
    var usePath           = $.trim( $("#rootXPath").val() );
    var formData          = new FormData();
    var other_data        = $('form#maintain').serializeArray();
    var sw_sewcode        = $.trim( $("#sw_sewcode").val() );
    var slabamt           = $.trim( $("#so_healthslab").val() );
    var licgroup          = $.trim( $("#so_licgroups").val() );
    var healthgroup       = $.trim( $("#so_healthinsurances").val() );
    var electexmption     = "";
    var accomoexmption    = "";
    var electrisconsup    = $.trim( $("#sk_electricconsumption").val() );
    var accmvals          = $.trim( $("#sk_accomodations").val() );
    var catgs             = $.trim( $("#sk_category").val() );
    var intworks          = $.trim( $("#sk_internwork").val() );
    var physcl            = $.trim($("#sk_physicalissue").val() );
    var so_basic          = $.trim($("#so_basic").val() );
    var accmtype          = $.trim($("#sk_accomotype").val() );
    if( $("input[name='sw_electricexemption']").is(":checked") ){
        electexmption = $("input[name='sw_electricexemption']:checked").val();
    }
    if( $("input[name='sw_accomodexemption']").is(":checked") ){
        accomoexmption = $("input[name='sw_accomodexemption']:checked").val();
    }
    if( so_basic <=0 ){
        alert("MA/Basic is required.");
         $("#so_basic").focus()
         return false;
    }else if( licgroup == '' ){
         alert("LIC group is required.");
         $("#so_licgroups").focus()
         return false;
     }else if( healthgroup == '' ){
        alert("Health group is required.");
        $("#so_healthinsurances").focus()
        return false;
    }else if( slabamt<=0 ){
        if( healthgroup == 'Y' ){
            alert("Health Slab is required.");
            $("#so_healthslab").focus()
            return false;
        }
        
    }else if( electrisconsup == '' ){
        alert("Electric consumption is required.");
        $("#sk_electricconsumption").focus()
        return false;
    }
    if( electrisconsup != '' ){
        if( accmvals == ''){
            alert("Accomodation is required.");
            $("#sk_accomotype").focus()
            return false;
            }
    }
    if( intworks == '' ){
        alert("International worker is required.");
        $("#sk_internwork").focus()
        return false;
    }else if( catgs == '' ){
        alert("Category is required.");
        $("#sk_category").focus()
        return false;
    }else if( physcl == '' ){
        alert("Physically handicap is required.");
        $("#sk_physicalissue").focus()
        return false;
    }

    if( accmvals == 'Y' ){
        if( accmtype == '' ){
            alert("Accommodation type is required.");
            $("#sk_physicalissue").focus()
            return false;
        }
    }

    formData.append("identity", "MNTNC");
    formData.append("sewcode", sw_sewcode);
    formData.append("electexmption", electexmption);
    formData.append("accomoexmption", accomoexmption);
    formData.append("slabamt", slabamt);
    formData.append("licgroup", licgroup);
    formData.append("healthgroup", healthgroup);
    $.each(other_data,function(key,input){
        formData.append(input.name,input.value);
    });
     $(".process_save").hide();
     $("#myselected_classname").val('mymaintain');
    $.ajax({
                     url: usePath+"sewadar_information/ajax_process",
                     type: 'POST',
                     data: formData,
                     async: false,
                     contentType: false,
                     processData: false,
                     success: function (resp) {
                        
                        if( resp.status ){
                               $("#pull_messages").html(resp.message);
                               $("#process_message").modal("show");   
                              
                        }else{
                               $("#pull_error_messages").html(resp.message);
                               $("#error_process_message").modal("show");
                        }

                     },
                     error: function () {
                         $(".process_save").show();
                     },
                     cache: false
             });
}
function process_search_sewadar(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"sewadar_information/search");
    $("form#myforms").submit();
}
   $("#sw_date_of_birth").click(function() {
         $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){ add_retirement_dated();} }).datepick("show");
    });

    $("#so_joiningdate").click(function() {
         $(this).datepick({ dateFormat: "dd-M-yyyy" ,onSelect:function(evt){ get_total_sewa_dated();} }).datepick("show");
    });

   $(document).on("click","input[name='skf_datebirth[]']",function(){
      $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });
    $(document).on("click","input[name='swe_from[]']",function(){
      $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });
     $(document).on("click","input[name='swe_to[]']",function(){
      $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });
      
    // $("#so_regularizationdate").click(function() {
    // $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    // });
    // $("#so_leavingdate").click(function() {
    // $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    // });
    $("#sw_date_of_birth").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    $("#so_settmentdate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    // $("#so_fullfinaldate").click(function() {
    // $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    // });
    $("#sp_gyandate").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    $("#swe_from1").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    $("#swe_to1").click(function() {
    $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    $("#skf_datebirth1").click(function() {
       $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    $("#sewadar_fromdate").click(function() {
       $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });

    $("#sewadar_uptodate").click(function() {
       $(this).datepick({ dateFormat: "dd-M-yyyy" }).datepick("show");
    });




