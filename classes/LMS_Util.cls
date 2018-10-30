/**
MARKETO UNIVERSITY--> LEARNING PASS ENABLEMENT
APEX CLASS DESCRIPTION: THIS IS UTIL CLASS USED FROM MANY PLACES
DATE: JULY 24, 2014
**/
global virtual Class LMS_Util{
    /**VARIABLES STARTED--**/
    public static Boolean isGoingTuRunceOnceMore = false;
    public static String LMSEntRecordTypeId = Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get(System.Label.EntitlementType).getRecordTypeId();
    
    /**ADD USER TO UNIVERSITY PUBLIC GROUP**/
    @future
    public static void addUserToPublicGroup(Set<String> Accountids, String GROUPNAME){
        List<User> usersNeedToAdd = new List<User>([SELECT Id FROM User WHERE AccountId IN : Accountids AND isActive = : True ]);
        if(usersNeedToAdd.isEmpty()) return;        
        String GROUPID = LMS_Util.returnPremiumCatalogGroupId();
        List<GroupMember> groupMemebrlist = groupMemberGenerator(usersNeedToAdd, GROUPID);
        if(!groupMemebrlist.isEmpty()) {
            System.debug('Group Member List is==>'+ groupMemebrlist);
            try{insert groupMemebrlist;}catch(Exception e){sendExceptionMail(e);}
        }
    }
    
    /**SCHEDULER TO REMOVE USERS FROM UNIVERSITY GROUP**/
    @future
    public static void deleteUserFromGroup(set<String> expiredEntitlements){
        DeleteUserWhenEntitlementEndDateReached deleteuserfromGroup = new DeleteUserWhenEntitlementEndDateReached(expiredEntitlements);
        deleteuserfromGroup.execute(null);
    }    
    
    /**ADD AND REMOVE USERS FROM UNIVERSITY GROUP**/
    @future 
    public static void AddAndDeleteUserFromGroup(Set<String> usersTobeAdded,  Set<String> usersTobeDeleted){         
        //ADD USERS
        List<GroupMember> groupMemebrlist = new List<GroupMember>();
        String GROUPID                    = LMS_Util.returnPremiumCatalogGroupId();
        if(!usersTobeAdded.isEmpty()){
            List<User> usersNeedToAdd = new List<User>([SELECT Id FROM User WHERE Id IN : usersTobeAdded AND isActive = : True ]);
            groupMemebrlist = groupMemberGenerator(usersNeedToAdd, GROUPID );
        }        
        //DELETE USERS
        List<GroupMember> groupMemebrlistDeleted = new List<GroupMember>([SELECT Id from GroupMember WHERE GroupId =:GROUPID AND UserOrGroupId IN : usersTobeDeleted]);
        if(!groupMemebrlistDeleted.isEmpty()){
            try{delete groupMemebrlistDeleted;}catch(Exception e){LMS_Util.sendExceptionMail(e);}
        } 
    
        if(!groupMemebrlist.isEmpty()) {
            System.debug('Group Member List is==> ' + groupMemebrlist);
            try{insert groupMemebrlist;}catch(Exception e){LMS_Util.sendExceptionMail(e);}
        }    
    }     
     
    public static List<GroupMember> groupMemberGenerator(List<User> usersTobeAdded, String GROUPID){
         List<GroupMember> groupMemebrlist = new List<GroupMember>();
         for(User usr : usersTobeAdded){
            GroupMember newMember = new GroupMember();
            newMember.GroupId = GROUPID;
            newMember.UserOrGroupId = usr.Id;
            groupMemebrlist.add(newMember); 
        }
        return groupMemebrlist;
    }
    
    public static String  returnPremiumCatalogGroupId(){
        List<Group> premiumGroup          = new List<Group>([SELECT id FROM Group WHERE DeveloperName = : System.Label.PremiumEducationCatalogPublicGroup LIMIT 1]);
        String GROUPID                    = !premiumGroup.isEmpty()?premiumGroup[0].Id:null;
        return GROUPID;
    }
    
    /**METHOD USED TO CHECK WHETHER PRODUCT IS UNIVERSITY PRODUCT OR NOT**/
    public static boolean isPremiumProduct(String productName){
        for(Premium_Education_Catalog_Products__c pr : Premium_Education_Catalog_Products__c.getAll().values()){
            if(productName.contains(pr.ProductId__c)) return true;
            if(pr.Product_Name__c == productName) return true;
        }
        return false;
    }    
    
    /**SEND EXCEPTION DESCRIPTION**/
     public static void sendExceptionMail(Exception e){
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'ayub.a@grazitti.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('MARKETO LMS EXCEPTION:: ' +e);
       mail.setPlainTextBody('MARKETO LMS EXCEPTION IN THE CLASS LMS_UTIL'+e);
       try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(exception ex){}
     }
     
    /**HELPER METHOD TO CREATE ENTITLEMENT WHEN UNIVERSITY OPP IS CLOSED**/   
     public static Entitlement decorateUnivEntitlement(Opportunity op, List<OpportunityLineItem> oli, Entitlement premiumCatalogEnt){
            if(oli.isEmpty()) return new Entitlement ();
            Decimal totalPurchasedCount = 0;
            String products=''; String productIds=''; String oppProductIds='';
            for(OpportunityLineItem ol : oli){
                /*****APPS-11599 - STARTS ******/
                if(ol.Quantity_from_Quote_Line__c != null){
                    totalPurchasedCount = ol.Quantity_from_Quote_Line__c;
                }else{
                    if(ol.Quantity!= null && ol.pricebookentry.product2.Included_Marketing_Users__c != null){
                        totalPurchasedCount += (ol.Quantity*ol.pricebookentry.product2.Included_Marketing_Users__c);
                    }
                }
                /*****APPS-11599 - ENDS - ONLY IF BLOCK WAS ADDED ******/
                products += ol.pricebookentry.product2.Name+';';
                productIds += ol.pricebookentry.product2.id+';';
                oppProductIds += ol.Id+';';
            }
            products.removeEnd(';');productIds.removeEnd(';'); oppProductIds.removeEnd(';');
            if(premiumCatalogEnt == null){
                premiumCatalogEnt                = new Entitlement ();
                premiumCatalogEnt.recordTypeId   = LMSEntRecordTypeId;
                premiumCatalogEnt.name           = op.Account.name+' - '+System.Label.Premium_Education_Catalog;
                premiumCatalogEnt.Type           = System.Label.Entitlement_Type_Label;
                premiumCatalogEnt.accountid      = op.Accountid;
                premiumCatalogEnt.Catalog__c     = System.Label.Premium_Education_Catalog_Id;
                premiumCatalogEnt.StartDate      = op.Sub_Start_Date__c;
            }
            premiumCatalogEnt.Processed_for_grace__c = false;
            premiumCatalogEnt.EndDate        = op.Sub_End_Date__c;
            premiumCatalogEnt.Opportunity__c = op.Id;
            premiumCatalogEnt.Product_ID__c  = productIds;
            premiumCatalogEnt.Products__c    = products;
            premiumCatalogEnt.Quantity__c    = totalPurchasedCount;  
            premiumCatalogEnt.Opportunity_Product__c =   oppProductIds;
                     
            return premiumCatalogEnt;
     }
     
     /**CREATE OR UPDATE ENTITLEMENT WHEN UNIVERSITY OPP IS CLOSED**/
     public static List<Entitlement> createUpdatePremiumEntitlement(Map<string, List<OpportunityLineItem>> universityMap, Map<string, Opportunity> overallOppMap){
        Map<Id,Opportunity> PriorOppWithNewOpp   = new Map<Id,Opportunity>();
        List<Entitlement> lmsEntListToBeInserted = new List<Entitlement>();
        List<Entitlement> lmsEntListToBeUpdated  = new List<Entitlement>();        
        List<Entitlement> allEntitlements = new List<Entitlement>();  
        Map<string,Opportunity> accWithNewOpp   = new Map<string,Opportunity>();
        Boolean isPriorOpptyBlank = false;    
		Boolean generateLearningPassCode = false;		
        String products=''; String productIds='';
        
        for(String oppId : universityMap.keySet()){
            if(overallOppMap.containsKey(oppId)){
                if(overallOppMap.get(oppId).Prior_Opportunity__c != null){                  
                    PriorOppWithNewOpp.put(overallOppMap.get(oppId).Prior_Opportunity__c, overallOppMap.get(oppId));
                }
                accWithNewOpp.put(overallOppMap.get(oppId).AccountId, overallOppMap.get(oppId));
            }
        }
        if(PriorOppWithNewOpp.isEmpty()){isPriorOpptyBlank = true;}// return new List<Entitlement>();        ///ALERT
        system.debug(PriorOppWithNewOpp+'PriorOppWithNewOpp==');
        
        List<Entitlement> lstmasterEntitlement= [SELECT Product_ID__c,Opportunity__r.closedate,EndDate,Opportunity__c, Products__c, Opportunity_Product__c, Quantity__c, AccountId, Processed_for_grace__c, Status FROM Entitlement WHERE AccountId IN: accWithNewOpp.keySet() AND recordTypeId =: LMSEntRecordTypeId order by Opportunity__r.closedate ];
        List<Entitlement> lmsEntList = new List<Entitlement>();
        if(isPriorOpptyBlank == false){
            for(Entitlement ent : lstmasterEntitlement){
                if(ent.Opportunity__c != null && PriorOppWithNewOpp.containsKey(ent.Opportunity__c)){
                    lmsEntList.add(ent);
                }
            }
        }else{
            lmsEntList = lstmasterEntitlement;
            for(OpportunityLineItem ol : universityMap.values()[0]){
                products += ol.pricebookentry.product2.Name+';';
                productIds += ol.pricebookentry.product2.id+';';
            }
        }
        
        if(lstmasterEntitlement.isEmpty()){
            Entitlement entt;
              entt = LMS_Util.decorateUnivEntitlement(overallOppMap.get(new List<String> (universityMap.keyset())[0]),universityMap.values()[0],entt);
            lmsEntListToBeInserted.add(entt);
			generateLearningPassCode = true;
        }           
        
        for(Entitlement ent : lmsEntList){  
            if(!isPriorOpptyBlank){    
                if(ent.Opportunity__c == null) continue;            
                if(ent.Status == 'Expired'){
                     if(PriorOppWithNewOpp.containsKey(ent.Opportunity__c) && PriorOppWithNewOpp.get(ent.Opportunity__c).Sub_Start_Date__c != null && PriorOppWithNewOpp.get(ent.Opportunity__c).Sub_Start_Date__c < ent.EndDate){
                         ent = decorateUnivEntitlement(PriorOppWithNewOpp.get(ent.Opportunity__c), universityMap.get(PriorOppWithNewOpp.get(ent.Opportunity__c).Id), ent);
                         lmsEntListToBeUpdated.add(ent); 
                     }else{
                         Entitlement newLMSEnt;
                         newLMSEnt = LMS_Util.decorateUnivEntitlement(PriorOppWithNewOpp.get(ent.Opportunity__c ), universityMap.get(PriorOppWithNewOpp.get(ent.Opportunity__c).Id), newLMSEnt );
                         newLMSEnt.Previous_Entitlement__c = ent.Id;
                         lmsEntListToBeInserted.add(newLMSEnt);
                     }
                }else{    
                     if(PriorOppWithNewOpp.containsKey(ent.Opportunity__c)){  
                         ent = decorateUnivEntitlement(PriorOppWithNewOpp.get(ent.Opportunity__c), universityMap.get(PriorOppWithNewOpp.get(ent.Opportunity__c).Id), ent);
                         lmsEntListToBeUpdated.add(ent);
                     }
                }
            }else{
					system.debug('********'+productIds);
					system.debug('#########'+ent.Product_ID__c);
					system.debug('%%%%%%%%%%%%%%'+ent.Product_ID__c.contains(productIds));
                if(ent.Product_ID__c.contains(productIds)){
					ent = decorateUnivEntitlement(accWithNewOpp.get(ent.AccountId), universityMap.get(accWithNewOpp.get(ent.AccountId).Id), ent);
					lmsEntListToBeUpdated.add(ent);
					break;
                }
            }
        }
       
        try{            
            if(!lmsEntListToBeInserted.isEmpty()){
                 insert lmsEntListToBeInserted;
				 if(generateLearningPassCode){
					 generateUniqueCode(lmsEntListToBeInserted);
				 }else{
					 Map<Id, Entitlement> learningPassEntitlementsToBeTransfer = new Map<Id, Entitlement>();
					 for(Entitlement ent : lmsEntListToBeInserted){
						 if(ent.Previous_Entitlement__c != null)
							 learningPassEntitlementsToBeTransfer.put(ent.Previous_Entitlement__c, ent);
					 }                 
					 boolean isLearningPassCreated = updateUniqueCode(learningPassEntitlementsToBeTransfer, false);       
                 }/**MAY 19- CODE IS COMMENTED BECAUSE LMS IS MOVING TO MERIDIAN FROM CYBERU**/          
                 //if(isLearningPassCreated) LMS_Util.sendPassportCodeToPrimaryUserAfter24Hr(learningPassEntitlementsToBeTransfer.values(), System.Label.University_LearningPassCodes_EmailTemplate_For_NewBusiness);
            }
            
            return lmsEntListToBeUpdated;//return enitltments only that need to be update, to avoid multiple DML, update it on the parent routine.
            
        }catch(Exception e){sendExceptionMail(e);} 
        return new List<Entitlement>();       
     }
     
     /**GENERATE UNIQUE LEARNING APSS CODE PER ACCOUNT**/ 
     public static boolean updateUniqueCode(Map<Id, Entitlement> transferEntitlementShip, boolean invokedFromTrigger){
         List<Learning_Passport__c> learningPassports = new List<Learning_Passport__c>([SELECT Id, Entitlement__c, Opportunity__c, Unique__c FROM Learning_Passport__c WHERE Entitlement__c IN: transferEntitlementShip.keySet()]);
         for(Learning_Passport__c learningPassport : learningPassports ){
             if(transferEntitlementShip.containsKey(learningPassport.Entitlement__c)){
                 Entitlement new_ent =  transferEntitlementShip.get(learningPassport.Entitlement__c);
                 if(invokedFromTrigger){
                     if(new_ent.Status == 'Expired'){
                         learningPassport.IsArchived__c = true;
                     }else{
                         learningPassport.IsArchived__c = false;
                     }
                 }else{ 
                     learningPassport.IsArchived__c = false;
                 }
                 
                 learningPassport.Entitlement__c = new_ent.Id;
                 learningPassport.Opportunity__c = new_ent.Opportunity__c;      
                 learningPassport.Opportunity_Product__c = new_ent.Opportunity_Product__c;
               }
         }        
        
        upsert learningPassports Unique__c;
        return true;
         
    } 
    
    
     /**GENERATE UNIQUE LEARNING APSS CODE PER ACCOUNT**/ 
     public static boolean generateUniqueCode(List<Entitlement> universityEntitlements){
         integer sixDigitCons = 100000;
         List<Learning_Passport__c> learningPassports = new List<Learning_Passport__c>();
         Set<Id> qualifiedEnts = new Set<Id>();
         for(Entitlement univ_ent : universityEntitlements){
             Set<Integer> uniquecodes = new Set<Integer>();
             integer i= 1;
             for(Decimal limitation = 0; limitation < univ_ent.Quantity__c; limitation++){
                 integer uniqueCode = sixDigitCons+(math.ceil(math.random()*100)*10).intValue()+i;
                 if(uniquecodes.contains(uniqueCode)){
                     uniqueCode = uniqueCode+(math.ceil(math.random()*100)*100).intValue()+i;
                 }
                 uniquecodes.add(uniqueCode);                 
                 Learning_Passport__c learningPass   = new Learning_Passport__c();
                 learningPass.Account__c             = univ_ent.AccountId;
                 learningPass.Opportunity__c         = univ_ent.Opportunity__c;
                 learningPass.Code__c                = string.valueOf(uniqueCode);
                 learningPass.Unique__c              = learningPass.Code__c+'-'+univ_ent.Opportunity_Product__c+'-'+learningPass.Account__c;
                 learningPass.Passport_Serial_No__c  = i;
                 learningPass.Opportunity_Product__c = univ_ent.Opportunity_Product__c;
                 learningPass.Entitlement__c         = univ_ent.Id;
                 learningPassports.add(learningPass);
                 i++;
              }
              if(univ_ent.StartDate <= Date.Today()){
                qualifiedEnts.add(univ_ent.Id);
              }              
          }
        
         try{ 
             if(!learningPassports.isEmpty()){
                 upsert learningPassports Unique__c;
                 if(!qualifiedEnts.isEmpty()){
                    updatePrimaryMarketoHiddenEmail(QualifiedEnts);
                    return true;
                 }
                 else{
                     return true;
                 }                
                 
             }else{
                 return true;
             }
         }catch(Exception e){
             return false;
         }
    }   
    
    /**SEND EMAIL IF TODAY ENTITLEMENT BEING ACTIVE**/
    public static void updatePrimaryMarketoHiddenEmail (Set<ID> EntiIds){
/*        List<Entitlement> UpdateEmailHidden = new List<Entitlement>();
        for(Entitlement ent: [Select Id, Primary_Marketo_User_Email_Hidden__c, Opportunity__r.Primary_Marketo_User_Lookup__r.Email FROM Entitlement Where ID IN: EntiIds]){
            ent.Primary_Marketo_User_Email_Hidden__c = ent.Opportunity__r.Primary_Marketo_User_Lookup__r.Email;
            UpdateEmailHidden.add(ent);
        }
        if(!UpdateEmailHidden.isEmpty()){
            update UpdateEmailHidden;
        }
*/    }
    
    
     
    /**SEND LEARNING PASS CODE TO PRIMARY USER**/ 
    public static void sendPassportCodeToPrimaryUserAfter24Hr(List<Entitlement> univ_ents, string EMAILTEMPLATENAME) {
        /***
         MAY 19- CODE IS COMMENTED BECAUSE LMS IS MOVING TO MERIDIAN FROM CYBERU
       **/
       /***
        //List<SMB_SheduledJobInfo__c> scheduledJobs = new List<SMB_SheduledJobInfo__c>();
        for(Entitlement univ_ent: univ_ents){
            if(univ_ent.Opportunity__c != null){
                SendLearningPassCodeToPrimUserAfter24Hr sheduleMail = new SendLearningPassCodeToPrimUserAfter24Hr(EMAILTEMPLATENAME); 
                Datetime timeToSendMail = System.now();
                timeToSendMail = timeToSendMail.addHours(24);
                //timeToSendMail = timeToSendMail.addseconds(60);
                String sch = '' + timeToSendMail.second() + ' ' + timeToSendMail.minute() + ' ' + timeToSendMail.hour() + ' ' + timeToSendMail.day() + ' ' + timeToSendMail.month() + ' ? ' + timeToSendMail.year();
                String scheduledJobId = System.schedule('SendPassportCodeToPrimaryUserAfter24Hr-'+timeToSendMail, sch, sheduleMail);
                //SMB_SheduledJobInfo__c scheduleProjectRec = new SMB_SheduledJobInfo__c();
                scheduleProjectRec.ProjectId__c     = univ_ent.Id;
                scheduleProjectRec.SheduledJobId__c = scheduledJobId;
                scheduledJobs.add(scheduleProjectRec);
            }
        }
        insert scheduledJobs;
        */
    }
    /**THIS CODE IS EXECUTED FROM BUTTON- 'RESEND LEARNING PASSPORT CODE' ON ENTITLEMENT**/
    
    
    public static List<Entitlement> sendLearningPassCodesToPrimUser(Set<Id> universityEntsIDs){  
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Entitlement> universityEnts  = new List<Entitlement>([SELECT Opportunity__c, Opportunity__r.Primary_Marketo_User_Lookup__c FROM Entitlement WHERE Id =: universityEntsIDs]);
        OrgWideEmailAddress owa     = [SELECT id, DisplayName , Address FROM OrgWideEmailAddress WHERE DisplayName =:'Marketo Education'];
        Map<String, Id> primContactWithOpp = new Map<String, Id>();
        for(Entitlement enty : universityEnts){
            primContactWithOpp.put(enty.Id, enty.Opportunity__r.Primary_Marketo_User_Lookup__c);
        }
        EmailTemplate mailTemplate  = [SELECT id,HtmlValue FROM EmailTemplate WHERE DeveloperName=:System.Label.University_LearningPassCodes_EmailTemplate_For_Entitlements];
        
        for(Entitlement enty :universityEnts){
            if(primContactWithOpp.containsKey(enty.Id)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(primContactWithOpp.get(enty.Id));
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setCcAddresses(system.label.MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS.split('#'));
                mail.setTemplateID(mailTemplate.Id); 
                mail.setWhatId(enty.ID);
                mail.setSaveAsActivity(false);
                mailList.add(mail);
                enty.Is_University_Codes_Sent__c = true;
                system.debug('mail--->'+mail);
            }
        }  
        if(!mailList.isEmpty()) { 
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mailList);
        }
        return universityEnts;       
    }
    
    WebService static integer sendLearningPassCodesInMail(String oppId, String entId){ 
        List<Entitlement> univ_ents = sendLearningPassCodesToPrimUser(new Set<Id> {entId});
        if(!univ_ents.isEmpty()) try{update univ_ents;}catch(Exception e){}
        return 1;
    }  
    
    /**DELETE SCHEDULER THAT SEND LEARNING PASS CODE TO PRIMARY USER**/ 
    public static void deleteSheduledOpp(Set<string> OpportunityIds){
        //List<SMB_SheduledJobInfo__c > sheduleProjToDelete = [select name from SMB_SheduledJobInfo__c where ProjectId__c in :OpportunityIds];
        /*if(sheduleProjToDelete.size()!= null && sheduleProjToDelete.size()>0){
            try{delete sheduleProjToDelete;}catch(Exception e){}
        }*/
    }

}