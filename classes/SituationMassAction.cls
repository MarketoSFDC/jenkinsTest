/****************************************************
Class Name: SituationMassAction
Author: Grazitti
Created Date: 11/12/2012
Usage: This class is used for mass change owner and close reason.
*****************************************************/
public class SituationMassAction{ 
    public Case caseRecord {get;set;}
    public List<Id> recIdList{get; set;}    
    public List<String> caseNumberList{get;set;}
    public String massCloseReason {get;set;}
    public Boolean sendNotification{get;set;}
    public List<Case> myCloseList {get;set;}
    public String retURL {get;set;}   
    //query record type add in wrapper list - constructor
    public SituationMassAction() {   
        caseRecord =  new Case();    
        String strRecs = '';sendNotification = false;
        recIdList  = new List<Id>();        
        if(ApexPages.currentPage().getParameters().get('ids') != null)
            strRecs = ApexPages.currentPage().getParameters().get('ids');                          
        if(strRecs.trim() != ''){                        
            recIdList = strRecs.split(',');                            
            getCaseNumbers();            
        }
        retURL = '';
        if(ApexPages.currentPage().getParameters().get('retURL') != null)
            retURL = ApexPages.currentPage().getParameters().get('retURL');        
    }       
    public void getCaseNumbers()
    {
        myCloseList  = new List<Case>();caseNumberList = new List<String>();
        try {
            myCloseList = [select Id,OwnerId,CaseNumber from Case where ID IN :recIdList];
            for(case c : myCloseList){ caseNumberList.add(c.CaseNumber); }
        }
        catch (Exception ex){}                     
    }  
    /*    
    public List<SelectOption> getUserTypes() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('','Select Close Reason'));
        options.add(new SelectOption('User','User'));
        options.add(new SelectOption('Queue','Queue'));
        options.add(new SelectOption('Customer Portal User','Customer Portal User'));
        return options;
    } */           
    // close cases and return to list
    public PageReference doChangeOwner() {  
        try 
        {        
            for(case c : myCloseList) {
                c.OwnerId = caseRecord.OwnerId;                          
            }
            update myCloseList;
            if(sendNotification == true){
                sendEmailNotification(caseRecord.OwnerId,recIdList);
            }
        } catch(DMLException ex) {
            ApexPages.addMessages(ex);                    
            return null;
        } catch(Exception ex) {
            ApexPages.addMessages(ex);            
            return null;
        }        
        PageReference pgRef  = new PageReference('/apex/SituationList'); 
        if(retURL !='') pgRef  = new PageReference(retURL);                                        
        pgRef.setRedirect(true);               
        return pgRef;
    }    
    public List<SelectOption> getCloseReason() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Spam','Spam'));
        options.add(new SelectOption('Duplicate','Duplicate'));
        options.add(new SelectOption('Invalid Record','Invalid Record'));
        return options;
    }        
    // close cases and return to list
    public PageReference doCloseCase() {          
        try 
        {            
            System.debug('massCloseReason=>' + massCloseReason);            
            myCloseList  = [select Id,Close_Reason__c,Status from Case where ID IN :recIdList];
            for(case c : myCloseList )
            {
                c.Close_Reason__c = massCloseReason;
                c.Status = 'Closed';            
            }
            update myCloseList;
        }
        catch(Exception ex)
        {             
        } 
        PageReference pgRef  = new PageReference('/apex/SituationList');
        if(retURL !='') pgRef  = new PageReference(retURL);
        pgRef.setRedirect(true);               
        return pgRef;
    }        
    public PageReference doCancel() {   
        PageReference pgRef = new PageReference('/apex/SituationList');
        if(retURL !='') pgRef  = new PageReference(retURL);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    @future (callout=true)
    public static void sendEmailNotification(String ownerId, List<Id> recs)
    {
        User myUser = [SELECT Id,Email from User Where Id =: OwnerId Limit 1];        
        List<Case> myCloseList = [select Id,OwnerId,CaseNumber from Case where ID IN :recs];               
        List<String> str = new String[]{myUser.Email};
        string [] toaddress=str;
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();      
        for(Case c : myCloseList)
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String msgbody = '' ;
            msgbody += 'Case ' + c.caseNumber + ' has been assigned to you. Please click on the link below to view the record.';
            msgbody += URL.getSalesforceBaseUrl().toExternalForm() + '/' + c.Id;            
            email.setSubject('Change SM Owner');
            email.setHtmlBody(msgbody);
            email.setToAddresses(toaddress);
            email.setSaveAsActivity(false);            
            lstMails.add(email);
        }        
        Messaging.sendEmail(lstMails);
    }
    
    @isTest
    public static void testSMMassAction()
    {    
        test.startTest();
        Case caseObj = new Case(Status = 'New', Priority = 'P3', Subject = 'Test', Description = 'Test Description2', OwnerId = UserInfo.getUserId());
        insert caseObj;                  
        caseObj = new Case(Status = 'New', Priority = 'P3', Subject = 'Test2', Description = 'Test Description2', OwnerId = UserInfo.getUserId());
        insert caseObj;                  
        caseObj = new Case(Status = 'New', Priority = 'P3', Subject = 'Test3', Description = 'Test Description3', OwnerId = UserInfo.getUserId());
        insert caseObj;                           
        List<Case> testCaseLst = new List<Case>();
        testCaseLst = [select Id,OwnerId,CaseNumber from Case Limit 10];        
        String recStr = '';
        for (case c : testCaseLst){
            recStr += c.id + ',';
        }
        integer indx = recStr.lastindexof(',');
        if(indx > 0) recStr = recStr.substring(0,indx);               
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseObj);   
        ApexPages.currentPage().getParameters().put('ids',recStr);     
        ApexPages.currentPage().getParameters().put('id',caseObj.Id);     
        ApexPages.currentPage().getParameters().put('retURL','/apex/SituationList');
        SituationMassAction situationCtrl = new SituationMassAction();          
        situationCtrl.caseRecord = caseObj;
        situationCtrl.sendNotification = true;        
        situationCtrl.getCloseReason();
        situationCtrl.getCaseNumbers();
        situationCtrl.doChangeOwner();
        situationCtrl.doCloseCase();
        situationCtrl.doCancel();
        test.stopTest();    
    }       
}