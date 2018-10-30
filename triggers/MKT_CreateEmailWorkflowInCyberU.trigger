/************************/
/****************************************************
Trigger Name: MKT_CreateEmailWorkflowInCyberU
Author: Vrp,
Created Date: 5/17/2013
Usage: This class used for creating temp object for send emails
*****************************************************
GRAZITTI :: In order to impelemnt timezone dynamically, we changed code as follows --
Modified Date: 1/17/2014
*****************************************************/

trigger MKT_CreateEmailWorkflowInCyberU on lmsilt__Roster__c (after insert, after update, after delete) {    
    List<MKT_Email_Workflow_in_CyberU__c> eWorkflowList = new List<MKT_Email_Workflow_in_CyberU__c>();                                                     
    Set<Id> RosterIdSet = new Set<Id>();                                                      
    Map<Id, List<lmsilt__Roster__c>> ClassIdRosterListMap = new Map<Id, List<lmsilt__Roster__c>>();
    Map<Id, Id> ClassIdUserMap = new Map<Id, Id>();                                                      
    Set<Id> ProductSet = new Set<Id>();                                                      
    Set<Id> UserSet = new Set<Id>();                                                      
    List<lmsilt__Roster__c> rostersForUpdate = new List<lmsilt__Roster__c>();   
                                                           
    if (Trigger.isInsert && Trigger.isAfter) {                
        List<lmsilt__Roster__c> rosters = [SELECT ID, lmsilt__Status__c, lmsilt__Student__c, lmsilt__Student__r.Name, lmsilt__Student__r.ContactId, lmsilt__Class__c,lmsilt__Student__r.TimeZoneSidKey,lmsilt__Class__r.lmsilt__Event__c,  lmsilt__Class__r.lmsilt__Start_Date__c,lmsilt__Class__r.Name,lmsilt__Class__r.lmsilt__End_Date__c,lmsilt__Class__r.lmsilt__Location__r.lmsilt__Room__c,lmsilt__Class__r.lmsilt__Location__r.Name,lmsilt__Class__r.lmsilt__Location__r.ArrivalText__c,lmsilt__Class__r.lmsilt__Location__r.Accommodations__c,lmsilt__Class__r.lmsilt__Event__r.Product__c, lmsilt__Class__r.lmsilt__Location__r.lmsilt__Street_Address__c,lmsilt__Class__r.lmsilt__Location__r.lmsilt__State__c,  lmsilt__Class__r.lmsilt__Location__r.lmsilt__Postal_code__c,lmsilt__Class__r.lmsilt__Event__r.Name, lmsilt__Class__r.lmsilt__Event__r.lmsilt__Description__c, MKT_Opportunity__c FROM lmsilt__Roster__c WHERE ID IN :trigger.new];                                                                  
        for (lmsilt__Roster__c RosterItem : rosters) {            
            ProductSet.Add(rosterItem.lmsilt__Class__r.lmsilt__Event__r.Product__c);                                                              
            UserSet.Add(rosterItem.lmsilt__Student__c);                                                              
            List<lmsilt__Roster__c> RostersList;                                                             
            if (ClassIdRosterListMap.containsKey(RosterItem.lmsilt__Class__c)) {                 
                RostersList =  ClassIdRosterListMap.get(RosterItem.lmsilt__Class__c);                                                                               
            }            
            else RostersList = new List<lmsilt__Roster__c>();  
            
            RostersList.Add(RosterItem);                                                              
            ClassIdRosterListMap.put(RosterItem.lmsilt__Class__c, RostersList);                                                          
        }  
              
        List<MKT_PaymentLicense__c> PaymentLicenseList = [Select User__c, MKT_Payment__r.MKT_Opportunity__c, MKT_Payment__r.Product__c, MKT_Payment__r.Account__c,MKT_Payment__c From MKT_PaymentLicense__c WHERE User__c IN :UserSet AND MKT_Payment__r.Product__c IN :ProductSet AND Canceled__c = false AND MKT_Payment__r.MKT_Opportunity__c != NULL];                                                          
        for (lmsilt__Roster__c rosterItem :rosters) {            
            for(MKT_PaymentLicense__c pl : PaymentLicenseList){                
                if (rosterItem.MKT_Opportunity__c == NULL && rosterItem.lmsilt__Student__c == pl.User__c && rosterItem.lmsilt__Class__r.lmsilt__Event__r.Product__c == pl.MKT_Payment__r.Product__c) {                  
                    rosterItem.MKT_Opportunity__c = pl.MKT_Payment__r.MKT_Opportunity__c;
                    rostersForUpdate.Add(rosterItem);                                                                    
                    break;                                                                  
                }              
            }        
        } 
               
        Map<String,List<lmsilt__Session__c>> classWithSessions = new Map<String,List<lmsilt__Session__c>>();                                                          
        for(lmsilt__Class__c cls : [SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c, lmsilt__Location__r.Name, lmsilt__Location__r.lmsilt__City__c, lmsilt__Location__r.lmsilt__Contact_Phone__c, lmsilt__Location__r.lmsilt__Country__c, lmsilt__Location__r.lmsilt__Postal_code__c, lmsilt__Location__r.lmsilt__Region__c, lmsilt__Location__r.lmsilt__Room__c, lmsilt__Location__r.lmsilt__State__c, lmsilt__Location__r.lmsilt__Street_Address__c,lmsilt__Location__r.lmsilt__Type__c, lmsilt__Location__r.lmsilt__ZIP__c,lmsilt__Location__r.ArrivalText__c,lmsilt__Location__r.Accommodations__c,(SELECT Id, IsDeleted, Name, lmsilt__ILT_vILT__c, lmsilt__Time_Zone__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, MKT_MultiDaySession__c FROM lmsilt__Sessions__r ORDER BY lmsilt__Start_Date_Time__c),(SELECT lmsilt__Error__c, lmsilt__JoinUrl__c, lmsilt__confirmationUrl__c, lmsilt__registrantKey__c FROM lmsilt__GoToTraining_Sessions__r) FROM lmsilt__Class__c WHERE Id IN :ClassIdRosterListMap.keySet()]) {                                                        
            classWithSessions.put(cls.Id,cls.lmsilt__Sessions__r);                                                         
        }
        List<lmsilt__Material__c> MaterialsList = [SELECT Id, lmsilt__Class__c, lmsilt__Sequence__c, lmsilt__Description__c, lmsilt__Instructions__c, Name, (SELECT Id, Name FROM Attachments) FROM lmsilt__Material__c WHERE lmsilt__Class__c IN :ClassIdRosterListMap.keySet() /*OR lmsilt__Event__c IN :EventIdSet*/];                                                          
        Map<Id, List<lmsilt__Material__c>> ClassIdMaterialsBeforeMap = new Map<Id, List<lmsilt__Material__c>>();                                                          
        Map<Id, List<lmsilt__Material__c>> ClassIdMaterialsAfterMap = new Map<Id, List<lmsilt__Material__c>>();                                                  
        for (lmsilt__Material__c MaterialItem : MaterialsList) {            
            if (MaterialItem.lmsilt__Sequence__c == 'Anytime' || MaterialItem.lmsilt__Sequence__c == NULL || MaterialItem.lmsilt__Sequence__c == 'Before') {                
                List<lmsilt__Material__c> MaterialsListBefore = new List<lmsilt__Material__c>();                                                                  
                if (ClassIdMaterialsBeforeMap.containsKey(MaterialItem.lmsilt__Class__c)) {                    
                    MaterialsListBefore = ClassIdMaterialsBeforeMap.get(MaterialItem.lmsilt__Class__c);                                                                      
                    MaterialsListBefore.Add(MaterialItem);                                                                  
                }else{                    
                    MaterialsListBefore.Add(MaterialItem);                                                                  
                }                
                ClassIdMaterialsBeforeMap.put(MaterialItem.lmsilt__Class__c, MaterialsListBefore);                                                              
            }else if (MaterialItem.lmsilt__Sequence__c == 'after'){                
                List<lmsilt__Material__c> MaterialsListAfter = new List<lmsilt__Material__c>();                                                                  
                if (ClassIdMaterialsBeforeMap.containsKey(MaterialItem.lmsilt__Class__c)){                    
                    MaterialsListAfter = ClassIdMaterialsAfterMap.get(MaterialItem.lmsilt__Class__c);
                    MaterialsListAfter.Add(MaterialItem);                                                                  
                }else {                    
                    MaterialsListAfter.Add(MaterialItem);                                                                  
                }                
                ClassIdMaterialsAfterMap.put(MaterialItem.lmsilt__Class__c, MaterialsListAfter);                                                              
            }      
        }        

        Map<String,String> userwithTimeZone = new Map<String,String>();                                                               
        Map<String,String> rosterWithTimeZone = new Map<String,String>();                                                                  
        for(lmsilt__Roster__c eachRoster : rosters){            
            if (!classWithSessions.get(eachRoster.lmsilt__Class__c).isEmpty()){                
                if(classWithSessions.get(eachRoster.lmsilt__Class__c)[0].lmsilt__ILT_vILT__c == 'ILT'){                   
                    System.debug('ClassTimeZone=='); 
                    rosterWithTimeZone.put(eachRoster.ID, classWithSessions.get(eachRoster.lmsilt__Class__c)[0].lmsilt__Time_Zone__c ); 
                } else{
                    System.debug('OnlineTimeZone==');   
                    rosterWithTimeZone.put(eachRoster.ID, eachRoster.lmsilt__Student__r.TimeZoneSidKey ); 
                } 
            }  
        }
        for (lmsilt__Roster__c RosterItem : rosters) {
            if (RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c == NULL) continue;
            
            /*Timezone Handling*/       
             String STUDENTTIMEZONE = 'PST';
             String customerTimeZoneSidId;
             TimeZone customerTimeZone;  
             if(rosterWithTimeZone.containsKey(RosterItem.Id)){
                 customerTimeZoneSidId = rosterWithTimeZone.get(RosterItem.Id);  
                 if(customerTimeZoneSidId != null){
                     customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId);
                     STUDENTTIMEZONE = customerTimeZone.getDisplayName(); 
                 } 
             }
             if(customerTimeZoneSidId != null){
                 if(customerTimeZoneSidId.startsWith('(')){
                     if(customerTimeZoneSidId.startsWith('(GMT') && customerTimeZoneSidId.length()>10){
                         customerTimeZoneSidId = customerTimeZoneSidId.substring(11).trim();
                         Integer firstIndex = customerTimeZoneSidId.indexOf('(');  
                         Integer lastIndex = customerTimeZoneSidId.lastIndexOf(')');    
                         customerTimeZoneSidId = customerTimeZoneSidId.substring(firstIndex+1,lastIndex); 
                         customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId); 
                         STUDENTTIMEZONE = customerTimeZone.getId(); 
                     }else if(customerTimeZoneSidId.startsWith('(')){
                         customerTimeZoneSidId = customerTimeZoneSidId.substring(1,customerTimeZoneSidId.length()-1);
                         customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId);
                         STUDENTTIMEZONE = customerTimeZone.getId();   
                     }            
                  }  
              }else{
                  customerTimeZoneSidId = 'America/Los_Angeles';
                  customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId);
                  STUDENTTIMEZONE = customerTimeZone.getId();
              }        
              System.debug(customerTimeZoneSidId +'customerTimeZoneSidId ===>'); 
              System.debug(STUDENTTIMEZONE +'STUDENTTIMEZONE ===>'+customerTimeZone); 
              MKT_Email_Workflow_in_CyberU__c eWorkflow = new MKT_Email_Workflow_in_CyberU__c();   
              eWorkflow.Class__c          = RosterItem.lmsilt__Class__c;  
              eWorkflow.ClassName__c      = RosterItem.lmsilt__Class__r.Name;  
              eWorkflow.ClassStartTime__c = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.format('h:mm a', customerTimeZoneSidId);   
              eWorkflow.ClassStartDate__c = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', customerTimeZoneSidId) +' '+ STUDENTTIMEZONE; 
              eWorkflow.ClassEndTime__c   = RosterItem.lmsilt__Class__r.lmsilt__End_Date__c.format('h:mm a', customerTimeZoneSidId);
              eWorkflow.LocationRoom__c   = RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Room__c;  
              eWorkflow.LocationName__c   = RosterItem.lmsilt__Class__r.lmsilt__Location__r.Name;
              eWorkflow.ArrivalText__c    = RosterItem.lmsilt__Class__r.lmsilt__Location__r.ArrivalText__c;
              eWorkflow.Accommodations__c = RosterItem.lmsilt__Class__r.lmsilt__Location__r.Accommodations__c;
              System.debug(STUDENTTIMEZONE +'STUDENTTIMEZONE ===>'+eWorkflow.ClassStartTime__c+'::'+eWorkflow.ClassStartDate__c+':::'+eWorkflow.ClassEndTime__c); 
              System.debug(RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c+'Date ===>'+RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.format('h:mm a', customerTimeZoneSidId));
              eWorkflow.Location__c       = ' '; 
              if (RosterItem.lmsilt__Class__r.lmsilt__Location__r.Name != NULL && RosterItem.lmsilt__Class__r.lmsilt__Location__r.Name != '') { 
                  eWorkflow.Location__c += RosterItem.lmsilt__Class__r.lmsilt__Location__r.Name; 
              } 
              if (RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Street_Address__c != NULL && RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Street_Address__c != '') {
                   eWorkflow.Location__c +=', ' + RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Street_Address__c; 
              }  
              if (RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__State__c != NULL && RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__State__c != '') {  
                   eWorkflow.Location__c +=', ' + RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__State__c ;  
              } 
              if (RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Postal_code__c != NULL && RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Postal_code__c != '') {
                  eWorkflow.Location__c +=', ' + RosterItem.lmsilt__Class__r.lmsilt__Location__r.lmsilt__Postal_code__c;  
              }
              eWorkflow.EventName__c = RosterItem.lmsilt__Class__r.lmsilt__Event__r.Name; 
              eWorkflow.CourseDescription__c = (RosterItem.lmsilt__Class__r.lmsilt__Event__r.lmsilt__Description__c != NULL) ? ('<pre><span style = "font-size: 10pt; font-family:\'Arial\',\'Helvetica\',\'sans-serif\'">• ' + RosterItem.lmsilt__Class__r.lmsilt__Event__r.lmsilt__Description__c + '</span></pre>') : '';
              eWorkflow = updateReminderDate(eWorkflow,RosterItem,customerTimeZoneSidId);
              eWorkflow.Sessions__c = '<ul>';  
              eWorkflow.SessionsVirtual__c = '<ul>';
              Integer NumberOfSessionsVirtual = 0;  
              Integer NumberOfSessions = 0;         
              if(classWithSessions.containsKey(RosterItem.lmsilt__Class__c)){  
                  for (lmsilt__Session__c SessionItem : classWithSessions.get(RosterItem.lmsilt__Class__c)) {
                      Integer NumberOfSessionsTemp = 1;  
                      String DatesSession = '<li><span><b>' + SessionItem.lmsilt__Start_Date_Time__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', customerTimeZoneSidId) + ' ' + SessionItem.lmsilt__Start_Date_Time__c.format('h:mm a', customerTimeZoneSidId) + ' - ' + SessionItem.lmsilt__End_Date_Time__c.format('h:mm a', customerTimeZoneSidId) + ' '+STUDENTTIMEZONE+'</b></span></li>';
                      if (SessionItem.MKT_MultiDaySession__c) { 
                          Integer SessionDays = SessionItem.lmsilt__End_Date_Time__c.Day() -  SessionItem.lmsilt__Start_Date_Time__c.Day(); 
                          for (Integer i = 1; i <= SessionDays; i++) {
                               DatesSession += '<li><span><b>' + SessionItem.lmsilt__Start_Date_Time__c.addDays(i).format('EEEEEEEEE, MMMMMMMMM dd, yyyy', customerTimeZoneSidId) + ' ' + SessionItem.lmsilt__Start_Date_Time__c.format('h:mm a', customerTimeZoneSidId) + ' - ' + SessionItem.lmsilt__End_Date_Time__c.format('h:mm a', customerTimeZoneSidId) + ' '+STUDENTTIMEZONE+'</b></span></li>';  
                               NumberOfSessionsTemp++; 
                          } 
                      } 
                      
                      if (SessionItem.lmsilt__ILT_vILT__c == 'vILT') { 
                          eWorkflow.IsVirtual__c        = true;   
                          eWorkflow.SessionsVirtual__c += DatesSession;
                          NumberOfSessionsVirtual      += NumberOfSessionsTemp;
                      }     
                      if (SessionItem.lmsilt__ILT_vILT__c == 'ILT') { 
                          eWorkflow.IsClassroom__c = true;       
                          eWorkflow.Sessions__c += DatesSession; 
                          NumberOfSessions += NumberOfSessionsTemp;
                      }  
                    }
                }  
                eWorkflow.Sessions__c += '</ul>'; 
                eWorkflow.SessionsVirtual__c += '</ul>'; 
                eWorkflow.NumberOfSessions__c = String.valueOf(NumberOfSessions); 
                eWorkflow.NumberOfSessionsVirtual__c = String.valueOf(NumberOfSessionsVirtual);  
                if (eWorkflow.IsVirtual__c == true && eWorkflow.IsClassroom__c == false) { 
                    eWorkflow.ClassType__c = Label.MKT_Virtual;  
                }
                if (eWorkflow.IsVirtual__c == true && eWorkflow.IsClassroom__c == true) {
                    eWorkflow.ClassType__c = Label.MKT_ClassroomVirtual; 
                }  
                if (eWorkflow.IsVirtual__c == false && eWorkflow.IsClassroom__c == true) {   
                    eWorkflow.ClassType__c = Label.MKT_Classroom; 
                }
                if (ClassIdMaterialsBeforeMap.containsKey(RosterItem.lmsilt__Class__c)) {  
                    eWorkflow.ClassMaterials__c = '<ul>'; 
                    for (lmsilt__Material__c MaterialsBefore : ClassIdMaterialsBeforeMap.get(RosterItem.lmsilt__Class__c)) { 
                        for (Attachment attachmentItem : MaterialsBefore.Attachments) { 
                            eWorkflow.ClassMaterials__c += '<li><a href = "' + Label.MKT_LinkFileDownload+'?file='+ attachmentItem.id + '">' + attachmentItem.Name + '</a></li>';
                        } 
                    }   
                    eWorkflow.ClassMaterials__c += '</ul>';   
                }  
                if (ClassIdMaterialsAfterMap.containsKey(RosterItem.lmsilt__Class__c)) { 
                    eWorkflow.ClassMaterialsAfter__c = '<ul>'; 
                    for (lmsilt__Material__c MaterialsAfter : ClassIdMaterialsAfterMap.get(RosterItem.lmsilt__Class__c)) {
                        for (Attachment attachmentItem : MaterialsAfter.Attachments) {
                            eWorkflow.ClassMaterialsAfter__c += '<li><a href = "' + Label.MKT_LinkFileDownload+'?file='+ attachmentItem.id + '">' + attachmentItem.Name + '</a></li>';
                        } 
                    }   
                    eWorkflow.ClassMaterialsAfter__c += '</ul>';
                } 
                eWorkflow.User__c         = RosterItem.lmsilt__Student__c; 
                eWorkflow.MKT_Username__c = RosterItem.lmsilt__Student__r.Name;  
                eWorkflow.Status__c       = RosterItem.lmsilt__Status__c;  
                eWorkflowList.Add(eWorkflow);    
             
            }          
          /**Dml Operations to send Workflow and update Roster**/   
          if (!eWorkflowList.isEmpty())
          try {
              insert eWorkflowList;
          }catch(Exception e){} 
          if (!rostersForUpdate.isEmpty()) 
          try {
              update rostersForUpdate;  
           }catch(Exception e){} 
        
        
}
      if (Trigger.isUpdate) {   
           Set<Id> RosterOldIdSet = new Set<Id>();
           Map<String,lmsilt__Roster__c> rosterWorkflowGettingUpdated = new Map<String,lmsilt__Roster__c>();  
           Set<Id> classIds = new Set<Id>();   
           for (lmsilt__Roster__c oldRoster : trigger.old) {
               if (!oldRoster.lmsilt__Attended__c)
                   RosterOldIdSet.add(oldRoster.Id); 
               
            } 
           for (lmsilt__Roster__c newRoster : [SELECT ID,lmsilt__Attended__c , lmsilt__Class__c, lmsilt__Class__r.lmsilt__Start_Date__c,lmsilt__Class__r.lmsilt__End_Date__c, lmsilt__Student__c,lmsilt__Status__c, lmsilt__Student__r.Name FROM lmsilt__Roster__c WHERE ID IN :trigger.new]) {
               if (newRoster.lmsilt__Attended__c && newRoster.lmsilt__Status__c !='Cancelled' && RosterOldIdSet.contains(newRoster.Id)) {             
                  RosterIdSet.add(newRoster.Id);
                  ClassIdUserMap.put(newRoster.lmsilt__Class__c, newRoster.lmsilt__Student__c); 
              }  
               if((Trigger.oldMap.get(newRoster.Id).lmsilt__Status__c!= (newRoster.lmsilt__Status__c))){   
                  rosterWorkflowGettingUpdated.put(newRoster.lmsilt__Student__c,newRoster);   
                  classIds.add(newRoster.lmsilt__Class__c);     
               } 
                UserSet.Add(newRoster.lmsilt__Student__c);    
           } 
           
           for (lmsilt__Roster__c RosterItem : [SELECT ID, lmsilt__Class__c, lmsilt__Class__r.lmsilt__Start_Date__c,lmsilt__Class__r.lmsilt__End_Date__c,lmsilt__Student__c,lmsilt__Status__c, lmsilt__Student__r.Name FROM lmsilt__Roster__c WHERE ID IN :RosterIdSet]) { 
                List<lmsilt__Roster__c> RostersList;    
                if (ClassIdRosterListMap.containsKey(RosterItem.lmsilt__Class__c)) {
                    RostersList =  ClassIdRosterListMap.get(RosterItem.lmsilt__Class__c);  
                } else RostersList = new List<lmsilt__Roster__c>();
                RostersList.Add(RosterItem); 
                ClassIdRosterListMap.put(RosterItem.lmsilt__Class__c, RostersList);
           }        
           
           Map<String,String> userwithTimeZone = new Map<String,String>(); 
           for(User usr: [Select Id,TimeZoneSidKey from User where Id IN : UserSet]){ 
               userwithTimeZone.put(usr.ID, usr.TimeZoneSidKey );   
           }  
           List<MKT_Email_Workflow_in_CyberU__c> workflowTobeUpdated = new List<MKT_Email_Workflow_in_CyberU__c>();
           for(MKT_Email_Workflow_in_CyberU__c workflow : [select ClassStartDate__c ,Status__c,User__c ,Class__c,RegistrationReminders3Date__c,RegistrationReminders2Date__c,RegistrationReminders1Date__c from MKT_Email_Workflow_in_CyberU__c where User__c in :rosterWorkflowGettingUpdated.keyset() and class__c in :classIds ]){            if(rosterWorkflowGettingUpdated.containsKey(workflow.User__c) && rosterWorkflowGettingUpdated.get(workflow.User__c).lmsilt__Class__c == workflow.Class__c){ 
               workflow.Status__c = rosterWorkflowGettingUpdated.get(workflow.User__c).lmsilt__Status__c;
                   if(workflow.Status__c =='Cancelled'){
                       workflow.RegistrationReminders1Date__c = NULL;
                       workflow.RegistrationReminders2Date__c = NULL;
                       workflow.RegistrationReminders3Date__c = NULL; 
                   }else{
                        if(workflow.ClassStartDate__c != null) 
                        workflow = updateReminderDate(workflow,rosterWorkflowGettingUpdated.get(workflow.User__c),userwithTimeZone.get(workflow.User__c));    
                   }
                   
                   workflowTobeUpdated.add(workflow);
            } 
        } 
        for (lmsilt__Class__c ClassItem : [SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c FROM lmsilt__Class__c WHERE Id IN :ClassIdRosterListMap.keySet()]) {
            if (ClassItem.lmsilt__Start_Date__c == NULL) continue;
                for (lmsilt__Roster__c RosterItem : ClassIdRosterListMap.get(ClassItem.Id)) { 
                    String STUDENTTIMEZONE = 'PST';
                    String customerTimeZoneSidId;
                    if(userwithTimeZone.containsKey(RosterItem.lmsilt__Student__c))
                    customerTimeZoneSidId = userwithTimeZone.get(RosterItem.lmsilt__Student__c);
                    TimeZone customerTimeZone = TimeZone.getTimeZone(customerTimeZoneSidId);   
                    STUDENTTIMEZONE = customerTimeZone.getDisplayName(); 
                    System.debug(STUDENTTIMEZONE +'STUDENTTIMEZONE ===>'); 
                    MKT_Email_Workflow_in_CyberU__c eWorkflow = new MKT_Email_Workflow_in_CyberU__c();
                    eWorkflow.User__c = RosterItem.lmsilt__Student__c;  
                    eWorkflow.ClassName__c = ClassItem.Name;   
                    eWorkflow.Class__c = ClassItem.Id; 
                    eWorkflow.ClassStartTime__c = ClassItem.lmsilt__Start_Date__c.format('h:mm a', customerTimeZoneSidId);      
                    eWorkflow.ClassStartDate__c = ClassItem.lmsilt__Start_Date__c.format('EEEEEEEEE, MMMMMMMMM dd, yyyy', customerTimeZoneSidId) +' '+STUDENTTIMEZONE;
                    eWorkflow.ClassEndTime__c = ClassItem.lmsilt__End_Date__c.format('h:mm a', customerTimeZoneSidId);
                    eWorkflow.EventName__c = ClassItem.lmsilt__Event__r.Name;
                    eWorkflow.CourseDescription__c = (ClassItem.lmsilt__Event__r.lmsilt__Description__c!= NULL) ? ('<pre><span style = "font-size: 10pt;  font-family:\'Arial\',\'Helvetica\',\'sans-serif\'">• ' + ClassItem.lmsilt__Event__r.lmsilt__Description__c + '</span></pre>') : ''; 
                    eWorkflow.IsAttended__c = true;  
                    eWorkflow.MKT_Username__c = RosterItem.lmsilt__Student__r.Name; 
                    eWorkflow.Status__c = RosterItem.lmsilt__Status__c; 
                    eWorkflowList.add(eWorkflow);  
               }
           } 
           if(!workflowTobeUpdated.isEmpty()) 
           try{
               update workflowTobeUpdated; 
           }catch (Exception e){} 
           if (eWorkflowList.size() > 0) { 
                try{
                    insert eWorkflowList;
                }catch (Exception e){}
           } 
         } 
         
    if (Trigger.isDelete && Trigger.isAfter) {        
        Set<Id> UserIds = new Set<Id>();                                                          
        Map<Id, Set<ID>> ClassIdRosterSetMap = new Map<Id, Set<Id>>();                                                          
        for (lmsilt__Roster__c oldRoster : trigger.old) {
            Set<ID> RosterUsersSet;                                                              
            if (ClassIdRosterSetMap.containsKey(oldRoster.lmsilt__Class__c)) {                 
                RosterUsersSet =  ClassIdRosterSetMap.get(oldRoster.lmsilt__Class__c);                                                              
            }            
            else RosterUsersSet = new Set<ID>();                                                             
            RosterUsersSet.Add(oldRoster.lmsilt__Student__c);                                                             
            ClassIdRosterSetMap.put(oldRoster.lmsilt__Class__c, RosterUsersSet);                                                              
            UserIds.Add(oldRoster.lmsilt__Student__c);                                                          
        }
        for(MKT_Email_Workflow_in_CyberU__c emailWorkflowItem : [SELECT ID, Class__c, User__c FROM MKT_Email_Workflow_in_CyberU__c WHERE Class__c IN : ClassIdRosterSetMap.keySet() AND User__c IN :UserIds]) {            
            if (ClassIdRosterSetMap.get(emailWorkflowItem.Class__c).contains(emailWorkflowItem.User__c))                
                eWorkflowList.Add(emailWorkflowItem);      
        }        
        if (eWorkflowList.size() > 0) {            
            try{delete eWorkflowList;                                                  
            }catch(exception e){}        
        }    
    }
        
    private MKT_Email_Workflow_in_CyberU__c updateReminderDate(MKT_Email_Workflow_in_CyberU__c eWorkflow,lmsilt__Roster__c RosterItem,String customerTimeZoneSidId){                      
        DateTime Reminder3 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addHours(-2);                                                              
        DateTime Reminder2;                                                              
        DateTime Reminder1;                                                              
        String dayOfWeek = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.format('EEE', customerTimeZoneSidId);                                                              
        if (dayOfWeek == 'Mon') {                
            Reminder2 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-3);                                                                  
            Reminder1 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-5);                                                              
        }else if (dayOfWeek == 'Tue') {                
            Reminder2 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-4);                                                                  
            Reminder1 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-6);                                                              
        }else if (dayOfWeek == 'Wed') {                
            Reminder2 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-2);                                                                  
            Reminder1 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-5);                                                              
            RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-2);
            Reminder1 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-6);}            
        else if (dayOfWeek == 'Fri') {                
          Reminder2 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-2);                                                                  
          Reminder1 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-4);                                                              
        }            
        else{                
          Reminder2 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-2);                                                                  
          Reminder1 = RosterItem.lmsilt__Class__r.lmsilt__Start_Date__c.addDays(-4);                                                              
        }            
         eWorkflow.RegistrationReminders1Date__c = (Reminder1 > system.now()) ? Reminder1 : NULL;
         eWorkflow.RegistrationReminders2Date__c = (Reminder2 > system.now()) ? Reminder2 : NULL;
         eWorkflow.RegistrationReminders3Date__c = Reminder3;                                                              
         return eWorkflow;                                                      
     }    
}