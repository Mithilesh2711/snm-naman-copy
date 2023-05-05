$("#newallowedcheckpassword").keydown(function (event) {
    var keycode  = (event.keyCode ? event.keyCode : event.which);
    if ( keycode == 13 ) {   //enter key
        setTimeout(function(){ get_user_activity_locked(); },500);         
     }

});

function send_user_otp_detail(){
   
    var usePath   =  $.trim( $("#globalrootaccess").val() );   
    var userid    =  $.trim( $("#otp_userid").val() );
     if( userid == ''  ){
        return false ;
     }

     $.ajax({
          url: usePath+"login/ajax_process",
          type: 'POST',
          data: {'identity' : 'SNDOTP','userid' : userid },
          async: false,
          success: function (resp) {
             
              if( resp.message !='' ){
                 alert(resp.message);
              }
              

          },
          error: function () {

          },
          cache: false
  });
}

function reset_text_boxes(){
    $("#otp_userid").val('');
    $("#otp_number").val('');
}

function validate_user_otp_detail(){
    var usePath   =  $.trim( $("#globalrootaccess").val() );   
    var userid    =  $.trim( $("#otp_userid").val() );
    var otpno     = $.trim( $("#otp_number").val() );
     if( userid == ''  ){
        alert("Userid is required");
        return false ;    
     }else if( otpno == '' ){
         alert("Please enter otp number");
         return false;
     }


     $.ajax({
          url: usePath+"login/ajax_process",
          type: 'POST',
          data: {'identity':'VFOTP','userid' : userid,'otp_number': otpno },
          async: false,
          success: function (resp) {
              if( resp.message !='' ){
                 alert(resp.message);
              }
              
              if( resp.status ){
                   $("#exampleModal").modal("hide");
                   $("#otp_userid").val('');
                   $("#otp_number").val('');
                   setTimeout(function(){ reset_text_boxes(); },500);
              }

          },
          error: function () {

          },
          cache: false
    });
}

function get_selected_tds_listed(types,url){
            var usePath  =  $.trim( $("#globalrootaccess").val() );        
           
                $.ajax({
                             url: usePath+"loans_advance/ajax_process",
                             type: 'POST',
                             data: {'identity':'LINKUSER','processuser':types},
                             async: false,
                             success: function (resp) {
                                 window.location = url;
                                 
                             },
                             error: function () {

                             },
                             cache: false
             });
			 

}

function myidleLogout() {
    var t;
    window.onload = resetTimer;
    window.onmousemove = resetTimer;
    window.onmousedown = resetTimer;  // catches touchscreen presses as well
    window.ontouchstart = resetTimer; // catches touchscreen swipes as well
    window.onclick = resetTimer;      // catches touchpad clicks as well
    window.onkeydown = resetTimer;
    window.addEventListener('scroll', resetTimer, true); // improved; see comments

    function process_idle_listing() {
        //alert("hello")
        $("#userloginposteddata").modal("show");
        var clid = "#newallowedcheckpassword";
        find_user_activity_done();
        common_focus_select(clid)
        // your function for too long inactivity goes here
        // e.g. window.location.href = 'logout.php';
    }

    function resetTimer() {
        clearTimeout(t);
        t = setTimeout(process_idle_listing, 3000000);  // time is in milliseconds # 900000
    }
}
myidleLogout();
function get_user_activity_locked(){
                var usePath      = $.trim( $("#myidlepathactive").val() );
                var password     = $.trim( $("#newallowedcheckpassword").val() );
                if( password == '' ){
                    alert("Please enter password.");
                    return false;
                }
                $.ajax({
                     url: usePath+"material_issue/ajax_process",
                     type: 'POST',
                     data: {'password': password,'indedntity':'CHKCRD'},
                     async: false,
                     success: function (resp) {
                          if( resp.status){
                            $("#userloginposteddata").modal("hide");
                          }else{
                              alert(resp.message);
                              return false;
                          }

                     },
                     error: function () {

                     },
                     cache: false
             });
    }

    function find_user_activity_done(){
        var usePath      = $.trim( $("#myidlepathactive").val() );
       
        $.ajax({
             url: usePath+"material_issue/ajax_process",
             type: 'POST',
             data: {'indedntity':'ACTIVE'},
             async: false,
             success: function (resp) {
                  

             },
             error: function () {

             },
             cache: false
     });

    }


