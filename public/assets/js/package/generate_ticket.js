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
function selected_my_ratings(vls){
    
    $("#my_selected_ratings").val(vls);
}
function porcess_ticket_information(){
     var usePath    = $.trim( $("#userXRoot").val() );
     var usertypes  = $.trim( $("#process_usertypes").val() );
     var ticketno   = $.trim( $("#my_ticket_number").val() );
     var tkdate     = $.trim( $("#my_ticket_date").val() );
     var assgto     = $.trim( $("#my_assignedto").val() );
     var levels     = $.trim( $("#my_levels").val() );
     var resolution = $.trim( $("#my_resolutions").val() );
     var feedback   = $.trim( $("#my_feedbacks").val() );
     var ratings    = $.trim( $("#my_selected_ratings").val() );
     var myststus   = $.trim( $("#my_select_status").val() );
     var ticketno   = $.trim( $("#my_ticket_number").val() );
     
     if( ticketno == '' ){
         alert("Ticket number is required");
         return false;
     }else if( assgto == ''){
         alert("Assign is required.");
         $("#my_assignedto").focus()
         return false;
     }
     $.ajax({
                     url: usePath+"loans_advance/ajax_process",
                     type: 'POST',
                     data: {'identity':'ATC','usertypes':usertypes,'ticketno':ticketno,'tkdate':tkdate,'assgto':assgto,'levels':levels,'resolution':resolution,'feedback':feedback,'ratings':ratings,'myststus':myststus},
                     async: false,
                     success: function (resp) {
                         alert(resp.message)
						 if( myststus == 'S' ){
							 $("#my_resolutions").focus();
						 }
                       if( resp.status){
                         $("#feedback").modal("hide");
                         window.location = window.location.href
                       }

                     },
                     error: function () {

                     },
                     cache: false
         });
}

function get_tiket_detail_listed(ticketno,mystatus,assiggns,ids){
            var usePath    = $.trim( $("#userXRoot").val() );
             var usertypes = $.trim( $("#process_usertypes").val() );
            var isassigned  =  $.trim( $("#assignedUsr").val() );
            var attachment  = $.trim( $("#myticketno"+ids).val() );
           
            if( attachment != '' ){
                $(".myloadattachment").removeClass("hidden");
                $("#viewmyattachment").attr("href",attachment);
            }else{
                $(".myloadattachment").removeClass("hidden").addClass("hidden");
                $("#viewmyattachment").attr("href","#");
            }
            
                if(  mystatus =='O' || mystatus == '' ){
						 $(".process_status").removeClass("hidden");
						 $(".hideresolution").removeClass("hidden").addClass("hidden");
						 $(".hidefeedback").removeClass("hidden").addClass("hidden");
						 $(".hideratings").removeClass("hidden").addClass("hidden");
						 if( usertypes != 'swd' ){
							 $("#assigned_status").html('');
						 }else{
							$("#assigned_status").html('Ticket Under Process'); 
						 }
                 }else{
					   
					  if( usertypes == 'swd' || usertypes == 'stf' ){
						     if(  mystatus =='S' ){
								 $(".process_status").removeClass("hidden");
								 $(".hideresolution").removeClass("hidden");
								 $(".hidefeedback").removeClass("hidden");
								 $(".hideratings").removeClass("hidden");								 
								 $(".resolved_status").removeClass("hidden").addClass("hidden");
							 }else if(  mystatus =='A' ){
                                 $(".process_status").removeClass("hidden");
								 $(".hideresolution").removeClass("hidden").addClass("hidden");
								 $(".hidefeedback").removeClass("hidden").addClass("hidden");
								 $(".hideratings").removeClass("hidden").addClass("hidden");
								 $(".resolved_status").removeClass("hidden");								 
							 }else{								  
								 $(".process_status").removeClass("hidden");
								 $(".hideresolution").removeClass("hidden");
								 $(".hidefeedback").removeClass("hidden").addClass("hidden");
								 $(".hideratings").removeClass("hidden").addClass("hidden");
								 $(".resolved_status").removeClass("hidden");
							 }
					  }else{
						     $("#my_select_status").val('S');
						     $(".process_status").removeClass("hidden");
							 $(".hideresolution").removeClass("hidden");
							 $(".hidefeedback").removeClass("hidden").addClass("hidden");
							 $(".hideratings").removeClass("hidden").addClass("hidden");
							 $(".resolved_status").removeClass("hidden");
					  }
                     
                 }

                 if( usertypes != 'swd' && usertypes != 'stf' ){
                    if(  mystatus =='O' ||mystatus =='A' ){
                        $("#my_select_status").prop("disabled",true)
                    }
                }else{
                    $("#my_select_status").prop("disabled",false) 
                }
                

             $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'ticketno': ticketno,'identity':'GTC'},
                             async: false,
                             success: function (resp) {
                               
                               if( resp.status){
                                  var sdata = resp.data;
                                  $("#my_ticket_number").val(sdata.rt_ticketno);
                                  $("#my_ticket_date").val(sdata.ticketdated);
                                  $("#selected_my_queries").html(sdata.rt_queryissue);
                                  $("#my_raise_department").val(resp.raseddeprtment);
                                   if( sdata.rt_status !='O'){
                                       $("#my_levels").val(sdata.rt_priorty);
                                   }
                                  
                                  if( sdata.rt_status !='O'){
                                      $("#assigned_status").html('');
                                      $(".process_save_newone").removeClass("hidden");
                                  }else{
                                      if( usertypes == 'ict' || usertypes == 'hr' ){
                                          $(".process_save_newone").removeClass("hidden");
                                      
                                      }else{
                                         $(".process_save_newone").removeClass("hidden").addClass("hidden");
                    
                                      }
                                      
                                  }
                                  $("#my_assignedto").val(sdata.rt_assignedsewacode);

                                  if( mystatus =='A'){
                                      $("#my_select_status").val('S');
                                  }
                                  
                                  $("#view_resolution").val(sdata.rt_resolveremark);
                                  $("#view_feed_backs").val(sdata.rt_feeback);
                                  if( usertypes == 'swd'){
                                      if( sdata.rt_status == 'S'){
                                          $(".process_status").removeClass("hidden");
                                      }else{
                                          $(".process_status").removeClass("hidden").addClass("hidden");
                                      }
                                  }else{
                                      $(".process_status").removeClass("hidden");
                                  }
                                 
                                  if(sdata.rt_status == 'C' ){
                                    $(".process_save_newone").removeClass("hidden").addClass("hidden");
                                  }
                                  if( sdata.rt_status == 'C' || sdata.rt_status == 'S' ){
                                    if( usertypes != 'swd' && usertypes != 'stf' ){
                                        $("#my_feedbacks").prop("readonly",true);
                                    }else{
                                        $("#my_feedbacks").prop("readonly",false);
                                    }
                                    $(".hideratings").removeClass("hidden");
                                    $(".hidefeedback").removeClass("hidden");
                                    
                                    if( sdata.rt_rating == 1){
                                        htmlrate = '<input type="radio"  onclick="selected_my_ratings(5);" id="star5" name="rating" value="5"><label for="star5" title="5 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(4);" id="star4" name="rating" value="4"><label for="star4" title="4 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(3);" id="star3" name="rating" value="3"><label for="star3" title="3 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(2);" id="star2" name="rating" value="2"><label for="star2" title="2 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(1);" id="star1" name="rating" value="1"><label  class="activen" for="star1" title="1 star"></label>';
                                        htmlrate += '<br/>&nbsp;';
                                        htmlrate += '<span></span> <br/>'; 
                                    }else if(  sdata.rt_rating == 2 ){
                                        htmlrate = '<input type="radio"  onclick="selected_my_ratings(5);" id="star5" name="rating" value="5"><label for="star5" title="5 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(4);" id="star4" name="rating" value="4"><label for="star4" title="4 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(3);" id="star3" name="rating" value="3"><label for="star3" title="3 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(2);" id="star2" name="rating" value="2"><label class="activen" for="star2" title="2 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(1);" id="star1" name="rating" value="1"><label  class="activen" for="star1" title="1 star"></label>';
                                        htmlrate += '<br/>&nbsp;';
                                        htmlrate += '<span></span> <br/>'; 

                                    }else if(  sdata.rt_rating == 3 ){
                                        htmlrate = '<input type="radio"  onclick="selected_my_ratings(5);" id="star5" name="rating" value="5"><label for="star5" title="5 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(4);" id="star4" name="rating" value="4"><label for="star4" title="4 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(3);" id="star3" name="rating" value="3"><label class="activen" for="star3" title="3 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(2);" id="star2" name="rating" value="2"><label class="activen" for="star2" title="2 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(1);" id="star1" name="rating" value="1"><label  class="activen" for="star1" title="1 star"></label>';
                                        htmlrate += '<br/>&nbsp;';
                                        htmlrate += '<span></span> <br/>'; 

                                    }else if(  sdata.rt_rating == 4 ){
                                        htmlrate = '<input type="radio"  onclick="selected_my_ratings(5);" id="star5" name="rating" value="5"><label for="star5" title="5 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(4);" id="star4" name="rating" value="4"><label class="activen" for="star4" title="4 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(3);" id="star3" name="rating" value="3"><label class="activen" for="star3" title="3 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(2);" id="star2" name="rating" value="2"><label class="activen" for="star2" title="2 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(1);" id="star1" name="rating" value="1"><label  class="activen" for="star1" title="1 star"></label>';
                                        htmlrate += '<br/>&nbsp;';
                                        htmlrate += '<span></span> <br/>'; 

                                    }else if(  sdata.rt_rating == 5 ){
                                        htmlrate = '<input type="radio"  onclick="selected_my_ratings(5);" id="star5" name="rating" value="5"><label class="activen" for="star5" title="5 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(4);" id="star4" name="rating" value="4"><label class="activen" for="star4" title="4 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(3);" id="star3" name="rating" value="3"><label class="activen" for="star3" title="3 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(2);" id="star2" name="rating" value="2"><label class="activen" for="star2" title="2 star"></label>';
                                        htmlrate += '<input type="radio" onclick="selected_my_ratings(1);" id="star1" name="rating" value="1"><label  class="activen" for="star1" title="1 star"></label>';
                                        htmlrate += '<br/>&nbsp;';
                                        htmlrate += '<span></span> <br/>'; 

                                    }                                    
                                                            
                                    $(".myused_ratings").html(htmlrate);
                                   
                                  }else{
                                       $(".hideratings").removeClass("hidden").addClass("hidden");; 
                                  }


                               }
                               
                             },
                             error: function () {

                             },
                             cache: false
                 });


}

function alertChecked(url){
    if( confirm("Are you sure want to delete ?")){
        window.location = url
    }
}

function alertCancellChecked(url){
    if( confirm("Are you sure want to cancel ?")){
        window.location = url
    }
}
function filter_tickets(){
    var useroot = $("#userXRoot").val();
    $("form#myforms").attr("action",useroot+"generate_ticket/ticket_list/search");
    $("form#myforms").submit();
}
   $("#rt_ticketdate").click(function() {

        $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

    });
    $("#from_dated").click(function() {

        $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

    });
    $("#upto_dated").click(function() {

        $(this).datepick({dateFormat: "dd-M-yyyy"}).datepick("show");

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