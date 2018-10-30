public class GetUsersBasedOnRoleHeirarchyCtrl{
    public Boolean showButton{get;set;}
    public Boolean showHeaderAndSideBar{get;set;}
    public Boolean showUserList{get;set;}
    private String state = '';
    private Id userId;
    public List<Manger_Activity_Log__c> finalManActLogList{get;set;} 
    public Map<Id,User> userIdToUserMap{get;set;} 
    public string baseUrl{get;set;}
    public Map<Id,String> tseToEvaluationStatus{get;set;}

    public void setstate(String n) {
        state = n;
    }
            
    public String getstate() {
        return state;
    }
    
    public void setUserId(Id n) {
        userId = n;
    }
            
    public Id getUserId() {
        return userId;
    }
   
    public PageReference methodOne() {
        showButton = true;
        List<User> tempUser = [Select Name from User where Id =:getUserId() Limit 1];
        state = tempUser[0].Name;
        return null;
    }
    
    public pagereference PerformReview(){
        If(getstate() =='' || getstate() == Null)return null;
        //List<Manger_Activity_Log__c> tempMangerActivityLogList = [Select Id, Evaluation_Ended__c from Manger_Activity_Log__c where SupportManager__c =: UserInfo.getUserId() AND TseName__c=:getUserId() LIMIT 1]; 
        List<Manger_Activity_Log__c> tempMangerActivityLogList = [Select Id, Evaluation_Ended__c from Manger_Activity_Log__c where SupportManager__c =: UserInfo.getUserId()  AND TseName__c=:getUserId()]; 
        
        tempMangerActivityLogList[0].Status__C = 'In Progress';
        update tempMangerActivityLogList[0];
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/CaseEvaluationV1?userId='+getUserId()+'&userName='+getstate()+'&activityLogId='+tempMangerActivityLogList[0].Id;        
        PageReference pageRef = new PageReference(baseUrl);    
        return pageRef; 
    }
    
    public pageReference runQuery(){
        String query = getState();   
        //showHeaderAndSideBar = URL.getCurrentRequestUrl().toExternalForm().contains('sfdcIFrameOrigin') ? False : True;     
        System.Debug('____showHeaderAndSideBar____'+showHeaderAndSideBar );
        List<User> usersUnderHeirarchy = [Select Id, Name from User Where ManagerId =: UserInfo.getUserId() and isPortalEnabled = false and isActive=True and Name LIKE :'%'+query+'%'];
        
        //List<User> usersUnderHeirarchy = [Select Id, Name, UserRoleId,  isPortalEnabled from User Where UserRoleId IN: setOfRoleIdsUnderMyRole and isPortalEnabled = false and isActive=True and Name LIKE :'%'+query+'%'];   
        userIdToUserMap = new Map<Id,User>();
        
        for(User tempUser : usersUnderHeirarchy){
            userIdToUserMap.put(tempUser.Id, tempUser);
        }
        
        System.Debug('_________userIdToUserMap________'+userIdToUserMap);
        List<Id> uniqueTSEId = new List<Id>();
        
        for(User tempUser : usersUnderHeirarchy){
            uniqueTSEId.add(tempUser.Id);
        }
        
        //TSE for whom there is already an entry made in Manger Activity Log Object
        finalManActLogList = [Select Id, Survey_Filled__c, Notification_Countdown_Enabled__c, Activity_Log_Status__c, Evaluation_Ended__c, Evaluation_Started__c, TseName__c, TseName__r.Name, Status__c from Manger_Activity_Log__c where TseName__c IN : uniqueTSEId and SupportManager__c =: UserInfo.getUserId()];
        //TSE for whom there is already an entry made in Manger Activity Log Object
        
        return null;
    }
}