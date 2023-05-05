class UserMailMailer < ApplicationMailer
  
def send_common_message(mobiles,messages,template_id)
  api_key  = '46017979D9B5EB';
  contacts =  mobiles;
template = template_id;
  senders  = 'INQUIS'
  sms_text = messages
 
#   sendURL  = "http://kutility.in/app/smsapi/index.php?key="+api_key+"&campaign=10728&routeid=7&type=text&contacts="+contacts+"&senderid="+senders+"&msg="+sms_text;
sendURL="https://www.smsgatewayhub.com/api/mt/SendSMS?APIKey=M6DNgM6KxEK6yhadi9Rr6w&senderid=SNMAPP&channel=2&DCS=0&flashsms=0&number="+contacts.to_s+"&text="+sms_text.to_s+"&route=1"+"&EntityId=1301159066873503911"+"&dlttemplateid="+template.to_s;

# https://www.smsgatewayhub.com/api/mt/SendSMS?APIKey=M6DNgM6KxEK6yhadi9Rr6w&senderid=SNMAPP&channel=2&DCS=0&flashsms=0&number=918287662408&text=OTP%20for%20login%20is%201234.%20-%20Sant%20Nirankari%20Mandal&route=31&EntityId=1301159066873503911&dlttemplateid=1207161734996230285
#sendURL = "https://www.smsgatewayhub.com/api/mt/SendSMS?apikey=M6DNgM6KxEK6yhadi9Rr6w&channel=2&DCS=0&type=text&number="+contacts+"&senderid="+senders+"&message="+sms_text+"&template_id=1207161734996230285";
  RestClient.post sendURL,:body=>''
end



end
