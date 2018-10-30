global class TSEQualityBatch implements Database.Batchable<Mentor_TSE_Table__c>{
    global List<Mentor_TSE_Table__c> mentorTseList = new List<Mentor_TSE_Table__c>();
    global Set<Id> mentorIds = new Set<Id>();
    public TSEQualityBatch(){
       mentorTseList = Database.Query(Label.QaMentorProcessQuery);      
    }
    global Iterable<Mentor_TSE_Table__c> start (database.batchablecontext BC){
        return (mentorTseList);
    }      
 
    global void execute(Database.BatchableContext BC, List<Mentor_TSE_Table__c> scope){
        try{
            List<Store_Cases_By_Week__c> weekList = new List<Store_Cases_By_Week__c>();
            Map<Id,Integer> evalCount = new Map<Id,Integer>();
            Map<Id,Integer> numberOfCasePerTSe = new Map<Id,Integer>();
            Map<Id,Id> mentorTseMap = new Map<Id,Id>();
            Set<Id> tseIds = new Set<Id>();
            List<Case> cseList = new List<Case>();
            Map<Id,List<case>> tseCaseMap = new Map<Id,List<case>>();
            List<Mentor_TSE_Table__c> mtList = new List<Mentor_TSE_Table__c>();
            Set<String> inValidCaseCloseReasons  = new Set<String>{'Spam','Duplicate','Invalid Case'};
            String weekCounter = ''; 
            weekCounter  = getWeekCount();
            List<case> caseList = new List<case>();
            for(Mentor_TSE_Table__c log : scope){
                mentorTseMap.put(log.Trainee_Name__c,log.Mentor_Name__c);
            }
            if(!Test.isRunningTest()) caseList = [SELECT id,OwnerId from case where OwnerId in : mentorTseMap.keySet() and status = 'Closed' and Close_Reason__c NOT IN : inValidCaseCloseReasons and recordtypeId =: Label.SupportCaseRecordTypeId and closeddate = Last_week];
            else caseList = [SELECT id,OwnerId from case limit 10];
    
            for(Case cseObj : caseList){
                cseList.add(cseObj);
                if(tseCaseMap.containskey(cseObj.ownerid)){
                    tseCaseMap.get(cseObj.OwnerId).add(cseObj);
                }
                else{
                    tseCaseMap.put(cseObj.OwnerId,new list<case>{cseObj});
                }
            }
            Set<Mentor_TSE_Table__c> mentors = new Set<Mentor_TSE_Table__c>();
            for(Mentor_TSE_Table__c  tseObj : [SELECT id,Mentor_Name__c,Trainee_Name__c,Mentor_Name__r.name,Trainee_Name__r.name from Mentor_TSE_Table__c where Trainee_Name__c IN : mentorTseMap.keySet()]){
                if(mentorTseMap.containsKey(tseObj.Trainee_Name__c) && mentorTseMap.get(tseObj.Trainee_Name__c) == tseObj.Mentor_Name__c){
                    if(tseCaseMap.get(tseObj.Trainee_Name__c) != null){
                        integer i = 1;
                        for(case cse : tseCaseMap.get(tseObj.Trainee_Name__c)){
                            mentors.add(tseObj);
                            Store_Cases_By_Week__c sc = new Store_Cases_By_Week__c();
                            sc.Mentor_TSE_Table__c = tseObj.Id;
                            sc.Name = tseObj.Mentor_Name__r.name +'-'+ tseObj.Trainee_Name__r.name;
                            sc.case__c = cse.Id;
                            sc.Evaluation_Status__c = 'Evaluate';
                            sc.Week_Number__c = weekCounter;
                            if(i < 6){
                                weekList.add(sc);
                                i++;
                            }
                            else{
                                continue;
                            }
                        }
                    }
                }
            }
            if(weekList != null && weekList.Size() > 0){
                insert weekList;
                sendEmailFirstReminderToMentor(mentors);
            }
        }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        
    }
    
    global void finish(Database.BatchableContext BC){
           
    }
     public static void sendEmailFirstReminderToMentor(Set<Mentor_TSE_Table__c> mentorIds){
        List<Messaging.SendEmailResult> mailResult = new List<Messaging.SendEmailResult>();
        EmailTemplate emailTemplate  = [Select id from EmailTemplate where name = 'TSE Quality Created Notification'];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress where displayname='Marketo Customer Support'];
        String ccAddress = label.QA_Mentor_Process_CC_List;
        String[] ccAddresses = ccAddress.split(';');        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
        for(Mentor_TSE_Table__c tmpKey : mentorIds){
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(tmpKey.Mentor_Name__c);
            message.setOrgWideEmailAddressId(owa.id);
            message.setCcAddresses(ccAddresses);
            message.setTemplateId(emailTemplate.Id);
            message.setWhatId(TmpKey.Id);
            message.setSaveAsActivity(false);
            allmsg.add(message);            
        }        
        mailResult = Messaging.sendEmail(allmsg, false);
        List<Messaging.SendEmailError> isEmailFailed = new List<Messaging.SendEmailError>();
        for(Messaging.SendEmailResult singlemEmailResult : mailResult){
            isEmailFailed.addAll(singlemEmailResult.getErrors());
        }
    } 
       global String getWeekCount(){
        Integer Day = Date.Today().day();
        Integer Month = Date.Today().Month();
        String monthWeek = '';
        integer week = 0;
        if(Day >= 1 && Day < 8) week = 1;
        else if(Day >= 8 && Day < 15)  week = 2;
        else if(Day >= 15 && Day < 23) week = 3;
        else if(Day >= 23 && Day < 31)week = 4;
        
        
        if(Month == 1) monthWeek = 'January';
        else if(Month == 2) monthWeek = 'February';
        else if(Month == 3) monthWeek = 'March';
        else if(Month == 4) monthWeek = 'April';
        else if(Month == 5) monthWeek = 'May';
        else if(Month == 6) monthWeek = 'June';
        else if(Month == 7) monthWeek = 'July';
        else if(Month == 8) monthWeek = 'August';
        else if(Month == 9) monthWeek = 'September';
        else if(Month == 10) monthWeek = 'October';
        else if(Month == 11) monthWeek = 'November';
        else if(Month == 12) monthWeek = 'December';
        monthWeek = monthWeek+'-'+week;
        return monthWeek;
    }
}