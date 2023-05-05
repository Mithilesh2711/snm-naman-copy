$("#userPassword").keydown(function (event) {
             var keycode  = (event.keyCode ? event.keyCode : event.which);
             if ( keycode == 13 ) { //enter key
                var password  = $.trim( $("#userPassword").val() );
                var users     = $.trim( $("input[name='userName'").val() );
               if( users!= '' && password!= '' ){
                   user_logins();
               }

            }

     });
     $(".account-btn").keydown(function (event) {
             var keycode  = (event.keyCode ? event.keyCode : event.which);
             if ( keycode == 13 ) { //enter key
                var password  = $.trim( $("#userPassword").val() );
                var users     = $.trim( $("input[name='userName'").val() );
               if( users!= '' && password!= '' ){
                   user_logins();
               }

            }

     });

    function set_login_user_focus(){
         $("input[name='userName']").focus();
    }
    function user_logins(){
   $("#myforms").submit();
}