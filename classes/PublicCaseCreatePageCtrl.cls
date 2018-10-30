public class PublicCaseCreatePageCtrl{
    public Case c { get; set; }        
    public String selContactId { get;set; }   
    public String selContactName { get;set; }   
    public String phNum { get; set; }
    public string accessPwd { get; set; }     
    public String emailAdd { get; set; }
    public String selectedPriority { get; set; }
    public String category{ get; set; }
    public List<SelectOption> selectOptions{get;set;}
    public List<User> usrDetail{get;set;}
    public string callfunc {get;set;}
    
    //public boolean showCaseDetail{get;set;}
    //public Case csDetail{get;set;}       
    public Case NagiosCase{get;set;}
    //public String contactOnBehalf{get;set;}
    //public String accOnBehalf{get;set;} 
    
    public Case ca {get;set;}
    
    public PublicCaseCreatePageCtrl(ApexPages.StandardController controller) {
        usrDetail = new List<user>();
        this.ca = (Case)controller.getRecord(); 
        usrDetail = [select id, Name, managerId from User where id =:this.ca.OwnerId];  
        contactOnBehalf = usrDetail[0].Name;
        accOnBehalf ='Marketo Demo 17';
        system.debug('accOnBehalf ==>'+accOnBehalf );
        targetIdAccount = this.ca.accountID;
        targetIdContact = this.ca.Contact.Id;
        EmailList = UserInfo.getUserEmail();
        getCategoryValue();
        system.debug('targetIdAccount ==> ' + targetIdAccount );
        system.debug('targetIdContact ==> ' + targetIdContact );
        
        SMCase = new Case(recordTypeId = '01250000000UK1E',parentId = this.ca.id, Situation_Contact__c = targetIdContact, Situation_Account__c = targetIdAccount,Email_List__c = EmailList);

    }  

    public String targetIdAccount{get;set;}
    public String targetIdContact{get;set;}        
    //public String selContactId { get;set; }   
    //public String selContactName { get;set; }   
    public boolean showCaseDetail{get;set;}
    public Case csDetail{get;set;}       
    public Case SMCase{get;set;}
    public string contactOnBehalf{get;set;}
    public string accOnBehalf{get;set;}
    public string EmailList{get;set;}
    
    public PublicCaseCreatePageCtrl() {        
        system.debug(' default==> ');        
        SMCase = new Case(recordTypeId = '01250000000UK1E');
        c = new Case(recordTypeId = '01250000000UJwxAAG',Origin='Answer Service', Case_Issue__c = 'Generic');
        NagiosCase = new Case(recordTypeId = '01250000000UJwxAAG', Origin='CPT', Problem_Type__c = 'Nagios Alert');
    }

    public pagereference refreshPanel(){ 
        showCaseDetail=true;       
        return null;    
    }
   
    public PageReference createSMCase() {   
        system.debug('enter createSMCase====>>>>>');
        if(accOnBehalf == null) { ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Account'); ApexPages.addMessage(msg); return null; }        
        if(contactOnBehalf == null) { ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Contact');ApexPages.addMessage(msg); return null; }                        
        try {             
            List<contact> contList = new List<contact>();
            contList = [select id, name, accountid from contact where name =:contactOnBehalf and name !=null and Accountid = '0015000000Xu1Kc' limit 1];
            if(contList.size() >0){
                SMCase.Situation_Contact__c = contList[0].Id;
                SMCase.Situation_Account__c = contList[0].Accountid; 
                system.debug('## Inside1 ' +SMCase.Situation_Contact__c);
                system.debug('## Inside1 ' + SMCase.Situation_Account__c);
            }else{
                Contact NewContact = new Contact();
                NewContact.FirstName = UserInfo.getFirstName();
                NewContact.LastName = UserInfo.getLastName();
                NewContact.Email = UserInfo.getUserEmail();
                NewContact.Accountid = '0015000000Xu1Kc';
                insert newContact;
                SMCase.Situation_Contact__c = NewContact.Id;
                SMCase.Situation_Account__c = NewContact.Accountid;
                system.debug('## Inside2 ' +SMCase.Situation_Contact__c);
                system.debug('## Inside2 ' + SMCase.Situation_Account__c);
            }                                     
            SMCase.ParentId = ca.Id;
            SMCase.Origin = userinfo.getProfileId() == Label.CustomerSuccessProfileId ?'Customer Success':'Support';
            SMCase.Email_List__c = EmailList;
            SMCase.Problem_Type__c = 'Manager Review';
            SMCase.Category__c = category;
            Map<Id,Map<Id,Boolean>> teamMap = n2de.DistributionEngineGlobal.getUserAvailabilityAllTeams();
            system.debug('Reach Level 2===>>>'+teamMap.keyset());               
            id t = label.escalCaseFromPOrtalTeam;
            Map<Id,Boolean> test = teamMap.get(t);
            system.debug('######Test ' +test +' '+ test.containskey(usrDetail[0].ManagerId) +' '+test.get(usrDetail[0].ManagerId));
            if(test.containskey(usrDetail[0].ManagerId) && test.get(usrDetail[0].ManagerId) == True){
                SMCase.OwnerId = usrDetail[0].ManagerId;
            }else{
               SMCase.OwnerId = '00G50000001R8aQ'; 
            }
            /*if(usrDetail[0].ManagerId != null){
                SMCase.OwnerId = usrDetail[0].ManagerId;
            }else{
                SMCase.OwnerId = '00G50000001R8aQ';   //support escalation queue
            }*/
           
            // Specify DML options to ensure the assignment rules are executed
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = false;
            SMCase.setOptions(dmlOpts);
            //Insert the case
            INSERT SMCase;
            
            system.debug('SMCase --> ' + SMCase);     
            
            csDetail = [SELECT caseNumber from case where id = :SMCase.id Limit 1];        
            //ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Case Created ' + csDetail.caseNumber);
            //ApexPages.addMessage(msg);
            SMCase = new Case(recordTypeId = '01250000000UK1E');        
            selContactId = '';   
            selContactName = '';   
            accOnBehalf = '';
            contactOnBehalf = '';
            callfunc='<script> CloseAndReWfresh(); </script>';                              
            return null;                    
        } catch (Exception e) { ApexPages.addMessages(e);return null; } 
          
    }    
    
    
    
    public pagereference checkPwd(){        
        return null;    
    }
 
    
    public PageReference submitCase() {
        if(selContactId == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Contact');
            ApexPages.addMessage(msg);
            return null;
        }
        try {            
            contact selContact = [SELECT Id, AccountID from Contact where id = :selContactId  Limit 1];
            c.AccountId = selContact.AccountId;                
            // now look for an associated contact with the same email
            c.ContactId = selContact.Id;
            system.debug('selectedPriority-->'+selectedPriority); 
            c.Priority = selectedPriority;                            
            // Specify DML options to ensure the assignment rules are executed
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;c.setOptions(dmlOpts);
            //Insert the case
            INSERT c;
            system.debug('case-->'+c);
                 
            Case cs = [SELECT caseNumber from case where id = :c.id Limit 1];        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Case Created ' + cs.caseNumber);
            ApexPages.addMessage(msg);
            c = new Case(recordTypeId = '01250000000UJwxAAG',Origin='Answer Service', Case_Issue__c = 'Generic');        
            selContactId = '';   
            selContactName = '';                            
            phNum = '';     
            return null;                    
        } catch (Exception e) { ApexPages.addMessages(e); return null; }        
    }
     
    public List<SelectOption> getCategoryValue(){
        selectOptions = new List<SelectOption>();
        for(String val : Label.SM_PickList_Values.split(';')){
            selectOptions.add(new SelectOption(val,val));
        }
         return selectOptions;
    }
    public PageReference createNagiosCase() {
        if(accOnBehalf == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Account');
            ApexPages.addMessage(msg);
            return null;
        }        
        if(contactOnBehalf == null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Invalid Contact');
            ApexPages.addMessage(msg);
            return null;
        }                        
        try {            
            // now look for an associated contact with the same email            
            system.debug('Prolem Type -->' + NagiosCase.Problem_Type__c); 
            NagiosCase.Priority = selectedPriority;                            
            // Specify DML options to ensure the assignment rules are executed
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule = true;
            NagiosCase.setOptions(dmlOpts);
            //Insert the case
            INSERT NagiosCase;
            
            system.debug('NagiosCase --> ' + NagiosCase);     
            
            csDetail = [SELECT caseNumber from case where id = :NagiosCase.id Limit 1];        
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, 'Case Created ' + csDetail.caseNumber);
            ApexPages.addMessage(msg);
            NagiosCase = new Case(recordTypeId = '01250000000UJwxAAG', Origin='CPT', Problem_Type__c = 'Nagios Alert');        
            selContactId = '';   
            selContactName = '';   
            accOnBehalf = '';
            contactOnBehalf = '';
                                     
            phNum = '';     
            return null;                    
        }  catch (Exception e) { ApexPages.addMessages(e); return null; } 
          
    }        
}