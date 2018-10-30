/****************************************************
Class Name: CaseController
Author: ClearTeask
Created Date: 5/21/2012
Usage: This class is used for showing case list view, pagination, case create, status change.
*****************************************************/
public with sharing class CaseController {
    
    String query = 'select id, CaseNumber, Status, createdDate, ClosedDate, Case_Status__c, Close_Reason_Eligible_for_Reopen__c, Priority, Subject, Asset__c, Previous_Case_Status__c from Case ';
       
    public Case   caseRecord {get;set;}
    public String filterBy {get; set;}
    public String strField {get;set;}
    public String charLink {get;set;}
    public String fileName {get; set;}
    public String caseComment {get; set;}
    public String resellerName {get; set;}
    public String entitlementName{get;set;}
    public String contactEmail{get;set;}
    
    public Boolean saveConfirm {get; set;}
    public Boolean authorizedUser {get; set;}
    public Boolean fileAttached {get; set;}
    public Boolean isP1Case {get; set;}
    
    public Integer fileSize {get; set;}
    
    public List<CaseComment> caseCommentList {get; set;}
    public List<Attachment> caseAttachList {get; set;}
    public List<SelectOption> viewOptions {get; set;}
    
    public boolean dAcceptSugBtn {get; set;}
    public boolean dReopenBtn {get; set;}
    public Boolean isPartnerSupported {get; set;}
    public Boolean isSandbox {get; set;}
    public Boolean isInactive {get; set;}
    public Boolean byPassActiveCheck {get;set;}
    public String authorizedContactName {get;set;}/*vishals@grazitti.com*/
    public String authorizedContactEmail{get;set;}/*vishals@grazitti.com*/    
    public Boolean isSupportedInstance {get; set;}/*bikramt@grazitti.com*/
    public String authorizedCompanyName {get;set;}/*bikramt@grazitti.com*/
    
    public Map<Id,String> closedCaseIdToSurveyLinkMap{get;set;}  
    public String myPodName{get;set;}  

    public Map<String,Integer> caseStatusToNumberOfCases{get;set;}

    //4135
    public boolean addAuthUsrError{get;set;} 
    public Id usrContactId;
    public Boolean RedirectToCaseCreatePage;  
     
    //bikram 4998
    public boolean assetError{get;set;}   
    public Map<Id,boolean> caseAssetErrorMap{get;set;}
    
    public Attachment attachmentObj {
        get{
            if (attachmentObj == null)
            attachmentObj = new Attachment();
            return attachmentObj;
        }
        set;
    }    
        
    String queryCondition;
    String queryConditionOrder;
    String strKeyword;
    String sortFullExp;
    
    private String sortExp = 'CaseNumber';
    private String sortDirection = 'ASC';
    public List<Case> caseList;
    public Boolean isSite {get; set;}
    
    
    //Bikram 5/Mar/3684, add Asset__c to query
    public String currUserMunchkinId{get;set;}    
    public String usrAccntId{get;set;}
    public String usrAssetId{get;set;}
    public String usrEntitlemntId{get;set;}
            

    //bikram 5285
    public String caseOnBehalf{get;set{caseonBehalf = value;}}
    public String accOnBehalf{get;set;}
    public String contactOnBehalf{get;set;}
    public Case   caseRecordOnBehalf {get;set;}
    public String UserType {get;set;}
    public Boolean isUnauthorizedInternalUser {get;set;}

    //public Boolean isPreferredService {get;set;}
    
    /* Constructor for redirecting Sandbox users, Partner Supported Users, and inactive Users */
    public CaseController() {

        caseAssetErrorMap = new Map<Id,Boolean>();    
        assetError = false;            
        String userType = UserInfo.getUserType();
        myPODName = '';
        myPrioritySet = '<=High=><=Medium=><=Low=><=Critical=><=P1=><=P2=><=P3=><=P4=>';          
        myStatusSet  ='<=New=><=Working=><=Awaiting Customer Input=><=Pending Marketo Response=><=Pending Response=><=Suggestion Provided=><=Escalated=><=Awaiting Fix=><=Closed=><=Referred to Ideas=><=Resolved=><=Spark Email Reroute=><=Routed to Tier 2=><=Meeting Scheduled=><=Transferred=>';
        
        
        //4135
        authorizedUser = true;
        RedirectToCaseCreatePage = false;
        
        if (userType != 'Standard') {
            init();                       
        }       
    }
    
    
    public void init() {
    
        Set<String> byPassList = new Set<String>();
        byPassList.addAll(System.Label.Internal_Case_Create_Page_Access_Email_List.split(','));        
        List<User> userList = [select id, Munchkin_ID__c,ContactId,Email,Contact.Account.Type,Contact.Account.Partner_Type__c,Contact.Email,Contact.Redirect_To_Case_Create__c from User where id = :UserInfo.getUserId()];
        String currUserMunchkinId;

        if(userList != null && userList.size() > 0) {            
            currUserMunchkinId = userList[0].Munchkin_ID__c;
            usrContactId = userList[0].ContactId;         
            if(userList[0].Email != NULL && (userList[0].Email.endsWithIgnoreCase('@marketo.com'))){// || byPassList.contains(userList[0].Email))){
               this.UserType = 'Internal';                    
            }            
            if(userList[0].Contact.Email != NULL) { //Page redirect for authorized contact redirect based on contact email
                contactEmail  = userList[0].Contact.Email;
                RedirectToCaseCreatePage = userList[0].Contact.Redirect_To_Case_Create__c;
            }                
            //sops-59, modified error message based on wrong munchkinId
            List<Authorized_Contact__c> authorizedContact = [Select Id, Entitlement__c,createdDate, lastModifiedDate, Entitlement__r.Status from Authorized_Contact__c where Contact__c =: userList[0].ContactId AND Entitlement__r.Status = 'Active'];
            byPassActiveCheck = authorizedContact.isEmpty() == true ? false : true;                
        }
        
        List<Asset> assetList = [Select id, Supported_Instance__c, Purpose__c, Munchkin_ID__c, POD__c, Partner_Supported__c,Account.Name_of_Reseller__c,          
        Account.Name From Asset a where Munchkin_ID__c = :currUserMunchkinId and (Purpose__c = 'Production' OR Purpose__c = 'LP Sandbox' OR Purpose__c = 'Internal') and Munchkin_ID__c != null limit 1];
        
        List<Entitlement> entList = [Select id, Status,AccountId,AssetId,Asset.Purpose__c,Asset.Munchkin_ID__c,Asset.Partner_Supported__c, Asset.POD__c,
        Asset.Account.Name_of_Reseller__c From Entitlement where Asset.Munchkin_ID__c = :currUserMunchkinId and Status = 'Active' and Asset.Munchkin_ID__c != null limit 1];
        
        
        if(entList.isEmpty() == FALSE) {
            usrEntitlemntId =  entList[0].Id;
            if(entList[0].AssetId != NULL && entList[0].Asset.Purpose__c == 'LP Technology') {
                this.UserType = 'LP Technology';
            }
        }

        //List<Asset> assetListPartner = [Select id, Partner_Supported__c, Purpose__c, Account.Name_of_Reseller__c, POD__c From Asset a where Munchkin_ID__c = :currUserMunchkinId and Partner_Supported__c = true and Munchkin_ID__c != null limit 1];        
        //Add internal purpose with/without Supported Instance access to support portal
        //List<Asset> internalListPartner = [Select id, Supported_Instance__c, Purpose__c, Account.Name, POD__c  From Asset a where Munchkin_ID__c = :currUserMunchkinId and Purpose__c = 'Internal' and Munchkin_ID__c != null limit 1];
        //System.debug(internalListPartner);                    
        if (assetList.isEmpty() || (currUserMunchkinId == null && currUserMunchkinId == '')) {
            isSandbox = true;
        }         
        //if(!assetListPartner.isEmpty()) {
        if(assetList.isEmpty() == FALSE) {
            if(assetList[0].Partner_Supported__c == true) { // check for partner
                isPartnerSupported = true;
                resellerName = assetList[0].Account.Name_of_Reseller__c;
            } else if(assetList[0].Purpose__c == 'Internal') { //check for internal
                isSupportedInstance = true;
                authorizedCompanyName = assetList[0].Account.Name;
                System.debug('authorizedCompanyName' + authorizedCompanyName);            
            }
            if(entList.isEmpty()) {
                isInactive = true;   
            }  
            myPODName  = assetList[0].Pod__c;
            System.debug('myPODName==>' + myPODName);    
            usrAssetId =  assetList[0].Id;
            System.debug('usrAssetId==>' + usrAssetId);                                        
        } 
        
        
    }
    
    /* Page reference to redirect user to intermediate page */
    
    public PageReference doRedirectUser() {    
        if (((isSupportedInstance != true) && (isSandbox == true || isPartnerSupported == true || isInactive == true))) {
            PageReference pgRef;
            if(Utils.isSite) {
                pgRef = new PageReference('/SupportRedirect');
            } else {
                pgRef = new PageReference('/apex/SupportRedirect');
            }
            pgRef.setRedirect(true);
            return pgRef;
        } 
        List<Contact> userContact = [Select email, id, Redirect_To_Case_Create__c from Contact Where Id =: usrContactId and id != null];
        if(userContact.isempty() == false) {
            if(userContact[0].Redirect_To_Case_Create__c == true) {
                PageReference pgRef = Page.Case_Create_Page;                
                userContact[0].Redirect_To_Case_Create__c = false;
                update userContact;
                pgRef.setRedirect(true);
                return pgRef;
            }
        }        
        return null;
    }
    
    /* Page reference to redirect user to intermediate page */
    
    public PageReference redirectParature() {
        
        PageReference pgRef;
        pgRef = new PageReference('https://app.marketo.com/homepage/success?task=ticket');
        pgRef.setRedirect(true);
        return pgRef;
       
    }
    
    /* Pagination Controls Start here */ 
     
    /* --setCon as ApexPages.StandardSetController --*/
    public ApexPages.StandardSetController setCon {
        get {
            
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([select id , CaseNumber, Close_Reason_Eligible_for_Reopen__c, Status, Case_Status__c, Priority, Subject from Case])); //where Owner__c = :userName 
                
            }
            setCon.setPageSize(25);
            return setCon;
        }
        set;
    }
    
    /*--returns the sort expression --*/
    public String sortExpression {
        get{            
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
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    /*-- method to be set sort direction image-- */
    public void setSortDirection(String value) {  
        sortDirection = value;
    }
    
    List<User> usrList = [Select u.Username, u.UserType, u.LanguageLocaleKey, u.UserRole.Name, u.UserRoleId, u.Name, u.Contact.Name, u.Contact.FirstName, 
            u.Contact.LastName, u.Contact.AccountId, u.Contact.Is_Authorized_Contact__c, u.ContactId, u.AccountId,
            u.Contact.Email, u.Contact.Account.Partner_Type__c, u.Contact.Account.Type
            From User u where Id =: UserInfo.getUserId()];
    
    Id userId = UserInfo.getUserId();
    Id accId = usrList[0].Contact.AccountId;
    Id userContactId = usrList[0].ContactId;
    Boolean isClosedTrue = true;
    Boolean isClosedFalse = false;
    String CLOSED = 'Closed';
    String SOFTCLOSE1 = 'Suggestion Provided';
    String SOFTCLOSE2 = 'Awaiting Fix';
    String SOFTCLOSE3 = 'Awaiting Engineering Fix (Soft Close)';
    
    // constructor
    public CaseController(ApexPages.StandardController controller){
        caseAssetErrorMap = new Map<Id,Boolean>();
        assetError = false;
        authorizedUser = true;
        fileAttached = false;
        caseRecord = (Case) controller.getRecord();
        dAcceptSugBtn = false;
        dReopenBtn = false;
        isSite = Utils.isSite;
        RedirectToCaseCreatePage = false;
        myPrioritySet = '<=High=><=Medium=><=Low=><=Critical=><=P1=><=P2=><=P3=><=P4=>';          
        myStatusSet  ='<=New=><=Working=><=Awaiting Customer Input=><=Pending Marketo Response=><=Pending Response=><=Suggestion Provided=><=Escalated=><=Awaiting Fix=><=Closed=><=Referred to Ideas=><=Resolved=><=Spark Email Reroute=><=Routed to Tier 2=><=Meeting Scheduled=><=Transferred=>';
       
        System.debug('Open Script Called Std==>' + userId );
        caseonBehalf = 'Me';    
        caseRecordOnBehalf = new Case ();
        system.debug('<==Standard Object Constructor Called==>');        
        
        PageReference pageRef = ApexPages.currentPage();
        
        Set<String> byPassList = new Set<String>();
        byPassList.addAll(System.Label.Internal_Case_Create_Page_Access_Email_List.split(','));            
        System.debug('byPassList==>' + byPassList);

        
        //bikram 8/03/ 3684
        List<User> currentUser = [Select id, Email,Munchkin_Id__c,ContactId,Contact.Is_Authorized_Contact__c, Contact.Email,Contact.Redirect_To_Case_Create__c, Contact.Account.Type, Contact.Account.Name, Contact.Account.Partner_Type__c from User Where Id =: UserInfo.getUserId()];
        authorizedCompanyName = currentUser[0].Contact.Account.Name;
        currUserMunchkinId = currentUser[0].Munchkin_Id__c;
        usrContactId = currentUser[0].contactId;
        if(currentUser[0].ContactID != NULL) {
            contactEmail          = currentUser[0].Contact.Email;
            usrContactId          = currentUser[0].ContactId; 
            RedirectToCaseCreatePage = currentUser[0].Contact.Redirect_To_Case_Create__c;
        }
        if(currentUser[0].Email != NULL && (currentUser[0].Email.endsWithIgnoreCase('@marketo.com'))){ // || byPassList.contains(currentUser[0].Email) )){
            this.UserType = 'Internal';  
            if(currentUser[0].Contact.Is_Authorized_Contact__c.equals('No')){ // If user is not authorized user can only create cases for customer.
                isUnauthorizedInternalUser = true;
                caseOnBehalf = 'Customer';
            } 
        }        

        List<Entitlement> entList = [Select id,Status,Type,AccountId,AssetId,Asset.Purpose__c,Asset.Munchkin_ID__c,Asset.Partner_Supported__c,Asset.POD__c From Entitlement where AccountId = :accId AND Asset.Munchkin_ID__c = :currUserMunchkinId and Status = 'Active' and (Asset.Munchkin_ID__c != null OR Asset.Munchkin_ID__c != '') limit 1];
        if(!entList.isEmpty()) {   
            usrEntitlemntId = entList[0].Id;
            System.debug('usrEntitlemntId==>' + usrEntitlemntId);
            entitlementName = entList[0].Type != '' && entList[0].Type != null?entList[0].Type:'';    
            System.Debug('entitlementName+++'+entitlementName);
            System.Debug('entList+++++'+entList);
            if(entList[0].Asset.Id != NULL) {     
                usrAssetId = entList[0].Asset.Id;
                myPodName = entList[0].Asset.Pod__c;           
            }                             
            if(this.UserType != 'Internal' && entList[0].Asset.purpose__c == 'LP Sandbox'){
                this.UserType = 'LP Technology'; 
            }                    
        }
        

        
        /* vishals@grazitti.com 23-08-12 START */
        authorizedContactName = '';
        List<Authorized_Contact__c> authConList = [Select a.Entitlement__r.AccountId, a.Entitlement__c, 
                                                       a.Customer_Admin__c, a.Contact__r.Name, a.Contact__c,a.Contact__r.Email
                                                       From Authorized_Contact__c a
                                                       where Entitlement__r.AccountId = :accId AND a.Customer_Admin__c = true];
        
        if(authConList != null && authConList.size() > 0) {
           authorizedContactName = authConList[0].Contact__r.Name;
           authorizedContactEmail = authConList[0].Contact__r.Email;
        }
        /* vishals@grazitti.com 23-08-12 END */
        
        if(((String)pageRef.getUrl()).contains('Case_Detail_Page')){
        
            if(caseRecord.Case_Status__c == 'Awaiting Fix' || caseRecord.Case_Status__c == 'Suggestion Provided (Open)'){
                dReopenBtn = true;
            }
            if(caseRecord.Case_Status__c == 'Suggestion Provided'){
                dAcceptSugBtn = true;
            }
        }
        if(usrList != null && usrList.size() > 0) {
            caseRecord.ContactId = usrList[0].ContactId;
            caseRecord.AccountId = usrList[0].AccountId;
            if(usrList[0].Contact.Is_Authorized_Contact__c != null && usrList[0].Contact.Is_Authorized_Contact__c.equals('No') && this.userType != 'Internal' ) {            
                authorizedUser = false;
                CaseOnBehalf = 'Customer';
            }
        }
        
        String confirm = ApexPages.currentPage().getParameters().get('save');
        if(confirm != null && confirm.equals('confirm'))
            saveConfirm = true;            
        String currPageParam =    ApexPages.currentPage().getParameters().get('filterBy');
        filterBy = currPageParam == null?System.Label.My_Open_Cases:currPageParam.replaceAll('_',' ');        
        viewOptions = new List<SelectOption>();
        listOptions();
        search();
        
        //String page = ApexPages.currentPage().getParameters().get('page');
        //if(page != null && page.equals('detail')) {
        caseCommentList = new List<CaseComment>();
        caseAttachList = new List<Attachment>();
        queryCommentsAndAttachments();
        //}                
        myPrioritySet = '<=High=><=Medium=><=Low=><=Critical=><=P1=><=P2=><=P3=><=P4=>';          
        myStatusSet  ='<=New=><=Working=><=Awaiting Customer Input=><=Pending Marketo Response=><=Pending Response=><=Suggestion Provided=><=Escalated=><=Awaiting Fix=><=Closed=><=Referred to Ideas=><=Resolved=><=Spark Email Reroute=><=Routed to Tier 2=><=Meeting Scheduled=><=Transferred=>';
    }
    
    /* query comments and attachment related to case */
    public void queryCommentsAndAttachments() {
        caseAttachList = [select id, Name, CreatedDate, CreatedById from Attachment 
                            where ParentId = :caseRecord.id order by CreatedDate DESC];
        caseCommentList = [select CommentBody, CreatedDate, CreatedById from CaseComment 
                            where ParentId = :caseRecord.id order by CreatedDate DESC];
    }
    
    /* search cases for list view */
    public void search(){
        filterQuery();
        
        sortFullExp = sortExpression  + ' ' + sortDirection;
        queryConditionOrder = query + ' order by ' + sortFullExp;
        getRecords();
        
        getCaseList();             
    }
    
    /* add filter to query */
    public void filterQuery(){
        
        String query;
        if(filterBy !=  null){//Bikram 5/Mar/3684                            
            String smRecIds = '';            
            if(Test.isRunningTest() == true) {
                smRecIds  = '01250000000UK1EAAW;01250000000UKa9AAG;01250000000UKpsAAG';                          
            } else {            
                smRecIds  = CaseRecordOrTypeIds__c.getInstance('SM_RecordType_Ids').ReferenceIds__c;
            }            
            List<String> sm_RecId = new List<String>();
            sm_RecId = smRecIds.split(';');
            if(filterBy.equals(System.Label.My_Open_Cases)){
                query = 'select id, CaseNumber, Status,createdDate, ClosedDate, Case_Status__c, Priority, Close_Reason_Eligible_for_Reopen__c, Subject, Previous_Case_Status__c from Case where ContactId = :userContactId AND RecordTypeId NOT in :sm_RecId ';
                query = query + ' and (isClosed = : isClosedFalse or Case_Status__c = :SOFTCLOSE1) ';  
            } else if(filterBy.equals(System.Label.My_Closed_Cases)){
                query = 'select id ,ContactId, AccountId, CaseNumber,Status,createdDate, ClosedDate, Case_Status__c,Close_Reason_Eligible_for_Reopen__c, Priority, Subject,Previous_Case_Status__c from Case where ContactId = :userContactId  AND RecordTypeId NOT in :sm_RecId ';
                query = query + ' and isClosed = : isClosedTrue and Case_Status__c != :SOFTCLOSE1 and Case_Status__c != :SOFTCLOSE2  ';
                closedCaseIdToSurveyLinkMap = getSurveyLinkForClosedCasesByLoggedInContact();            
            } else if(filterBy.equals(System.Label.My_Awaiting_Fix_Cases)){
                query = 'select id ,Close_Reason__c, CaseNumber,Status,createdDate, ClosedDate, Case_Status__c,Close_Reason_Eligible_for_Reopen__c, Priority, Subject,Previous_Case_Status__c from Case where ContactId = :userContactId  AND RecordTypeId NOT in :sm_RecId ';
                query = query + ' and isClosed = : isClosedTrue and Close_Reason__c = :SOFTCLOSE3 and Case_Status__c = :SOFTCLOSE2  ';
            } else if(filterBy.equals(System.Label.All_Company_Open_Cases)){
               query = 'select id , CaseNumber,Status,createdDate, ClosedDate, Case_Status__c, Priority,Close_Reason_Eligible_for_Reopen__c, Subject, AssetId,Previous_Case_Status__c from Case where AccountId = :accId  AND RecordTypeId NOT in :sm_RecId ';
               query = query + ' and (isClosed = : isClosedFalse or Case_Status__c = :SOFTCLOSE1) ';
               //query = query + ' AND (EntitlementId != null) ';//bikram 6163 AND  EntitlementId != \'\') AND (EntitlementId =: usrEntitlemntId)   ';//Bikram 5/Mar/3684
            } else if(filterBy.equals(System.Label.All_Company_Closed_Cases)){
               query = 'select id , CaseNumber,Status,createdDate, ClosedDate, Case_Status__c, Priority, Subject, Close_Reason_Eligible_for_Reopen__c,Previous_Case_Status__c from Case where AccountId = :accId  AND RecordTypeId NOT in :sm_RecId ';
               query = query + ' and ( isClosed = : isClosedTrue) and Case_Status__c != :SOFTCLOSE1 and Case_Status__c != :SOFTCLOSE2';                                 
               //query = query + ' AND (EntitlementId != null) '; //bikram 6163  AND  EntitlementId != \'\') AND (EntitlementId =: usrEntitlemntId) ';//Bikram 5/Mar/3684
            } else if(filterBy.equals(System.Label.All_Company_Awaiting_Fix_Cases)){
               query = 'select id ,Close_Reason__c, CaseNumber,Status,createdDate, ClosedDate, Case_Status__c, Priority, Subject, Close_Reason_Eligible_for_Reopen__c,Previous_Case_Status__c from Case where AccountId = :accId  AND RecordTypeId NOT in :sm_RecId ';
               query = query + ' and ( isClosed = : isClosedTrue) and Close_Reason__c = :SOFTCLOSE3 and Case_Status__c = :SOFTCLOSE2 ';                                  
               //query = query + ' AND (EntitlementId != null) ' ; // bikram 6163  AND EntitlementId != \'\') AND (EntitlementId =: usrEntitlemntId) ';//Bikram 5/Mar/3684
            }  
            System.Debug('sm_RecId+++'+sm_RecId);            
        }
        this.query = query;             
        System.debug('usrEntitlemntId==>query==>' + accId +  usrEntitlemntId + query);
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query)); 
        //return query;
    }
    
    /*--method which is called for A-Z Pagination-- */
    public void getAlphaRecords(){    
             
        String smRecIds = '';            
        if(Test.isRunningTest() == true) {
            smRecIds  = '01250000000UK1EAAW;01250000000UKa9AAG;01250000000UKpsAAG';                          
        } else {            
            smRecIds  = CaseRecordOrTypeIds__c.getInstance('SM_RecordType_Ids').ReferenceIds__c;
        }            
        List<String> sm_RecId = new List<String>();
        sm_RecId = smRecIds.split(';');
            
        if(sortExpression != null){
            filterQuery();
            if(charLink != null && charLink.equals('Other')){
                String strChar = ' and (';
                for(Integer i=0; i<=9; i++){
                    strChar = strChar + sortExpression +' like \''+ i +'%\''+' or ';
                }
                strChar = strChar.subString(0, strChar.length()-3) + ')';
                strChar = query + strChar + ' limit 10000 ';
                System.debug('strChar==>'+strChar);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(strChar));                                                                                                                                            
            } else if(charLink != null && charLink.equals('All')){
                String sortFullExp = sortExpression  + ' ' + sortDirection;                
                String queryAll = query ;
                queryAll = queryAll + ' order by ' + sortFullExp;
                System.debug('queryAll==>'+queryAll);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryAll));                                                                                                                                                                    
            } else if(charLink != null){
                String strChar = charLink + '%';
                String alphaQuery = query +' and '+ sortExpression +' like :strChar';                
                System.debug('alphaQuery==>'+alphaQuery);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(alphaQuery));                    
            }                  
        }
    }
    /*--method which sets value in StandardSetControler-- */
    public void getRecords() {
    
        String smRecIds = '';//CaseRecordOrTypeIds__c.getInstance('SM_RecordType_Ids').ReferenceIds__c;
        
        if(Test.isRunningTest() == true) {
                smRecIds  = '01250000000UK1EAAW;01250000000UKa9AAG;01250000000UKpsAAG';                          
        } else {            
                smRecIds  = CaseRecordOrTypeIds__c.getInstance('SM_RecordType_Ids').ReferenceIds__c;
        } 
        
        
        List<String> sm_RecId = new List<String>();
        sm_RecId = smRecIds.split(';'); 
       
        if(strKeyword != null && queryConditionOrder == null){
            queryCondition = query + ' where CaseNumber like :strKeyword or Priority like :strKeyword or Status like :strKeyword  or Subject like :strkeyword';
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryCondition));        
            
        } else if(queryConditionOrder != null && strKeyword == null){
            queryCondition = query ;
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryConditionOrder));                    
            
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
        viewOptions.add(new SelectOption(System.Label.My_Open_Cases, System.Label.My_Open_Cases));
        viewOptions.add(new SelectOption(System.Label.My_Closed_Cases, System.Label.My_Closed_Cases));
        viewOptions.add(new SelectOption(System.Label.My_Awaiting_Fix_Cases, System.Label.My_Awaiting_Fix_Cases)); 
        viewOptions.add(new SelectOption(System.Label.All_Company_Open_Cases, System.Label.All_Company_Open_Cases));
        viewOptions.add(new SelectOption(System.Label.All_Company_Closed_Cases, System.Label.All_Company_Closed_Cases));
        viewOptions.add(new SelectOption(System.Label.All_Company_Awaiting_Fix_Cases, System.Label.All_Company_Awaiting_Fix_Cases));       
    }
    
    /* save case record but check if P1 first*/
    public PageReference checkSaveFirst() {
        system.debug('checkSaveFirst() Called==>');
        try {
            if(caseRecord != null && caseRecord.Priority != null && caseRecord.Priority.equals('P1')) {
                isP1Case = true;
                return null;
            } else {                
            
                if(caseonBehalf != 'Me' && caseonBehalf.trim() != '' && UserType == 'Internal' )
                {
                    /*if(caseRecordOnBehalf.AccountId == NULL || caseRecordOnBehalf.ContactId == NULL){
                        //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Error: Please fill Account and Contact Field.');
                        //ApexPages.addMessage(myMsg);
                        //return null;
                    }
                    /*if(chkContactAcctLst.isEmpty()) {
                      ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Selected Account is not active or Authorized Contact is not valid.');
                      ApexPages.addMessage(myMsg);
                      return null;
                    }*/
                    List<Contact> chkContactAcctLst = [SELECT Id from Contact Where id = :caseRecordOnBehalf.ContactId AND AccountId = :caseRecordOnBehalf.AccountId AND Account.Type NOT IN ('ex-customer','ex-partner') Limit 1];
                    Id myAccId = usrList[0].Contact.AccountId ;                                                       
                } else If(caseonBehalf == 'Me' && isUnauthorizedInternalUser == true) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You are not authorized to create case');
                    ApexPages.addMessage(myMsg);  
                    return null; 
                }   
            
                List<BusinessHours> bhList = [Select b.Name From BusinessHours b where Name = 'US'];
                if(bhList != null && bhList.size() > 0) {
                    caseRecord.BusinessHours = bhList[0];
                }
                caseRecord.Origin = 'Web';                                                                
                if(caseonBehalf.trim() == 'Customer' && userType == 'Internal'){
                    caseRecord.Is_For_Customer__c = TRUE;
                    caseRecord.Is_Preferred_Services__c = FALSE;
                    caseRecord.AccountId = caseRecordOnBehalf.AccountId;
                    caseRecord.ContactId = caseRecordOnBehalf.ContactId;       
                    caseRecord.Case_Creator_Account__c  = usrList[0].Contact.AccountId;
                    caseRecord.Case_Creator_Contact__c  = usrList[0].ContactId; 
                    caseRecord.Case_Creator_ContactEmail__c  = usrList[0].Contact.Email;                                   
                    caseRecord.PreferredServiceAccount__c = NULL;                
                } else {
                    caseRecord.Is_For_Customer__c = FALSE;
                    caseRecord.Is_Preferred_Services__c = FALSE;
                    caseRecord.ContactId = usrList[0].ContactId;
                    caseRecord.AccountId = usrList[0].AccountId;                
                    caseRecord.Case_Creator_Account__c  = NULL;
                    caseRecord.Case_Creator_Contact__c  = NULL;    
                    caseRecord.Case_Creator_ContactEmail__c = NULL;                                   
                    caseRecord.PreferredServiceAccount__c = NULL;                                               
                }                
                
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                caseRecord.setOptions(dmo);
                upsert caseRecord;
                PageReference pgRef;
                if(Utils.isSite) {
                    pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&save=confirm&page=detail');
                } else {
                    pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&save=confirm&page=detail');
                }
                pgRef.setRedirect(true);
                return pgRef;
            }                        
        } catch(Exception e) {

            if(e.getMessage().containsIgnoreCase('ParseEmail')) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Email List.');
                ApexPages.addMessage(myMsg);
                return null;    
            }
            ApexPages.addMessages(e);
            return null; 
        }        
        return null; 
    }
    
    /* save case record */
    public PageReference doSave() {
        
        System.debug('doSave() called==>');
        if(caseonBehalf.trim() == 'Customer')
        {
            if(caseRecordOnBehalf.AccountId == NULL || caseRecordOnBehalf.ContactId == NULL){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Error: Please fill Account and Contact Field.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            List<Contact> chkContactAcctLst = [SELECT Id from Contact Where id = :caseRecordOnBehalf.ContactId AND AccountId = :caseRecordOnBehalf.AccountId AND Account.Type NOT IN ('ex-customer','ex-partner') Limit 1];
            if(chkContactAcctLst.isEmpty()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Selected Account is not active or Authorized Contact is not valid.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            //List<User> myUserAccInfo = [SELECT ID,Contact.Email, Contact.AccountId, Contact.Account.Type, Contact.Account.Partner_Type__c from User where Id=:userinfo.getUserId() LIMIT 1];
            Id myAccId = usrList[0].Contact.AccountId ;                                                       
        } 
        
        try {
            if(caseRecord != null && caseRecord.Priority != null && caseRecord.Priority.equals('P1')) {
                List<BusinessHours> bhList = [Select b.Name From BusinessHours b where Name = 'P1 Issues'];
                if(bhList != null && bhList.size() > 0) {
                    caseRecord.BusinessHours = bhList[0];
                }
            } else {
                List<BusinessHours> bhList = [Select b.Name From BusinessHours b where Name = 'US'];
                if(bhList != null && bhList.size() > 0) {
                    caseRecord.BusinessHours = bhList[0];
                }
            }
            
            
            if(caseonBehalf.trim() == 'Customer' && userType == 'Internal'){
                caseRecord.Is_For_Customer__c = TRUE;
                caseRecord.Is_Preferred_Services__c = FALSE;
                caseRecord.AccountId = caseRecordOnBehalf.AccountId;
                caseRecord.ContactId = caseRecordOnBehalf.ContactId;       
                caseRecord.Case_Creator_Account__c  = usrList[0].Contact.AccountId;
                caseRecord.Case_Creator_Contact__c  = usrList[0].ContactId; 
                caseRecord.Case_Creator_ContactEmail__c  = usrList[0].Contact.Email;                                   
                caseRecord.PreferredServiceAccount__c = NULL;                
            }  else {
                caseRecord.Is_For_Customer__c = FALSE;
                caseRecord.Is_Preferred_Services__c = FALSE;
                caseRecord.ContactId = usrList[0].ContactId;
                caseRecord.AccountId = usrList[0].AccountId;                
                caseRecord.Case_Creator_Account__c  = NULL;
                caseRecord.Case_Creator_Contact__c  = NULL;    
                caseRecord.Case_Creator_ContactEmail__c = NULL;                                   
                caseRecord.PreferredServiceAccount__c = NULL;                                               
            }               
                        
            caseRecord.Origin = 'Web';
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            caseRecord.setOptions(dmo);
            upsert caseRecord;
        } catch(Exception e) {
            isP1Case = false;
            
            if (e.getMessage().containsIgnoreCase('ParseEmail')) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Email List.');
                ApexPages.addMessage(myMsg);
                return null;    
            }
            ApexPages.addMessages(e);
            return null; 
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&save=confirm&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&save=confirm&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* save case record */
    public PageReference doSaveP2() {
        
       System.debug('doSaveP2() called==>');

       if(caseonBehalf.trim() == 'Customer' && UserType == 'Internal')
        {
            if(caseRecordOnBehalf.AccountId == NULL || caseRecordOnBehalf.ContactId == NULL){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Error: Please fill Account and Contact Field.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            List<Contact> chkContactAcctLst = [SELECT Id from Contact Where id = :caseRecordOnBehalf.ContactId AND AccountId = :caseRecordOnBehalf.AccountId AND Account.Type NOT IN ('ex-customer','ex-partner') Limit 1];
            if(chkContactAcctLst.isEmpty()) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Selected Account is not active or Authorized Contact is not valid.');
                ApexPages.addMessage(myMsg);
                return null;
            }
            Id myAccId = usrList[0].Contact.AccountId ;                                                       
        }
         
        try {
            List<BusinessHours> bhList = [Select b.Name From BusinessHours b where Name = 'US'];
            if(bhList != null && bhList.size() > 0) {
                caseRecord.BusinessHours = bhList[0];
            }

            if(caseonBehalf.trim() == 'Customer' && userType == 'Internal'){
                caseRecord.Is_For_Customer__c = TRUE;
                caseRecord.Is_Preferred_Services__c = FALSE;
                caseRecord.AccountId = caseRecordOnBehalf.AccountId;
                caseRecord.ContactId = caseRecordOnBehalf.ContactId;       
                caseRecord.Case_Creator_Account__c  = usrList[0].Contact.AccountId;
                caseRecord.Case_Creator_Contact__c  = usrList[0].ContactId; 
                caseRecord.Case_Creator_ContactEmail__c  = usrList[0].Contact.Email;                                   
            } else {
                caseRecord.Is_For_Customer__c = FALSE;
                caseRecord.Is_Preferred_Services__c = FALSE;
                caseRecord.ContactId = usrList[0].ContactId;
                caseRecord.AccountId = usrList[0].AccountId;                
                caseRecord.Case_Creator_Account__c  = NULL;
                caseRecord.Case_Creator_Contact__c  = NULL;    
                caseRecord.Case_Creator_ContactEmail__c  = NULL;                                   
            }
                                                      
            caseRecord.Priority = 'P2';
            caseRecord.Origin = 'Web';
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            caseRecord.setOptions(dmo);
            upsert caseRecord;
        } catch(Exception e) {
            isP1Case = false;
            if (e.getMessage().containsIgnoreCase('ParseEmail')) {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Invalid Email List.');
                ApexPages.addMessage(myMsg);
                return null;    
            }
            ApexPages.addMessages(e);
            return null;
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&save=confirm&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&save=confirm&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* save updates to Email List on case record */
    public PageReference doSaveEmail() {
        
        try {
            case c1 = new case (id = caseRecord.Id);
            c1.Email_List__c = caseRecord.Email_List__c;    
            update c1;            
            //upsert caseRecord;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case detail page */
    public PageReference viewCaseDetail() {
        String selectedCaseId = ApexPages.currentPage().getParameters().get('selectedCaseId');
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + selectedCaseId + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + selectedCaseId + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case create page */
    public PageReference createCase() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Create_Page');
        } else {
            pgRef = new PageReference('/apex/Case_Create_Page');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case list page */
    public PageReference doCancel() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/CaseListPage');
        } else {
            pgRef = new PageReference('/apex/CaseListPage');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* methaod to redirect to case detail page if they cancel adding email */
    public PageReference doCancelEmail() {
        String selectedCaseId = ApexPages.currentPage().getParameters().get('selectedCaseId');
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + selectedCaseId + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + selectedCaseId + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case edit page */
    public PageReference editRedirect() {
        PageReference pgRef;
        
        if(UserInfo.getUserType() != null && UserInfo.getUserType().equals('PowerCustomerSuccess')) {
            if(Utils.isSite) {
                pgRef = new PageReference('/Case_Create_Page?id=' + caseRecord.id);
            } else {
                pgRef = new PageReference('/apex/Case_Create_Page?id=' + caseRecord.id);
            }
        } else {
            pgRef = new Pagereference ('/' + caseRecord.id + '/e?retURL=/%2F' + caseRecord.id + '&nooverride=1');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case edit page */
    public PageReference caseEdit() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Create_Page?id=' + caseRecord.id);
        } else {
            pgRef = new PageReference('/apex/Case_Create_Page?id=' + caseRecord.id);
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to accept suggestion and update case status */
    public PageReference acceptSuggestion() {
        //caseRecord.Status = 'Closed';
        //caseRecord.Close_Reason__c = 'Resolved';
        try {
            List<Case> closeCurCase = [SELECT Id, Status,createdDate, ClosedDate, Close_Reason__c,Customer_Temperature_on_Case_Closer__c from Case Where Id=:caseRecord.Id limit 1];
            closeCurCase[0].Status = 'Closed';
            closeCurCase[0].Close_Reason__c = 'Resolved';
            if(closeCurCase[0].Customer_Temperature_on_Case_Closer__c == NULL)
                closeCurCase[0].Customer_Temperature_on_Case_Closer__c = 'Unknown';            
            update closeCurCase; 
            //update caseRecord;
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to reject suggestion and update case status */
    public PageReference rejectSuggestion() {
        caseRecord.Status = 'Reopened';
        caseRecord.Close_Reason__c = null;
        try {
            update caseRecord;
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        }                   

        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case close page */
    public PageReference closeCase() {     
        //caseRecord.Status = 'Closed';
        //caseRecord.Close_Reason__c = 'Resolved';        
        try {
            List<Case> closeCurCase = [SELECT Id, Status, Close_Reason__c, Customer_Temperature_on_Case_Closer__c from Case Where Id=:caseRecord.Id limit 1];
            closeCurCase[0].Status = 'Closed';
            closeCurCase[0].Close_Reason__c = 'Resolved';
			if(closeCurCase[0].Customer_Temperature_on_Case_Closer__c == NULL)
                closeCurCase[0].Customer_Temperature_on_Case_Closer__c = 'Unknown';            
            update closeCurCase; 
            //update caseRecord;             
        } catch(Exception e) {
            return null;
            //ApexPages.addMessages(e);
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to case detail page */
    public PageReference redirectToCaseDetail() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    /* method to redirect to add attachment page */
    public PageReference goToAttach() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Attachment?id='+caseRecord.id);
        } else {
            pgRef = new PageReference('/apex/Case_Attachment?id='+caseRecord.id);
        }
        pgRef.setRedirect(true);
        return pgRef;
    } 
    
    /* method to redirect to add comment page */
    public PageReference goToComment() {
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Comment?id='+caseRecord.id);
        } else {
            pgRef = new PageReference('/apex/Case_Comment?id='+caseRecord.id);
        }
        System.Debug('pgRef++'+pgRef);
        pgRef.setRedirect(true);
        return pgRef;
    }   
    
    /* method to attach file to case */
    public PageReference attachFile() {
        try {
            if(attachmentObj != null && attachmentObj.Body != null) {
                attachmentObj.ParentId = caseRecord.id;
                insert attachmentObj;
                attachmentObj = [select Name, BodyLength, Body from Attachment where id = :attachmentObj.id];
                fileName = attachmentObj.Name;
                fileSize = attachmentObj.BodyLength;
                fileAttached = true;
            } else {
                ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, System.Label.Please_Upload_File));
            }
            attachmentObj = new Attachment();
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    /* method to add comment to case */
    public PageReference addComment() {
        try {
            if(caseComment != null && caseComment.trim() != '') {
                CaseComment ccRecord = new CaseComment (
                    ParentId = caseRecord.id,
                    CommentBody = caseComment
                );
                insert ccRecord;
            } else {
                ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, System.Label.Comment_Is_Required));
                return null;
            }
        } catch(Exception e) {
            ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, e.getMessage()));
        }
        PageReference pgRef;
        if(Utils.isSite) {
            pgRef = new PageReference('/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        } else {
            pgRef = new PageReference('/apex/Case_Detail_Page?id=' + caseRecord.id + '&page=detail');
        }
        pgRef.setRedirect(true);
        return pgRef;
    }        
    
    public String myPrioritySet{get;set;}             
    public Map<String,String> priorities{
    get {
        return new Map<String, String> {        
        ''   => '',
        'High' => 'High Priority',
        'Medium' => 'Medium Priority',
        'Low' => 'Low Priority',
        'Critical' => 'Critical Priority',
        'P1' => 'Production down: Production system, application, or critical feature/function is down.',
        'P2' => 'Production impaired: A major feature or function is not working correctly and is blocking full use of the Marketo system, but existing production campaigns are working correctly and other features are operational.',
        'P3' => 'Minor issue: A minor issue is impacting usability of the system, but a workaround is available and major features / functions are working correctly.',
        'P4' => 'P4'
        };
    }
    set;
    }               
         
    public String  myStatusSet {get;set;}        
    
    public Map<String,String> statuses{
    get {        
        return new Map<String, String> {        
        '' => '',
        'New' => 'New case that has not been assigned to a Support Engineer.',
        'Working' => 'Assigned to Support Engineer and work is in progress.',
        'Awaiting Customer Input' => 'Assigned Support Engineer has sent a question or request for information to the Case submitter and is waiting for a response.  If we do not hear back after two weeks and 3 email attempts, the Case will be closed via workflow.  If you feel the issue is not resolved, you can reopen the case within 10 days.',
        'Pending Marketo Response' => 'Updated by Case submitter waiting for a response from the assigned Support Engineer.  Cases that have been reopened by you will go into the Pending Marketo Response Status.',
        'Pending Response' => 'Updated by Case submitter waiting for a response from the assigned Support Engineer. Cases that have been reopened by you will also go into the Pending Response Status.',
        'Suggestion Provided' => 'Assigned Support Engineer provided a suggestion that should resolve the issue and is waiting for verification from the Case submitter.  If we do not hear back after 10 days and 3 email attempts, the case will be closed via workflow.  If you feel the issue is not resolved, you can reopen the case within 10 days.',
        'Escalated' => 'Escalated to Engineering for a patch to be applied before the next monthly release.  The Support Case will remain open until the patch has been applied and validated by the Case submitter.',
        'Awaiting Fix' => 'Submitted to Engineering and waiting for the fix to be delivered in the Marketo monthly release.',
        'Closed' => 'Case has been Closed and confirmed by the case submitter or workflow changed to Closed after email attempts from Suggestion Provided or Awaiting Customer Input.',
        'Referred to Ideas' => 'Referred to Ideas',
        'Resolved' =>'Resolved',
        'Spark Email Reroute' => 'Spark Email Reroute',
        'Routed to Tier 2' => 'Reassigned to a Senior Support Engineer or Subject Matter Expert for resolution.',
        'Meeting Scheduled' => 'Meeting Scheduled.',
        'Transferred' => 'Working.'
        };
    }
    set;
    }    
    
    
        //
    public String getSurveyLinkForCurrentCase() {
        // Return survey link for the case if
        //            contact is  authorized and asset.purpose is production
        //            contact has already not attended the survey for case
        
        // CONSTANTS
        final String ENGLISH      = 'English';
        final String GERMAN       = 'German';
        final String FRENCH       = 'French';
        final String SPANISH      = 'Spanish';
        final String PORTUGUESE   = 'Portuguese';
        final String JAPANESE     = 'Japanese';
        
        // if currentcase is not closed retirn from here
        String caseOwnerId  = caseRecord.ownerId;
        System.Debug('CASERECORD'+caseRecord);
        if(caseRecord.ClosedDate == null || caserecord.isclosed != true || caseRecord.Csat_Survey_Sent_For_Parent_Case__c ||
           caseOwnerId.startsWith('00G') || (CSatSurveySettings__c.getValues('IsCSatSurveyActive').Survey_Active__c != true)
           || ((caseRecord.Problem_Type__c == 'Configuration/Set Up') && (caseRecord.Category__c == 'Configuration Outreach'))
           ){
            return '';
        }
         
        // Whether contact eligible to attend surveys
        Boolean isEligibleForSurvey              = false;
        Set<String> validCaseCloseReasons        = new Set<String>{'Resolved','Referred to KB','Referred to Ideas','Referred to Other Group','No Response from Customer'};
        Map <Id, Boolean> contactIdToEligibility =  CSatSurvey.getContactsToSurveyEligibilityMap(new List<Id>{caseRecord.contactId});
        System.debug('DetailPageClosedDate===='+caseRecord.ClosedDate);
        if (contactIdToEligibility.containsKey(caseRecord.contactId) ) {
            isEligibleForSurvey = contactIdToEligibility.get(caseRecord.contactId);
        }
        
        System.Debug('isEligibleForSurvey'+ caseRecord.ClosedDate);
        if ((isEligibleForSurvey == false) || (caseRecord.Closed_Less_Than_10_Days_Ago__c == 'No') || !validCaseCloseReasons.contains(caseRecord.Close_Reason__c)) {
        //if ((isEligibleForSurvey == false) && (caseRecord.ClosedDate.addDays(30)< datetime.now()) && !validCaseCloseReasons.contains(caseRecord.Close_Reason__c)) {
            return ''; // return from here only if contact not eligible for survey
        }  
        //         

        //Bikram 4998        
        case cRecord = [SELECT EntitlementId, Entitlement.AssetID from Case Where Id=:caseRecord.ID limit 1];        
        if(cRecord.EntitlementID != null && cRecord.Entitlement.AssetID == null){ 
            assetError = true; 
            system.debug('CaseREcord Called==>'+assetError +cRecord.Entitlement.AssetID+cRecord.EntitlementID);
            PageReference pg = Page.CaseEntitlementError;                     
            String hostname = ApexPages.currentPage().getHeaders().get('Host');
            String currURL ='';
            Map<String,String> headerInfo = new Map<String,String>();
            headerInfo = ApexPages.currentPage().getHeaders();
            if(headerInfo.containsKey('CipherSuite'))
                currURL = 'https://' + hostname + pg.getURL();                 
            else 
                currURL =  'http://' + hostname + pg.getURL();                    
            return currURL;
        }

        if(cRecord.EntitlementID == null){
            assetError = true;
            return '';
        } 

        System.debug('assetError==>' +  assetError);

         
        //List<Community_Profile__c> portalUserProfiles = [Select c.User__r.ContactId, c.Language__c, c.CSatSurveyPreferences__c From Community_Profile__c c where c.User__r.ContactId =:caseRecord.contactId];
        List<Contact> caseCntctPrefLang = [SELECT Id, Preferred_Language__c from contact where id =:caseRecord.ContactId LIMIT 1];
        
        Map <String, String> languageToSurveyLink     = new Map<String, String> ();                
        String casePreferredLang = 'English';
        if(caseCntctPrefLang.size() > 0)casePreferredLang = caseCntctPrefLang[0].Preferred_Language__c;

        //System.debug('Preferred Language'+casePreferredLang);
        languageToSurveyLink.put(ENGLISH ,System.Label.CSatSurveyEnglish);
        languageToSurveyLink.put(FRENCH  ,System.Label.CSatSurveyFrench);
        languageToSurveyLink.put(GERMAN  ,System.Label.CSatSurveyGerman);
        languageToSurveyLink.put(SPANISH ,System.Label.CSatSurveySpanish);
        languageToSurveyLink.put(PORTUGUESE ,System.Label.CSatSurveyPortuguese);
        if(System.Label.JapaneseSurveyEnabled == 'Yes')languageToSurveyLink.put(JAPANESE ,System.Label.CSatSurveyJapanese);
        
        //To check supported Languages
        Set<String> supportedLang = new Set<String>{ENGLISH,FRENCH,GERMAN,SPANISH,PORTUGUESE};
        if(System.Label.JapaneseSurveyEnabled == 'Yes')supportedLang.Add(JAPANESE);
        
		boolean resultspotLang    = supportedLang.contains(casePreferredLang);
        // Default user survey settings
        String userLangPref   = ENGLISH;
        userLangPref          =  resultspotLang!= false?casePreferredLang:userLangPref;
                        
        //System.Debug('SURVEYS ATTENDED CURRENT MONTH'+CSatSurvey.countSurveyOnCaseByContact(caseRecord.Id, caseRecord.contactId));
        if (CSatSurvey.countSurveyOnCaseByContact(caseRecord.Id, caseRecord.contactId) == 0) { // contact has already not attended the survey for case
              System.Debug('*************PRFFFRED**********'+userLangPref );         
            return languageToSurveyLink.get(userLangPref);
        }            
        return '';  
    }
    
    // 
    public Map<Id,String> getSurveyLinkForClosedCasesByLoggedInContact() {
    
        // return survey link for cases closed by contact if
        //                    Contact is authorized and its asset.purpose is production
        //                    Contact has already not attended survey for the case
        //                    Case is not closed more than 30 days ago  __NEED_TO_ADD_THIS__     
    
        // CONSTANTS
        final String ENGLISH      = 'English';
        final String GERMAN       = 'German';
        final String FRENCH       = 'French';
        final String SPANISH      = 'Spanish';
        final String PORTUGUESE   = 'Portuguese';
        final String JAPANESE     = 'Japanese';
            
        List<User> usrList              = [Select u.ContactId, u.AccountId From User u where Id =: UserInfo.getUserId()];        

        List<Case> closedCasesByContact = [Select ID,ClosedDate,ownerId,Close_Reason__c,createdDate, Csat_Survey_Sent_For_Parent_Case__c, Closed_Less_Than_10_Days_Ago__c, Problem_Type__c,Category__c,EntitlementId,Entitlement.AssetId from Case where IsClosed=true and contactid =:usrList.get(0).ContactId]; // ___NEED_TO_FIX_THIS_ FOR_NO_CONTACTID__AND_ONLY_SELECTED_CASES
        //system.debug('Closed Cases==='+closedCasesByContact);
        // Initialize the caseIdToSurveyLinkMap to be returned by this function
        Map<Id,String> caseIdToSurveyLinkMap = new Map<Id, String>();
        for (Case tempCase:closedCasesByContact) {
            caseIdToSurveyLinkMap.put(tempCase.Id,'false');
            //Bikram added 4998 
            caseAssetErrorMap.put(tempCase.Id,FALSE);            
            if(tempCase.EntitlementId != null && tempCase.Entitlement.AssetID == null){
                caseAssetErrorMap.put(tempCase.Id,TRUE);
            }//Bikram added 4998 ends             
        }

        Boolean isEligibleForSurvey              = false; // Whether Asset is production and contact is authorized
        Map <Id, Boolean> contactIdToEligibility =  CSatSurvey.getContactsToSurveyEligibilityMap(new List<Id>{usrList.get(0).ContactId});
        if (contactIdToEligibility.containsKey(caseRecord.contactId)) {
            isEligibleForSurvey = contactIdToEligibility.get(caseRecord.contactId);
        }  
                
        // Check Whether contact qualifies to get survey link or survey is not active
        if (isEligibleForSurvey == false || (CSatSurveySettings__c.getValues('IsCSatSurveyActive').Survey_Active__c != true)) {
            return caseIdToSurveyLinkMap; // return from here only
        }

        //Bikram 4998
        if(isEligibleForSurvey == null) { assetError = true; }
        

        // Fetch the portalUserprofile for the surveypreferences of the contact
        //List<Community_Profile__c> portalUserProfiles = [Select c.User__r.ContactId, c.Language__c  From Community_Profile__c c where c.User__c =:UserInfo.getUserId()];
        List<Contact> caseCntctPrefLang = [SELECT Id, Preferred_Language__c from contact where id =:caseRecord.ContactId LIMIT 1];
        String casePreferredLang = 'English';
        if(caseCntctPrefLang.size() > 0)casePreferredLang = caseCntctPrefLang[0].Preferred_Language__c;
        // Default user survey settings
        String userLangPref   = ENGLISH;
        //if (portalUserProfiles.size()>0){userLangPref= portalUserProfiles.get(0).Language__c != null?portalUserProfiles.get(0).Language__c:userLangPref;}
        Set<String> supportedLang = new Set<String>{ENGLISH,FRENCH,GERMAN,SPANISH,PORTUGUESE};
        if(System.Label.JapaneseSurveyEnabled == 'Yes')supportedLang.Add(JAPANESE);
        boolean resultspotLang    = supportedLang.contains(casePreferredLang);
        userLangPref          =  resultspotLang != false?casePreferredLang:userLangPref;
        system.debug('***********userLangPref************'+userLangPref);
        Map <String, String> languageToSurveyLink = new Map<String, String> ();
        languageToSurveyLink.put(ENGLISH ,System.Label.CSatSurveyEnglish);
        languageToSurveyLink.put(FRENCH  ,System.Label.CSatSurveyFrench);
        languageToSurveyLink.put(GERMAN  ,System.Label.CSatSurveyGerman);
        languageToSurveyLink.put(SPANISH ,System.Label.CSatSurveySpanish);
        languageToSurveyLink.put(PORTUGUESE ,System.Label.CSatSurveyPortuguese);
        if(System.Label.JapaneseSurveyEnabled == 'Yes')languageToSurveyLink.put(JAPANESE ,System.Label.CSatSurveyJapanese);
        //  Check if feedback already provided by the contact on closed cases
        List<CSatSurveyFeedback__c>     surveyFeedbackOnClosedCasesByContact = CSatSurvey.getSurveyFeedbackByContact(usrList.get(0).ContactId);
        Map <Id, CSatSurveyFeedback__c> caseIdToSurveyFeedbackMap            = new Map<Id, CSatSurveyFeedback__c>();      
        
        for (CSatSurveyFeedback__c csfeedback:surveyFeedbackOnClosedCasesByContact) {
            caseIdToSurveyFeedbackMap.put(csfeedback.case__c, csfeedback); 
        }
        //System.Debug('CSFEEDBACKS'+caseIdToSurveyFeedbackMap);   
        for (Case closedCase:closedCasesByContact) {
           //System.Debug('CLOSEDCASEID'+closedCase.Id);
           //System.Debug('CLOSEDCASEDATE=======>'+closedCase.ClosedDate);
           //valid Close Reasons
           Set<String> validCaseCloseReasons    = new Set<String>{'Resolved','Referred to KB','Referred to Ideas','Referred to Other Group','No Response from Customer'};
           String caseOwnerId                   = closedCase.ownerId;
           if (!caseIdToSurveyFeedbackMap.containsKey(closedCase.Id) 
               && (closedCase.ClosedDate != null) 
               && (closedCase.Csat_Survey_Sent_For_Parent_Case__c == false) 
               && (closedCase.Closed_Less_Than_10_Days_Ago__c == 'Yes') 
               && validCaseCloseReasons.contains(closedCase.Close_Reason__c)
               && !caseOwnerId.startsWith('00G')
               && !((closedCase.Problem_Type__c == 'Configuration/Set Up') && (closedCase.Category__c == 'Configuration Outreach'))
               && closedCase.EntitlementID != null               
               ) { // contact has already not attended the survey for case
                caseIdToSurveyLinkMap.put(closedCase.ID, languageToSurveyLink.get(userLangPref));
                //System.Debug('caseIdToSurveyLinkMap 1'+caseIdToSurveyLinkMap);
           } else {
                caseIdToSurveyLinkMap.put(closedCase.ID, 'false');
                //System.Debug('caseIdToSurveyLinkMap 2'+caseIdToSurveyLinkMap);
           }      
        } 
        return caseIdToSurveyLinkMap;  
    }          
    
    //Bikram 30 May 2013
    public Boolean getCanAddAuthorizedContact()
    {
        //Authorized contact filter rule, can we add this contact as authorized contact? 
        List<User> currUsrContact = [SELECT Id,UserType, AccountID, Contact.AccountId, Contact.Customer_Portal_User__c from user Where AccountId = :accId AND isActive = true AND id=:Userinfo.getUserid()];
        if(currUsrContact == null || currUsrContact.isEmpty()) return false;             
        if(currUsrContact[0].Contact.Customer_Portal_User__c == true && currUsrContact[0].AccountId == currUsrContact[0].Contact.AccountId)
        {   
            List<Entitlement> authEntList = [Select AccountId, of_Allowed_Authorized_Contacts__c, of_Authorized_Contacts__c, OK_to_Add__c From Entitlement a where AccountId = :accId and Asset.Munchkin_Id__c =: currUserMunchkinId and Asset.Munchkin_Id__c != null and Status = 'Active'];
            if(authEntList == null || authEntList.isEmpty())                 
                return false;
            if(authEntList[0].of_Allowed_Authorized_Contacts__c > authEntList[0].of_Authorized_Contacts__c && authEntList[0].OK_to_Add__c == true)        
                return true;                         
            /*
            List<Authorized_Contact__c> authConList = [Select a.Entitlement__r.AccountId, a.Entitlement__r.of_Allowed_Authorized_Contacts__c, a.Entitlement__r.of_Authorized_Contacts__c, a.Entitlement__r.OK_to_Add__c, a.Entitlement__c, a.Customer_Admin__c, a.Contact__r.Name, a.Contact__c, a.Contact__r.Email From Authorized_Contact__c a where Entitlement__r.AccountId = :accId and Entitlement__r.Asset.Munchkin_Id__c =: currUserMunchkinId and Entitlement__r.Status = 'Active'];
            if(authConList == null || authConList.isEmpty()){ return false; }
            if(authConList[0].Entitlement__r.of_Allowed_Authorized_Contacts__c > authConList[0].Entitlement__r.of_Authorized_Contacts__c && authConList[0].Entitlement__r.OK_to_Add__c == true)        
                return true;
            */
        }
        return false;            
    }
    
    public pageReference autoAddAuthorizedContact()
    {
        addAuthUsrError = false;
        System.debug('<==autoAddAuthorizedContact==>');
        if(getCanAddAuthorizedContact())
        {
            List<Authorized_Contact__c> authConList = [Select a.Entitlement__r.AccountId, a.Contact__r.Name, a.Contact__c, a.Contact__r.Email From Authorized_Contact__c a where Entitlement__r.AccountId = :accId and Entitlement__r.Asset.Munchkin_Id__c =: currUserMunchkinId AND Entitlement__r.Status = 'Active'];
            Authorized_Contact__c newAuthContact = new Authorized_Contact__c();
            try {
                List<Entitlement> myEntitlements = [select id, Name, AccountId from Entitlement where AccountId = :accId AND AssetId =:usrAssetID and Asset.Munchkin_Id__c =: currUserMunchkinId AND Status = 'Active'];
                if(myEntitlements.isEmpty()) {
                    addAuthUsrError = true;
                    ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, 'No entitlement found for this contact.'));
                    return null;
                } else {
                    System.debug('<==Add new user==>' + usrContactId);
                    newAuthContact.Contact__c = usrContactId;
                    newAuthContact.Entitlement__c = myEntitlements[0].Id;
                    insert newAuthContact;                
                    PageReference pgRef = Page.Case_Create_Page;
                    pgRef.setRedirect(true);
                    return pgRef;
                }    
            } catch(Exception e) {
                ApexPages.addMessages(e);
                addAuthUsrError = true;
                return null;
            }               
        }
        return null;    
    }                

    public PageReference  reLoadPanel() 
    {
        caseonBehalf = ApexPages.currentPage().getParameters().get('firstParam');
        system.debug('caseOnBehalf Called + isUnauthorizedInternalUser==>' + caseOnBehalf + ' ' + isUnauthorizedInternalUser);
        return null;
    }
          
}