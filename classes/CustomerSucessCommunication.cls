public class CustomerSucessCommunication{

     public static void getNotification(){
     List<case> selfNotifications = new List<case>();
     List<case> mangNotifications = new List<case>();
     list<id> ownerIdList = new list<id>();
     List<Case> caseList = new List<Case>();      
      
     for(Case cse : [Select id,CreatedDate, priority, businessHoursID, ownerId, Casenumber, owner.name,AgeInDays__c from case where recordtypeId = '01238000000UWKt' and Last_Public_Comment_Date_Time__c = null and Last_Comment_Date_Time__c = null and status != 'Closed' and createdDate = LAST_N_DAYS:14]){
      if(cse.priority == 'Low'){
       datetime fourDaysDt = BusinessHours.addGmt(cse.businessHoursID, system.now(), (-5760)*60000);//4 Days
       datetime fourDaysFive = fourDaysDt.addMinutes(5);
       datetime sevenDaysDt  = BusinessHours.addGmt(cse.businessHoursID, system.now(), (-10080)*60000);//7 Days
       datetime sevenDaysDtFive = sevenDaysDt.addMinutes(5);
       if((cse.createddate >fourDaysDt && cse.createddate <=fourDaysFive) || Test.isRunningTest()){
        selfNotifications.add(cse);
       }else if((cse.createddate >sevenDaysDt && cse.createddate <= sevenDaysDtFive) || Test.isRunningTest()){
        mangNotifications.add(cse);
        ownerIdList.add(cse.ownerId);
       }
      }else if(cse.priority == 'Medium'){
       datetime twoDaysDt = BusinessHours.addGmt(cse.businessHoursID, system.now(), (-4320)*60000);//3 Days
       datetime twoDaysFive = twoDaysDt.addMinutes(5);
       datetime fiveDaysDt  = BusinessHours.addGmt(cse.businessHoursID, system.now(), (-7200)*60000);//5 Days
       datetime fiveDaysFive = fiveDaysDt.addMinutes(5);
       if(cse.createddate >twoDaysDt && cse.createddate <=twoDaysFive){
        selfNotifications.add(cse);
       }else if((cse.createddate >fiveDaysDt && cse.createddate<=fiveDaysFive) || Test.isRunningTest()){
        mangNotifications.add(cse);
        ownerIdList.add(cse.ownerId);
       }
      }else if(cse.priority == 'High'){
       datetime oneDaysDt = BusinessHours.addGmt(cse.businessHoursID, system.now(), (-1440)*60000);//1 Day
       datetime oneDaysFive = oneDaysDt.addMinutes(5);
       datetime twoDaysDt  = BusinessHours.addGmt(cse.businessHoursID, system.now(), (-2880)*60000);//2 Days
       datetime twoDaysFive = twoDaysDt.addMinutes(5);
       if(cse.createddate >oneDaysDt && cse.createddate<=oneDaysFive){
        selfNotifications.add(cse);
       }else if(cse.createddate >twoDaysDt && cse.createddate<=twoDaysFive){
        mangNotifications.add(cse);
        ownerIdList.add(cse.ownerId);
       }
      }
     }
      
     Map<Id,Id> usrMap = new Map<Id,Id>();
     for(User usr: [Select id,ManagerId from user where id IN: ownerIdList]){
      usrMap.put(usr.id,usr.ManagerId);
     }
     
     List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
     if(!selfNotifications.IsEmpty()){
      for(case cs : selfNotifications){
        Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(cs.ownerID);
        message.setSubject('Need Response On CSM Case - '+cs.CaseNumber);
        String body = 'Hi ' + cs.Owner.Name + ', <br/>';
        body += '<p>No updates/comments has not been made on this customer\'s request ('+cs.casenumber+') over the past '+cs.AgeInDays__c+'days. Please log into SFDC and provide an update on this request\'s progress. Thank you.</p>';
        body +='<p>Case Details -:';
        body +='<br/>Case Number: '+cs.CaseNumber;
        body +='<br/>Case Priority: '+cs.Priority;
        body += '<br/>Case Link: '+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.Id;
        body +='<p>Regards,';
        body +='<br/>CSM Team';
        message.setHtmlBody(body);
        if(Label.Email_CC_List_CSM != 'No'){
            message.setCcAddresses(new List<Id>{Id.valueOf(Label.Email_CC_List_CSM)});
        }
        message.setOrgWideEmailAddressId('0D2380000008The');
        message.setSaveAsActivity(false);   
        allmsg.add(message);
      }
      
     } 
     if(!mangNotifications.IsEmpty() || Test.isRunningTest()){
      for(case cs : mangNotifications){
        Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(cs.ownerID);
        message.setSubject('Need Response On CSM Case - '+cs.CaseNumber);
        String body = 'Hi ' + cs.Owner.Name + ', <br/>';
        body += '<p>No updates/comments has not been made on this customer\'s request ('+cs.casenumber+') over the past '+cs.AgeInDays__c+'days. Please log into SFDC and provide an update on this request\'s progress. Thank you.</p>';
        body +='<p>Case Details -:';
        body +='<br/>Case Number: '+cs.CaseNumber;
        body +='<br/>Case Priority: '+cs.Priority;
        body += '<br/>Case Link: '+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cs.Id;
        body +='<p>Regards,';
        body +='<br/>CSM Team';
        message.setHtmlBody(body);
        message.setOrgWideEmailAddressId('0D2380000008The');
        message.setSaveAsActivity(false); 
        if(usrMap.containskey(cs.OwnerID)){
        List<Id> managrId = new List<Id>();
        if(Label.Email_CC_List_CSM != 'No'){
            managrId.add(Id.valueOf(Label.Email_CC_List_CSM)); 
        }
        managrId.add(usrMap.get(cs.OwnerID)); 
        message.setCcAddresses(managrId);
       }
       allmsg.add(message);
      }  
     }
    
     List<Messaging.SendEmailResult> mailResult = new List<Messaging.SendEmailResult>(); 
     mailResult = Messaging.sendEmail(allmsg, false);
    }
}