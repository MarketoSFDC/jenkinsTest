/****************************************************
Class Name: SituationMgmtController
Author: ClearTeask
Created Date: 11/09/2012
Usage: This class is used for showing case list view, pagination, case create, status change.
*****************************************************/
public with sharing class SituationMgmtController {
    public boolean CustomerDoesNotWantToBeContacted {get;set;}
    String query = 'Select id, CaseNumber,parent,Situation_Account__c ,Status,Close_Reason__c, Priority, Subject,SM_Account_Temperature__c from Case ';  
    public Case caseRecord {get;set;}
    Public String accID{get;set;}
    public String filterBy {get; set;}
    public String strField {get;set;}
    public String charLink {get;set;}
    public String fileName {get; set;}    
    public String caseComment {get; set;}    
    public String selectedStatus {get; set;}   
    public Integer fileSize {get; set;}     
    public List<SelectOption> viewOptions {get; set;}
    public List<CaseComment> caseCommentList {get; set;}   
    public List<EmailMessage> caseEmailList {get; set;}//Bikram
    public Boolean errorFlag{get;set;}        
    String queryCondition;
    String queryConditionOrder;
    String strKeyword;
    String sortFullExp;    
    private String sortExp = 'CaseNumber';
    private String sortDirection = 'ASC';
    public Transient List<Case> caseList;    
    public Boolean showOwner {get; set;}
    public Boolean isCreateable {get; set;}
    public Boolean isUpdateable {get; set;}
    public Boolean isDeletable {get; set;}
    public Boolean isPublicCmnt {get; set;}
    public Boolean isEdit {get; set;}
    Public List<SelectOption> SelectOptionList= new List<SelectOption>();
    Public String type = ApexPages.currentPage().getParameters().get('type');                  
    public string myCloseCases {get;set;}
    public string myDeleteCases {get;set;}    
    public boolean closeReasonRequiredFlag{get;set;}    
    public Map<String,String> emailToContactMap = new Map<String,String>();    
    public Map<String,String> emailToContactsMap = new Map<String,String>();
    public Map<String,String> eMsgToAddressMap = new Map<String,String>();
    public Boolean isOwnerQueue {get;set;}
    public Boolean isOriginTbd {get;set;}
    //public set<String> profHavingfullAccessToSm  = new set<String>();
    //public Map<Id,String> profileIdToName = new Map<Id,String>();
    
    //public Map<Id,Id> recordTypeToQueueMap = new Map<Id,Id>();
    
    public SituationMgmtController() {        
        emailToContactMap = new Map<String,String>();        
        emailToContactsMap = new Map<String,String>();                
    }
    
    //4001
    public void fillRecordTypetoQueueMap() {    
        List<group> myQueueItems = [select id, name from group where name like 'S%Queue'];     
    }
     
    public Boolean getProblemTypeVisibility() {    
        if(filterBy != null) {        
            //If All Open Support, return true immediately
            if(filterBy == 'All Open Support') { 
                return true;                        
            } else if(filterBy == 'My Open Issues') {
                try {            
                    SupportAdminProfiles__c SMProblemTypeProfileVisibility = SupportAdminProfiles__c.getValues('SMProblemTypeProfileVisibility');
                    if(SMProblemTypeProfileVisibility.ProfileIds__c.containsIgnoreCase(UserInfo.getProfileId())) {
                        return true;
                    }
                } catch(Exception ex) { System.debug(''+ex); }        
            }
        }
        return false;        
    }
            
    public Boolean getIsValidProfile(){
        SupportAdminProfiles__c SM_Allow_Cru = SupportAdminProfiles__c.getValues('SM_Allow_Cru');
        if(SM_Allow_Cru !=null && SM_Allow_Cru.ProfileIds__c.containsIgnoreCase(UserInfo.getProfileId()))
            return true;
        return false;               
    }
    public Boolean getIsValidProfileCRUD(){
        SupportAdminProfiles__c SM_Allow_Crud = SupportAdminProfiles__c.getValues('SM_Allow_Crud');
        if(SM_Allow_Crud !=null && SM_Allow_Crud.ProfileIds__c.containsIgnoreCase(UserInfo.getProfileId()) && isDeletable)
            return true;
        return false;        
    }   
    public PageReference changeFlag(){
        String selectedCloseReason =  ApexPages.currentPage().getParameters().get('selectedCloseReason');
        Set<String> freeCloseReasons = new Set<String>{'Duplicate','Spam','Invalid Record','Not Services Related'};
        System.Debug('CLOSE REASON'+selectedCloseReason);
        if (freeCloseReasons.contains(selectedCloseReason)){
            closeReasonRequiredFlag = false;
        } else {
            closeReasonRequiredFlag = true;
        }
        //caseRecord.Sub_Category__c = null;
        return null;
    } 
    /* Pagination Controls Start here */ 
     
    /* --setCon as ApexPages.StandardSetController --*/
    public ApexPages.StandardSetController setCon {
        get {            
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select id , CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name, SM_Account_Temperature__c from Case where Ownerid = :UserInfo.getUserId() ])); //where Owner__c = :userName                 
            }
            setCon.setPageSize(25);
            return setCon;
        }
        set;
    }    
    
    /*--returns the sort expression --*/
    public String sortExpression {
        get{   
            system.debug('=====sortExp==='+sortExp);          
            return sortExp;                       
        }
        set{
            /* if the column is clicked on then switch between Ascending and Descending modes */
            if (value == sortExp)
              sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';               
            sortExp = value;
        }
    }    
     
    public pagereference checkValidation() {   
        String ownerOfCase = CaseRecord.Owner.Name;
        if(CaseRecord.origin !='TBD' && ownerOfCase != Null && ownerOfCase.contains('Queue')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Public comments and emails cannot be sent from SM records that are owned by a queue. Please correct this field and try again.'));
        }
        if(CaseRecord.origin =='TBD' && ownerOfCase != Null && !ownerOfCase.contains('Queue')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Public comments and emails cannot be sent from SM records that have an origin of TBD. Please correct this field and try again.'));
        }
        if(CaseRecord.origin =='TBD' && ownerOfCase != Null && ownerOfCase.contains('Queue')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Public comments and emails cannot be sent from SM records that are owned by a queue or have an origin of TBD. Please correct these fields and try again.'));
        }
        return null;
    }
        
    /* --indicates whether there are more records after the current page set-- */
    public Boolean hasNext {
        get{
            return setCon.getHasNext();
        }
        set;
    }
  
    /* --indicates whether there are more records before the current page set-- */
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    /* --returns the final record number of the set-- */
    public Integer recordTo {
        get {
            if(setCon.getPageNumber()* setCon.getPageSize() > setCon.getResultSize()){
                return setCon.getResultSize();
            }
            return setCon.getPageNumber()* setCon.getPageSize();
        }
        set;
    }
    
    /* --returns the initial record number of the set-- */
    public Integer recordFrom {
        get {
            if(setCon.getPageNumber()* setCon.getPageSize() > setCon.getResultSize()){
                return ((setCon.getPageNumber()-1)* setCon.getPageSize()) + 1;
            }
            return (recordTo - setCon.getPageSize()) + 1; 
        }
        set;
    }
    
    /* --returns the page number of the current page set-- */
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    /* --returns the total page numbers of the set-- */
    public Integer pageNumberTotal {
        get {
            Integer modResult = Math.mod(setCon.getresultSize(), setCon.getPageSize());            
            if(modResult > 0)
            return Math.abs(setCon.getresultSize()/setCon.getPageSize()) + 1;
            else
            return Math.abs(setCon.getresultSize()/setCon.getPageSize());            
        }
        set;
    }
    
    /* --returns the first page of records-- */
    public void first() {
        setCon.first();
    }
  
    /* --returns the last page of records-- */
    public void last() {
        setCon.last();
    }
  
    /* --returns the previous page of records-- */
    public void previous() {
        setCon.previous();
    }
  
    /* --returns the next page of records-- */
    public void next() {
        setCon.next();
    }
    
    /* --method to be show sort direction image-- */
    public String getSortDirection() {
        /* if column is not selected */
         system.debug('=====sortExpression ==='+sortExpression ); 
        if (sortExpression == null || sortExpression == '')
            return 'DESC';
        else
            return sortDirection;
    }
    
    /*-- method to be set sort direction image-- */
    public void setSortDirection(String value) {  
        sortDirection = value;
    }
    
    Id recTypeId;
    
    Boolean isClosedTrue = true;
    Boolean isClosedFalse = false;
    String CLOSED = 'Closed';
    
    // constructor
    public SituationMgmtController(ApexPages.StandardController controller) {            
            
        emailToContactMap = new Map<String,String>();
        emailToContactsMap = new Map<String,String>();
        List<String> fields = new List<String>();        
        if(!test.isRunningTest()){
            fields.add('Request_Type__c');
            fields.add('First_Contact_Date__c');    
            controller.addFields(fields);    
        }
        caseRecord = (Case) controller.getRecord();
        list<case> parentCase = new list<case>([Select id,parentID from case where Id = :caseRecord.id]); 
        if(parentCase.IsEmpty()==False){
            for( CSatSurveyFeedback__c CSAT : [select id, Contact_Support_Manager__c from CSatSurveyFeedback__c where Case__c = :parentCase[0].ParentId and Case__c!=null  limit 1]){
                if(CSAT.Contact_Support_Manager__c == 'No'){
                    CustomerDoesNotWantToBeContacted = true;
                }
            }
        }
        caseCommentList = new List<CaseComment>();
        checkPermissions();
        recTypeId = recTypeAssignment(type);                                
        caseRecord.RecordTypeId = recTypeId;
        //caseRecord.OwnerId = UserInfo.getUserId();
        String page = ApexPages.currentPage().getParameters().get('page');
        if(page != null && page.equals('new_account')) {
            String accid = ApexPages.currentPage().getParameters().get('accid');
            caseRecord.Situation_Account__c = accid;
        }
        if(page != null && page.equals('new_contact')) {
            String conid = ApexPages.currentPage().getParameters().get('conid');
            caseRecord.Situation_Contact__c = conid;
        }
        if(page != null && page.equals('edit')) {
            isEdit = true;
            caseRecord = SituationUtil.queryCase(caseRecord.id);
            //selectedStatus = caseRecord.Status;
        }
        if(page != null && page.equals('close')) {
            caseRecord = SituationUtil.queryCase(caseRecord.id);            
            //selectedStatus = caseRecord.Status;            
        }       
        if(page != null && page.equals('clone')) 
            doClone();        
        
        String filtrby = ApexPages.currentPage().getParameters().get('filterBy');
        if(filtrby  == null ||  filtrby.trim().length()==0)
            filterBy = 'My Open Issues';
        else 
            filterBy = filtrby;                
        viewOptions = new List<SelectOption>();
        listOptions();
        search();
        String commentId = ApexPages.currentPage().getParameters().get('cmnt');
        queryComments(commentId);            
        
        String selectedCloseReason =  caseRecord.Close_Reason__c;
        Set<String> freeCloseReasons = new Set<String>{'Duplicate','Spam','Invalid Record','Not Services Related'};
        System.Debug('CLOSE REASON'+selectedCloseReason);
        if (freeCloseReasons.contains(selectedCloseReason)){
            closeReasonRequiredFlag = false;
        } else {
            closeReasonRequiredFlag = true;
        }                    
    }        

   
    public  void ContactProperty(){               
        SelectOptionList.clear();
        Contact associatedContact = new Contact();
        if(CaseRecord.Situation_Contact__c != null) associatedContact = [Select Id, AccountId from Contact where Id = :CaseRecord.Situation_Contact__c limit 1];
        List<Account> AccoList = [Select Id, Name from Account where Id=:associatedContact.AccountId limit 1];
        for(Account AccObj : AccoList){ 
            SelectOptionList.add(new SelectOption(AccObj.Id,AccObj.Name));                
        }  
        CaseRecord.Situation_Account__c = associatedContact.AccountId;
    }
    public List<SelectOption> getaccounts(){  
        system.debug(SelectOptionList);      
        return SelectOptionList;             
    }    
    
    public Id recTypeAssignment(String type) {
        String recTypeName = '';        
        if(type != null && type.equals('serv'))
            recTypeName = 'Situation Management - Services';
        if(type != null && type.equals('supp'))
            recTypeName = 'Situation Management - Support';
        if(type != null && type.equals('feed'))            
            recTypeName = 'Situation Management - MarketoCares';   
        /*if(type != null && type.equals('EscMan'))            
            recTypeName = 'Situation Management - Escalation Manager';*/
        List<RecordType> recTypeList = [select id, Name from RecordType where sObjectType = 'Case' and Name = :recTypeName];    
        if(recTypeList != null && recTypeList.size() > 0) {
            recTypeId = recTypeList[0].id;
        }
        return recTypeId;
    }
    
    public void checkPermissions() {       
        isCreateable = SituationUtil.caseIsCreateable();
        isUpdateable = SituationUtil.caseIsUpdateable();
        isDeletable = SituationUtil.caseIsDeletable();
     }
    
    public void queryComments(String commentId) {
        String cmntId = commentId;
        String parentId = caseRecord.id;
        String queryCmnt = 'select CommentBody, CreatedDate, CreatedById, isPublished from CaseComment where ParentId = :parentId ';
        
        if(commentId != null)
            queryCmnt += ' and id = :cmntId ';
        queryCmnt += ' order by CreatedDate DESC ';
        
        caseCommentList = Database.query(queryCmnt);
        if(commentId != null && caseCommentList != null && caseCommentList.size() > 0) {
            caseComment = caseCommentList[0].CommentBody;
            isPublicCmnt = caseCommentList[0].isPublished;
        }
    }
    
    //steffi updated on 5 Nov
    public List<EmailMessage> getEmailList()
    {
        String caseId = ApexPages.currentPage().getParameters().get('ID');
        String parentId = caseId;
        String queryCmnt = 'select Id, status,EmailMessage.Subject, CreatedDate, CreatedById, FromAddress, ToAddress, MessageDate, CcAddress, BccAddress from EmailMessage where ParentId = :parentId ';  
        queryCmnt += ' order by MessageDate DESC ';        
        caseEmailList = Database.query(queryCmnt);  
        if(caseEmailList.size()>0) {         
            getReplyAllListings();
        }
        //System.Debug('<===caseEmailList==>' +caseId + caseEmailList);        
        return caseEmailList ;     
    }
    
    public Map<String,String> getEmailToContactMap()
    {
        return emailToContactMap;
    }
    public Map<String,String> getEmailToContactsMap()
    {
        return emailToContactsMap;
    }
    public Map<String,String> getEMsgToAddressMap()
    {
        return eMsgToAddressMap;
    }
    
    /* Fill Reply All Contacts Map */
    public void getReplyAllListings()
    {                
        List<String> suppEmailList = new List<String>();
        List<String> caseCcLst = new List<String>();
        
        //List of exempted email ids
        suppEmailList.AddAll(SupportAdminProfiles__c.getValues('SupportEmailsForReplyAllExmpt').ProfileIds__c.split(';'));
        //System.debug('suppEmailList==>'+suppEmailList);
        //suppEmailList.AddAll('support@marketo.com;supportfeedback@marketo.com;supportescalations@marketo.com;services@marketo.com'.split(';'));
        
        String caseEmailLst = caseRecord.Email_List__c;
        if(caseEmailLst != null && caseEmailLst.trim() != '') {                
            caseCcLst = getEmailAddressList(caseEmailLst);                                                                                 
        }
               
        Set<String> myemIdsForCntct = new Set<String>();
        
        for(EmailMessage e : caseEmailList) {
        
            String toAddressStr = '';              
            //Workaround fix for 4826         
            if(e.ToAddress != null && (!(e.ToAddress.trim()==''))) {                         
            //Find the correct ToAddress
                if(e.ToAddress.contains(';')) { // If multiple email Ids                        
                    List<String> tmpToAddressLst = new List<String>();
                    Set<String> tmpToAddressSet =  new Set<String>();                
                    tmpToAddressLst = e.ToAddress.split(';'); // semi-colon seprated address str to list               
                    tmpToAddressSet.AddAll(tmpToAddressLst);  //list of emails in ToAddress to set
                    tmpToAddressSet.removeAll(suppEmailList); //remove all supp emails from set of to address email ids    
                    if(tmpToAddressSet.size() == 0) {  //If no non-supp email Ids in list              
                        toAddressStr = e.ToAddress.split(';')[0];
                    } else {                                       
                        tmpToAddressLst.clear();
                        tmpToAddressLst.AddAll(tmpToAddressSet);    
                        toAddressStr = tmpToAddressLst[0];//.get(0);                
                    }            
                } else {  // single email Id 
                    toAddressStr = e.ToAddress.Trim();
                }
            }                       
            
            emailToContactsMap.put(e.Id,'');
            eMsgToAddressMap.put(e.Id,toAddressStr);           
            if(toAddressStr != '') {
                emailToContactMap.put(toAddressStr,'');                
                myemIdsForCntct.Add(toAddressStr);            
            }
            
            List<String> myEmailList = new List<String>();
            List<String> myEmailToList = new List<String>();            

            if(e.ToAddress != null && (!(e.ToAddress.trim()==''))) {             
                myEmailToList.AddAll(getEmailAddressList(e.ToAddress));            
            }
            //myEmailList.AddAll(getEmailAddressList(e.FromAddress));            
            if(e.CcAddress != null && (!(e.CcAddress.trim()==''))){
                myEmailList.AddAll(getEmailAddressList(e.CcAddress));
            }
            if(e.BccAddress != null && (!(e.BccAddress.trim() == '')))
                myEmailList.AddAll(getEmailAddressList(e.BccAddress));                                    
            
            if(!caseCcLst.isEmpty())
                myEmailList.AddAll(caseCcLst);                
            
            List<String> myEmlIdList = new List<String>();
            Set<String> myEmlIdSet = new Set<String>();     
            myEmlIdSet.AddAll(myEmailList);                                          
            
            //if(!caseCcLst.isEmpty()) myEmlIdSet.removeAll(caseCcLst);                        
            myEmlIdSet.removeAll(suppEmailList);
            myEmlIdSet.removeAll(myEmailToList);
            myEmlIdSet.remove(e.FromAddress);                      
            
            myEmlIdList.AddAll(myEmlIdSet);
                        
            if(!myEmlIdList.isEmpty())
                emailToContactsMap.put(e.Id,String.join(myEmlIdList,';')+';');                   
            
            myEmlIdSet.clear();
        }
        
        List<Contact> emailContacts  = new List<Contact>();
        try {
            myemIdsForCntct.removeAll(suppEmailList);
            emailContacts = [SELECT ID,Email from Contact Where Email IN :myemIdsForCntct];
            for(contact e : emailContacts) {
                emailToContactMap.put(e.Email,e.Id);                                     
            }                
        } 
        catch(Exception ex){       }                            
    
        //System.debug('emailToContactMap==>' + emailToContactMap);
        //System.debug('emailToContactsMap==>' + emailToContactsMap);        
    }
    
    
    
    /* search cases for list view */
    public void search(){
        filterQuery();
        getCaseList();                     
    }
    
    /* add filter to query */
    public void filterQuery(){
        
        String query;
        if(filterBy ==  null){
            //return query;
        }else{            
            if(filterBy.equals('My Open Issues')){
                showOwner = false;
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c, Problem_Type__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and RecordType.Name like \'%Situation Management%\' and ownerid=\''+UserInfo.getUserId()+'\'';
               
                
            }else if(filterBy.equals('All Open Support')){
                recTypeId = recTypeAssignment('supp');
                showOwner = true;
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name, SM_Account_Temperature__c, Problem_Type__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and RecordTypeId = :recTypeId ';
           
            }else if(filterBy.equals('All Open Services')){
                recTypeId = recTypeAssignment('serv');
                showOwner = true;
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and RecordTypeId = :recTypeId ';           
                
           }else if(filterBy.equals('All Open Feedback')){
                recTypeId = recTypeAssignment('feed');
                showOwner = true;
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and RecordTypeId = :recTypeId ';         
                
           /*}else if(filterBy.equals('All Open Escalate Manager')){
                recTypeId = recTypeAssignment('EscMan');
                showOwner = true;
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and RecordTypeId = :recTypeId ';*/  
                
           }else if(filterBy.equals('Queue (Support)')){
                showOwner = true;
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and (Owner.Name=\'MarketoCares Queue\' OR Owner.Name=\'Support Escalations Queue\')';
           }
           //steffi added 11 jan
           else if(filterBy.equals('Queue (Services)')){
                showOwner = true;   
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and (Owner.Name=\'Services Queue\')';            
           }
           else if(filterBy.equals('Queue (Feedback)')){
                showOwner = true;   
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and (Owner.Name=\'MarketoCares Queue\')';            
           }
           else if(filterBy.equals('Queue (Escalate Manager)')){
                showOwner = true;   
                query = 'select id, CaseNumber, Status, Priority, Subject, Situation_Account__r.Name, Situation_Contact__r.Name, CreatedDate, LastModifiedDate, Owner.Name, RecordType.Name,SM_Account_Temperature__c from Case where ';
                query = query + ' isClosed = : isClosedFalse and Status != :CLOSED ';  
                query = query + ' and (Owner.Name=\'Support Escalations Queue\')';            
           }
        }
        this.query = query;        
        sortFullExp = sortExpression  + ' ' + sortDirection;
        queryConditionOrder = query + ' order by ' + sortFullExp;               
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryConditionOrder ));                
        //return query;
    }
    
    /*--method which is called for A-Z Pagination-- */
    public void getAlphaRecords() {
        if(sortExpression != null) {
            filterQuery();
            if(charLink != null && charLink.equals('Other')){
                String strChar = ' and (';
                for(Integer i=0; i<=9; i++){
                    strChar = strChar + sortExpression +' like \''+ i +'%\''+' or ';
                }
                strChar = strChar.subString(0, strChar.length()-3) + ')';
                strChar = query + strChar;
                System.debug('strChar = '+strChar);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(strChar ));                                                                                                                                            
            } else if(charLink != null && charLink.equals('All')){
                String sortFullExp = sortExpression  + ' ' + sortDirection;                        
                String queryAll = query ;
                queryAll = queryAll + ' order by ' + sortFullExp;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryAll));                                                                                                                                                                    
            } else {
                String strChar = charLink + '%';
                String alphaQuery = query +' and '+ sortExpression +' like :strChar  ';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(alphaQuery));                    
            }                      
        }
    }
    /*--method which sets value in StandardSetControler-- */
    public void getRecords() {       
        if(strKeyword != null && queryConditionOrder == null){
            queryCondition = query + ' where CaseNumber like :strKeyword or Priority like :strKeyword or Status like :strKeyword  or Subject like :strkeyword';
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryCondition));        
            System.Debug('setCon '+setCon );
        } else if(queryConditionOrder != null && strKeyword == null){
            queryCondition = query ;
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryConditionOrder));                    
            System.Debug('QUERY'+queryConditionOrder);
        } else{
            queryCondition = query + ' where CaseNumber like :strKeyword or Priority like :strKeyword or Status like :strKeyword  or Subject like :strkeyword';
            String totalQueryCondition = queryCondition + ' order by ' + sortFullExp;
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(totalQueryCondition));                               
        }         
        getCaseList ();
    }
    
    /* method for sorting columns */
    public PageReference viewData(){
        filterQuery();
         /* build the full sort expression */
        System.Debug('SORT EXPRESSION '+sortExpression+' SORT DIRECTION '+sortDirection);
        sortFullExp = sortExpression  + ' ' + sortDirection;
        queryConditionOrder = query + ' order by ' + sortFullExp;
        getRecords();
        return null;
    }
    
    /*Pagination Controls End here */
     
    public List<Case> getCaseList (){    
        caseList = new List<Case>();
        caseList = setcon.getRecords();            
        return caseList ;        
    }                
    
    /* adding the options in list view picklist */
    public void listOptions() {
        viewOptions.add(new SelectOption('My Open Issues', 'My Open Issues'));
        viewOptions.add(new SelectOption('All Open Support', 'All Open (Support)'));
        viewOptions.add(new SelectOption('All Open Services', 'All Open (Services)'));
        viewOptions.add(new SelectOption('All Open Feedback', 'All Open (Feedback)'));
        //viewOptions.add(new SelectOption('All Open Escalate Manager', 'All Open (Escalate Manager)'));
        viewOptions.add(new SelectOption('Queue (Support)', 'Queue (Support)'));        
        viewOptions.add(new SelectOption('Queue (Services)', 'Queue (Services)'));//steffi added 11 jan
        viewOptions.add(new SelectOption('Queue (Feedback)', 'Queue (Feedback)'));
        //viewOptions.add(new SelectOption('Queue (Escalate Manager)', 'Queue (Escalate Manager)'));
    }

   /* save case record */
    public PageReference doSave() {
        try {
            if(ApexPages.currentPage().getParameters().get('page') != '' && ApexPages.currentPage().getParameters().get('page') != null){
                String page1 = ApexPages.currentPage().getParameters().get('page');
                if(caseRecord.status != 'closed' && page1.equals('detail')){
                   System.debug('######### Entered inside if');
                    caseRecord.Close_Reason__c = null;
                }
            }
              if(caseRecord.Id == null && caseRecord.OwnerID == null && caseRecord.recordTypeID != null) {     
                  if(SmRecordTypeToQueue__c.getAll() != null && SmRecordTypeToQueue__c.getAll().containsKey(caseRecord.recordTypeID)) {          
                      string tmpRecTypeId = caseRecord.recordTypeID;
                      caseRecord.OwnerID = SmRecordTypeToQueue__c.getInstance(tmpRecTypeId).QueueId__c;                      
                      /*
                      if(caseRecord.recordTypeID == '01250000000UKpsAAG') { //Situation Management - Support Feedback 
                          caseRecord.OwnerID = '00G50000001R8aaEAC';                  
                      } else if(caseRecord.recordTypeID == '01250000000UK1EAAW') { //Situation Management - Support
                          caseRecord.OwnerID = '00G50000001R8aQEAS';
                      } else if(caseRecord.recordTypeID == '01250000000UKa9AAG') { //Situation Management - Services
                          caseRecord.OwnerID = '00G50000001R8aVEAS';
                      }*/                                       
                  }  
              }
              errorFlag = false;        
              upsert caseRecord; 
         } catch(Exception e) {
            errorFlag = true;
            ApexPages.addMessages(e);
            return null;
       }
       if(caseComment != null && caseComment != '') {
            CaseComment ccRecord = new CaseComment (
                ParentId = caseRecord.id,
                CommentBody = caseComment
            );
            try {
                insert ccRecord;
            } catch(Exception e) {
                ApexPages.addMessages(e);
                return null;
            }
        }
        PageReference pgRef = detailPageRef(caseRecord.id, type);
        return pgRef;
    }
    
    /* method to redirect to case create page */
    public void doClone() {
        Id caseId = caseRecord.id;
        caseRecord = new Case();
        caseRecord = cloneCase(caseId);
    }
    
    public Case cloneCase(String caseId) {
        Case caseClone = new Case();
        caseClone = SituationUtil.queryCase(caseId).clone(false, true);
        return caseClone;
    }    
       
    /*
    public class casewrapper
    {
        public case cse{get; set;}        
        public casewrapper(Case c){cse = c;}
    }*/            
    
    public String chosenEntry { get; set { chosenEntry = value; } }   
    public PageReference DeleteSelected()
    {                              
        myDeleteCases = Apexpages.currentPage().getParameters().get('chosenEntry');                       
        if(myDeleteCases.length()> 0)
        {
            List<Id> myDeleteIds = myDeleteCases.split(',');
            //System.debug('Delete Selected Called==>' + myDeleteCases + myDeleteIds);                             
            delete new List<Case>([select Id from Case where ID IN :myDeleteIds]);                        
        }         
        myDeleteCases='';
        search();
        return null;    
    }
        
    public PageReference DeleteSingleSelected()
    {                                           
        //System.debug('DeleteSingleSelected Called ==>' + chosenEntry);        
        if(chosenEntry.length()> 0)
        {
            List<Id> myDeleteIds = chosenEntry.split(',');
            //System.debug('DeleteSingleSelected Called==>' + chosenEntry+ myDeleteIds);                                      
            delete new List<Case>([select Id from Case where ID IN :myDeleteIds]);                                    
        }
        chosenEntry = '';
        search();
        return null;    
    }      
    
    
    public PageReference doDelete() {        
        try {
            delete caseRecord;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        PageReference pgRef = new PageReference('/apex/SituationList');
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    //Bikram 15 Nov 2012
    public PageReference gotoListSearch()
    {
        PageReference pgRef = new PageReference('/apex/SituationList?filterBy='+filterBy);
        pgRef.setRedirect(true);
        return pgRef;            
    }   
    
    /* method to redirect to case detail page */
    public PageReference viewCaseDetail() {
        String selectedCaseId = ApexPages.currentPage().getParameters().get('selectedCaseId');
        String recType = ApexPages.currentPage().getParameters().get('recType');
        String rec = '';
        if(recType != null && recType.containsIgnoreCase('Services'))
            rec = 'serv';
        else if(recType != null && recType.containsIgnoreCase('Feedback'))
            rec = 'feed';  
        else if(recType != null && recType.containsIgnoreCase('Support'))
            rec = 'supp'; 
        else if(recType != null && recType.containsIgnoreCase('Escalation'))
            rec = 'EscMan';                 
        PageReference pgRef = detailPageRef(selectedCaseId, rec);
        return pgRef;
    }
    
    /* method to redirect to case create page */
    public PageReference createCase() {
        PageReference pgRef = new PageReference('/apex/SituationRecordTypeSelect');
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case list page */
    public String selectedRecType { get; set; }
    public PageReference doCancel() {
        String recid = '';
        try {
            recid = ApexPages.currentPage().getParameters().get('id');  
            if(recid.length() > 0){             
                PageReference pgRef;          
                if(type.equals('serv')) {
                    String url = '/apex/SituationServicesDetail?type=serv';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);                
                } else if(type.equals('supp')) {
                    String url = '/apex/SituationSupportDetail?type=supp';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);
                } 
                /*else if(type.equals('feed')) {
                    String url = '/apex/SituationFeedbackDetail?type=feed';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);
                } */
                else if(type.equals('EscMan')) {
                    String url = '/apex/EscalateManagerDetail?type=feed';
                    url += (recid== null) ? '' : ('&id=' + recid);                
                    pgRef = new PageReference(url);
                }          
                pgRef.setRedirect(true);
                return pgRef;
            }                   
        }
        catch(Exception ex)
        {
            recid = '';            
        }
        PageReference pgRef = new PageReference('/apex/SituationList');
        pgRef.setRedirect(true);
        return pgRef;      
    }   
    
    /* method to redirect to case edit page */
    public PageReference caseEdit() {
        PageReference pgRef = createPageRef(caseRecord.id, type, '');
        return pgRef;
    }
    
    /* method to redirect to case detail page */
    public PageReference redirectToCaseDetail() {
        PageReference pgRef = detailPageRef(caseRecord.id, type);
        return pgRef;
    }
    
    /* method to redirect to case clone page */
    public PageReference redirectToCaseClone() {
        if(type == null) {type = SituationUtil.getCaseRecordTypeParam(CaseRecord.Id);}    
        PageReference pgRef = createPageRef(caseRecord.id, type, 'clone');
        return pgRef;
    }
    
    /* method to redirect to case edit page */
    public PageReference redirectToCaseEdit() {
        PageReference pgRef;// = createPageRef(caseRecord.id, type, 'edit');
        //system.debug('caseRecordid=>'+caseRecord.id + '<=>' +  CaseRecord.type);                              
        if(type == null) {type = SituationUtil.getCaseRecordTypeParam(CaseRecord.Id);}
        if(type.equals('serv'))
            pgRef = new PageReference('/apex/SituationServicesCreate?id=' + caseRecord.id + '&page=edit&type='+type);
        else if(type.equals('supp'))
            pgRef = new PageReference('/apex/SituationSupportCreate?id=' + caseRecord.id + '&page=edit&type='+type);
        else if(type.equals('EscMan'))
            pgRef = new PageReference('/apex/EscalateManagerCreate?id=' + caseRecord.id + '&page=edit&type='+type);
        else
            pgRef = new PageReference('/apex/EscalateManagerCreate?id=' + caseRecord.id + '&page=edit&type='+type);
        
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case close page */
    public PageReference redirectToCaseClose() {       
        PageReference pgRef;    
        if(type == null) {type = SituationUtil.getCaseRecordTypeParam(CaseRecord.Id);}
        if(type.equals('serv'))
            pgRef = new PageReference('/apex/SituationServicesClose?id=' + caseRecord.id + '&page=close&type='+type);
        else if(type.equals('supp'))
            pgRef = new PageReference('/apex/SituationClose?id=' + caseRecord.id + '&page=close&type='+type);
        else if(type.equals('feed')) 
            pgRef = new PageReference('/apex/SituationFeedbackClose?id=' + caseRecord.id + '&page=close&type='+type);
        else if(type.equals('EscMan')) 
            pgRef = new PageReference('/apex/SituationFeedbackClose?id=' + caseRecord.id + '&page=close&type='+type);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public List<SelectOption> getOptions(){
        List<SelectOption> option = new List<SelectOption>();
        option.add(new SelectOption('','--None--' ));
        option.add(new SelectOption('Closed', 'Closed'));
        return option;
    }
    
     /* method to redirect to add comment page */
    public PageReference goToComment() {
        PageReference pgRef;
        pgRef = new PageReference('/apex/SituationComments?id='+caseRecord.id +'&type='+type);
        pgRef.setRedirect(true);
        return pgRef;
    }   
    
    /* method to add comment to case */
    public PageReference addComment() {
        try {
            if(caseComment != null && caseComment != '') {
                String commentId = ApexPages.currentPage().getParameters().get('cmnt');
                CaseComment ccRecord;
                if(commentId != null) {
                    ccRecord = new CaseComment (
                        id = commentId
                    );
                } else {
                    ccRecord = new CaseComment ( ParentId = caseRecord.id );
                }
                ccRecord.CommentBody = caseComment;
                System.Debug('This is to check isPublicCmnt value'+isPublicCmnt);
                If(isPublicCmnt == null){
                    ccRecord.isPublished = false;
                }else {
                    ccRecord.isPublished = isPublicCmnt;
                }
                upsert ccRecord;
            } else {
                ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, System.Label.Comment_Is_Required));
                return null;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, e.getMessage()));
            return null;
        }
        PageReference pgRef = detailPageRef(caseRecord.id, type);
        return pgRef;
    }
    
    public PageReference detailPageRef(String caseId, String type) {
        PageReference pgRef;
        if(type == null) {type = SituationUtil.getCaseRecordTypeParam(CaseRecord.Id);}
        //if(type == null) type = CaseRecord.Type;
        if(type != null) {
            if(type.equals('serv')) {
                pgRef = new PageReference('/apex/SituationServicesDetail?id=' + caseId + '&page=detail&type=serv');
                pgRef.setRedirect(true);
            } else if(type.equals('supp')) {
                pgRef = new PageReference('/apex/SituationSupportDetail?id=' + caseId + '&page=detail&type=supp');
                pgRef.setRedirect(true);                
            } else if(type.equals('feed')) {
                pgRef = new PageReference('/apex/SituationFeedbackDetail?id=' + caseId + '&page=detail&type=feed');
                pgRef.setRedirect(true);
            }else if(type.equals('EscMan')) {
                pgRef = new PageReference('/apex/EscalateManagerDetail?id=' + caseId + '&page=detail&type=EscMan');
                pgRef.setRedirect(true);
            }
        }        
        //System.debug('detailPageRef=>' + caseId + ' ' +type);
        return pgRef;
    }
    
    public PageReference createPageRef(String caseId, String type, String page) 
    {
        PageReference pgRef;        
        if(type != null) {
            if(type.equals('supp')) {
                String url = '/apex/SituationSupportCreate?';
                url += (caseId == '') ? '' : ('id=' + caseId + '&');
                url += 'page=' + page + '&type=supp';
                pgRef = new PageReference(url);
                pgRef.setRedirect(true);                
            } else if(type.equals('serv')) {
                String url = '/apex/SituationServicesCreate?';
                url += (caseId == '') ? '' : ('id=' + caseId + '&');
                url += 'page=' + page + '&type=serv';
                pgRef = new PageReference(url);
                pgRef.setRedirect(true);
            }  else if(type.equals('feed')) {
                String url = '/apex/SituationFeedbackCreate?';
                url += (caseId == '') ? '' : ('id=' + caseId + '&');
                url += 'page=' + page + '&type=feed';
                pgRef = new PageReference(url);
                pgRef.setRedirect(true);
            } else if(type.equals('EscMan')) {
                String url = '/apex/EscalateManagerCreate?';
                url += (caseId == '') ? '' : ('id=' + caseId + '&');
                url += 'page=' + page + '&type=EscMan';
                pgRef = new PageReference(url);
                pgRef.setRedirect(true);
            }
        }
        return pgRef;
    }    
    
    /*get list of comma seprated email ids and return list */
    public List<String> getEmailAddressList(String myEmails)
    {
        myEmails = myEmails.deleteWhitespace();
        if(myEmails.contains(',')){ myEmails = myEmails.replaceAll(',',';');}
        if(myEmails.contains(';')){ return myEmails.split(';');}
        List<String> myLst = new List<String>();
        myLst.Add(myEmails);
        return myLst;
    }    
}