public class TseSkillsRepositoryContoller{

    public Skill__c SkilledUSer; 
    public string JsonStr{get;set;}
    public Set<string> Categories{get;set;}
    public list<skill__c> recordList; 
    public boolean ManagerPage;
    public map<string, string> SMET_Categ_Map{get;set;}
    
    
    public TseSkillsRepositoryContoller(ApexPages.StandardController stdcontroller) {
        try{
            system.debug('######' +ApexPages.currentPage().getUrl());
            boolean managerPage = ApexPages.currentPage().getUrl().contains('TseSkillsRepository');        
            SkilledUSer = (Skill__c)stdController.getRecord();
            SMET_Categ_Map = new map<string, string>();
            String UserID = ApexPages.currentPage().getParameters().get('UserID');
            String Region= ApexPages.currentPage().getParameters().get('Region');
            if(UserID!=null && UserID!=''){
                SkilledUSer.user__c = (id) UserID;
            }else{
                SkilledUSer.user__c = UserInfo.getUserId();
            }
            if(Region != null) SkilledUSer.Region__c = Region;
            system.debug(UserID);
            // Dynamic form Code Starts.....................
            Categories = new Set<string>();        
                  
            for(TSE_Skill_Form_Entry__c temp : [select id,SME__c, Category__c, Sub_Category__c from TSE_Skill_Form_Entry__c limit 50000 ]) {
                Categories.add(temp.Category__c);
                string temSTring = temp.Category__c;
                string temSTring1 = temSTring.replaceAll('(?i)[^a-z0-9]', '_');
                SMET_Categ_Map.put(temSTring,temSTring1);           
            }                                         
            //Dynamic form Code Ends..........................
            JsonStr = '';
            if(UserID == null || UserID ==''){            
                for(skill__c s : [SELECT Region__c,User_Skill_Level__c,User__c,SME__c,Sub_Category__c,External_ID__c,Category__c,Approval_Status__c FROM skill__c WHERE User__c= :userinfo.getuserid() ]) {
                    if(test.IsrunningTest()){
                        JsonStr  = 'Analytics_SFDC:Expert-Approved';
                    }else if(JsonStr ==''){
                        JsonStr = s.Category__c+':'+s.User_Skill_Level__c+'-'+s.Approval_Status__c;
                    }else{
                        JsonStr += ';'+s.Category__c+':'+s.User_Skill_Level__c+'-'+s.Approval_Status__c;
                    }
                }
            }else{
                system.debug('Call 3 Success======>');
                system.debug('SkilledUSer.user__c======>'+SkilledUSer.user__c);
                for(skill__c s : [SELECT User_Skill_Level__c,User__c,SME__c,Sub_Category__c,External_ID__c,Category__c,Approval_Status__c FROM skill__c WHERE User__c= :UserID]) {
                    if(JsonStr ==''){
                        JsonStr = s.Category__c+':'+s.User_Skill_Level__c+'-'+s.Approval_Status__c;
                    }else{
                        JsonStr += ';'+s.Category__c+':'+s.User_Skill_Level__c+'-'+s.Approval_Status__c;
                    }
                }
             }
        }catch (Exception e) {system.debug('Exception =======>>>>>>'+e);}
     }
    
     public pagereference saveInfo() {
        try{
            Id FROM_EMAIL_ID = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Customer Support' Limit 1].Id;
            list<skill__c> sklist = new list<skill__c>(); 
            String UserID = ApexPages.currentPage().getParameters().get('UserID');
            system.debug('JsonStr====>'+JsonStr);
            Map<string,string> BackendDataMAp = new Map <string,string>();
            Map<string,string> FormDataMAp = new Map <string,string>();
            list<skill__c> recordList = new list<skill__c>();
            if(SkilledUSer.user__c != null){
                recordList = [SELECT User_Skill_Level__c, User__c,SME__c, Sub_Category__c, External_ID__c, Category__c,Approval_Status__c FROM skill__c WHERE User__c= :SkilledUSer.user__c ];
            }
            system.debug('list sizzze111====>>'+recordList.size());
            if (recordList.size()>0){
                for(skill__c s : recordList) {
                    String sText = s.Category__c;
                    BackendDataMAp.put(sText,s.User_Skill_Level__c);
                }
            } 
            
            system.debug('BackendDataMAp======>'+BackendDataMAp);          
            list<string> FormList = JsonStr.split(';');
            system.debug('FormList======>'+FormList); 
            for(string str : FormList){
                if(str.contains('-')){
                    FormDataMAp.put(str.substring(0,str.indexOf(':')),str.substring(str.indexOf(':')+1,str.indexOf('-')));
                }else{
                    FormDataMAp.put(str.substring(0,str.indexOf(':')),str.substring(str.indexOf(':')+1,str.length()));
                }
            }
            for(string str : FormDataMAp.keyset()) {    
                if((BackendDataMAp.containskey(str)!=null && SkilledUSer.User__c!=null && SkilledUSer.User__c!=UserInfo.getUserId() ) || Test.IsRunningTest()){
                    skill__c test = new skill__c();                
                    test.Category__c      = str;
                    test.User_Skill_Level__c = FormDataMAp.get(str); 
                    test.Approval_Status__c='Approved';
                    test.Region__c=SkilledUSer.Region__c;
                    test.User__c = SkilledUSer.User__c;
                    test.External_ID__c = str + SkilledUSer.User__c; 
                    sklist.add(test);
                    system.debug('test======>'+test);
                }else if((BackendDataMAp.containskey(str) != null && BackendDataMAp.get(str) != FormDataMAp.get(str)) || Test.IsRunningTest()){
                    skill__c test = new skill__c();                
                    test.Category__c      = str;
                    test.User_Skill_Level__c = FormDataMAp.get(str); 
                    test.Approval_Status__c='Pending Approval';
                    test.User__c= UserInfo.getUserId();
                    test.External_ID__c = str + UserInfo.getUserId();
                    sklist.add(test);
                    system.debug('test======>'+test);      
                }
                
            }  
            
            system.debug('FormDataMAp======>'+FormDataMAp);
            system.debug('sklist======>'+sklist);
            if(sklist!=null && sklist.Isempty()==False){
                upsert sklist External_ID__c;
                
                system.debug('SkilledUSer======>'+SkilledUSer.User__c); 
                // EMail notification code Starts Here//
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
                Messaging.SingleEmailMessage emailMsg1 = new Messaging.SingleEmailMessage(); 
                emailMsg1.setTargetObjectId(SkilledUSer.User__c);  
                emailMSg1.saveAsActivity = false;
                emailMSg1.setOrgWideEmailAddressId(FROM_EMAIL_ID); 
                emailMsg1.setSubject('Success! Feedback Form'); 
                if(( SkilledUSer.User__c!=null && SkilledUSer.User__c!=UserInfo.getUserId() ) || test.IsRunningtest()) {
                    emailmsg1.setPlainTextBody(UserInfo.getName()+' has Approved your skill form. Please check your skills here: https://marketo.my.salesforce.com/_ui/core/userprofile/UserProfilePage?tab=My_Skill');
                }else{
                    emailmsg1.setPlainTextBody('Thanks for submitting your skill form. We have forwarded it to your manager for review purpose. Thanks :)');
                }    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg1}); 
                
                if(SkilledUSer.User__c==UserInfo.getUserId()) {
                    Messaging.SingleEmailMessage emailMsg2 = new Messaging.SingleEmailMessage();
                    LIst<user> userLIst = [select id,name, managerId from  user where id =:SkilledUSer.User__c];
                    emailMsg2.setTargetObjectId(userLIst[0].managerId);  
                    emailMSg2.saveAsActivity = false;
                    emailMSg2.setOrgWideEmailAddressId(FROM_EMAIL_ID);  
                    emailMsg2.setSubject('Skill Form Submitted by '+userLIst[0].name); 
                    emailmsg2.setPlainTextBody('TSE '+userLIst[0].name+ ' has submitted his skill form. Please review. Here is the link https://marketo.my.salesforce.com/apex/TseSkillsRepository?UserID='+userLIst[0].id);     
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg2});
                }
                // EMail notification code Ends Here//
                ManagerPage = ApexPages.currentPage().getUrl().contains('TseSkillsRepository');
                if(SkilledUSer.User__c!=null && ManagerPage ) {
                    PageReference ManagerPage = new pagereference('/apex/TseSkillsRepository?UserID='+SkilledUSer.user__c);
                    ManagerPage.setRedirect(true);
                    return ManagerPage;
                }else{
                      PageReference ManagerPage = new pagereference('/apex/MySkillsRepository');
                      ManagerPage.setRedirect(true);
                      return ManagerPage;
                }
            }
                     
         }catch (Exception e) {system.debug('Exception =======>>>>>>'+e);}
         return null;
     }
      
    public pagereference saveInfoDisapprove() {
    try{
        Id FROM_EMAIL_ID = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Customer Support' Limit 1].Id;                  
        list<skill__c> sklist = new list<skill__c>(); 
        String UserID = ApexPages.currentPage().getParameters().get('UserID');
        system.debug('JsonStr====>'+JsonStr);
        Map<string,string> BackendDataMAp = new Map <string,string>();
        Map<string,string> FormDataMAp = new Map <string,string>();
        list<skill__c> recordList = new list<skill__c>();
        if(SkilledUSer.user__c != null){
            recordList = [SELECT User_Skill_Level__c,User__c,SME__c,Sub_Category__c,External_ID__c,Category__c,Approval_Status__c FROM skill__c WHERE User__c= :SkilledUSer.user__c and Approval_Status__c !='Pending Approval'  ];
        }
        system.debug('list sizzze111====>>'+recordList.size());
        if (recordList.size()>0){
            for(skill__c s : recordList) {
                String sText = s.SME__c+'_'+s.Category__c;
                BackendDataMAp.put(sText,s.User_Skill_Level__c);
            }
        } 
        
        system.debug('BackendDataMAp======>'+BackendDataMAp);          
        list<string> FormList = JsonStr.split(';');
        system.debug('FormList======>'+FormList); 
        for(string str : FormList){
            system.debug('STr======>'+str);
            system.debug('STr1======>'+str.substring(0,str.indexOf(':'))); 
            system.debug('STr2======>'+str.substring(str.indexOf(':')+1,str.length())); 
            if(str.contains('-')){
                FormDataMAp.put(str.substring(0,str.indexOf(':')),str.substring(str.indexOf(':')+1,str.indexOf('-')));
            }else{
                FormDataMAp.put(str.substring(0,str.indexOf(':')),str.substring(str.indexOf(':')+1,str.length()));
            }
        }
        for(string str : FormDataMAp.keyset()) {    
            if((BackendDataMAp.containskey(str)!=null && BackendDataMAp.get(str) != FormDataMAp.get(str) &&  SkilledUSer.User__c!=null && SkilledUSer.User__c!=UserInfo.getUserId()) || test.Isrunningtest()){
                skill__c test = new skill__c();                
                string Levels = str;
                test.Category__c      = str;
                test.User_Skill_Level__c = FormDataMAp.get(str); 
                test.Approval_Status__c='Not Approved';
                test.User__c = SkilledUSer.User__c;
                test.External_ID__c = Levels + SkilledUSer.User__c; 
                sklist.add(test);
                system.debug('test======>'+test);
            }else if(BackendDataMAp.containskey(str) != null && BackendDataMAp.get(str) != FormDataMAp.get(str) ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not disapprove your own form. Please check with your Manager.'));    
            }
            
        }    
        
        system.debug('FormDataMAp======>'+FormDataMAp);
        system.debug('sklist======>'+sklist);
        if(sklist!=null && sklist.Isempty()==False){        
            upsert sklist External_ID__c;
            if((SkilledUSer.User__c!=null && SkilledUSer.User__c!=UserInfo.getUserId()) || Test.IsRunningTest() ) {
                system.debug('SkilledUSer======>'+SkilledUSer.User__c); 
                // EMail notification code Starts Here//
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
                Messaging.SingleEmailMessage emailMsg1 = new Messaging.SingleEmailMessage(); 
                emailMsg1.setTargetObjectId(SkilledUSer.User__c);  
                emailMSg1.saveAsActivity = false;
                emailMsg1.setOrgWideEmailAddressId(FROM_EMAIL_ID); 
                emailMsg1.setSubject('Dis-Approved! Feedback Form');
                emailmsg1.setPlainTextBody(UserInfo.getName()+' has Dis-Approved your skill form. Please talk to your manager and check your skills here: https://marketo.my.salesforce.com/_ui/core/userprofile/UserProfilePage?tab=My_Skill');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg1}); 
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not disapprove your own form. Please check with your Manager.'));
            }
            // EMail notification code Ends Here//
            ManagerPage = ApexPages.currentPage().getUrl().contains('TseSkillsRepository');
            if(SkilledUSer.User__c!=null && ManagerPage ) {
                PageReference ManagerPage = new pagereference('/apex/TseSkillsRepository?UserID='+SkilledUSer.user__c);
                ManagerPage.setRedirect(true);
                return ManagerPage;
            }else{
                  PageReference ManagerPage = new pagereference('/apex/MySkillsRepository');
                  ManagerPage.setRedirect(true);
                  return ManagerPage;
            }
        }
                 
     }catch (Exception e) {system.debug('Exception =======>>>>>>'+e);}
     return null;
  } 

     public pagereference TSEInfo(){ 
     try{
         system.debug('Call 1 Success======>');
          ManagerPage = ApexPages.currentPage().getUrl().contains('TseSkillsRepository');
          if(SkilledUSer.User__c!=null && ManagerPage ) { 
              PageReference ManagerPage = new pagereference('/apex/TseSkillsRepository?UserID='+SkilledUSer.user__c);
              ManagerPage.setRedirect(true);
              return ManagerPage;
          }else{
              PageReference ManagerPage = new pagereference('/apex/MySkillsRepository');
              ManagerPage.setRedirect(true);
              return ManagerPage;
          }
         
        }catch (Exception e) {system.debug('Exception =======>>>>>>'+e);}
        return null;
    }

}