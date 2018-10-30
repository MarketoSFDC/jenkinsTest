public class HiddenP1ServiceRestoredController{
    Id caseId;
    String isInConsole;
    PageReference goBackTo;
            
    public HiddenP1ServiceRestoredController(){
        caseId      = ApexPages.currentPage().getParameters().get('caseId');
        isInConsole = ApexPages.currentPage().getParameters().get('inConsole');
        
        System.Debug('__Location Of Case__'+isInConsole);
        System.Debug('__Id Of Case__'+caseId);
    }
    public pageReference timeSetterForCaseField(){
        Case caseToBeUpdated                              = new Case(Id=caseId);
        Case currentCase                                  = [Select CreatedDate,IsClosed,ClosedDate,P1_Service_Restored_Time__c from Case 
                                                                where Id =: caseId];
                                                                
        System.Debug('Closed Status'+currentCase.IsClosed);
        List<CaseHistory> historyOfCase                   = [Select CreatedDate, NewValue From CaseHistory Where 
                                                                Field = 'Priority' and 
                                                                CaseId =: caseId 
                                                                ORDER BY CreatedDate DESC];
        If(! currentCase.isClosed){
            caseToBeUpdated.P1_Service_Restored_Time__c       = System.now();    
            System.Debug('__P1 Service Restored Time__'+caseToBeUpdated.P1_Service_Restored_Time__c);
            // Enter If Case was switched to P1 after case creation but it was not created with priority P1.
            if(historyOfCase.size() > 0){        
                if( historyOfCase[0].NewValue == 'P1'){
                    caseToBeUpdated.P1_Switch_Time__c         = historyOfCase[0].CreatedDate;
                }  
            //Enter If Case was created with priority P1 itsel.             
            }else{
                caseToBeUpdated.P1_Switch_Time__c = currentCase.CreatedDate;    
            }
            update caseToBeUpdated;
        }
        If(isInConsole == 'yes'){
            goBackTo                      = new PageReference('/ui/support/servicedesk/ServiceDeskPage?tsid=02u50000000doVh');
        }else{
            goBackTo                      = new PageReference('/'+caseId+'?id='+ApexPages.currentPage().getParameters().get('CaseId')+'&nooverride=0');
        }
        return goBackTo;
    }
    @isTest( SeeAllData=True )
    public static void testHiddenP1ServiceRestoredController(){
        test.startTest();
        List<Case> testCase = [Select id from Case Limit 1];
        PageReference testRef = new PageReference('/'+testCase[0].Id+'?id='+testCase[0].Id+'&nooverride=0');
        test.setCurrentpage(testRef);
        ApexPages.currentPage().getParameters().put('caseId',testCase[0].Id);
        HiddenP1ServiceRestoredController testObj = new HiddenP1ServiceRestoredController();
        pageReference testPgRef = testObj.timeSetterForCaseField(); 
        test.stopTest();   
    }
}