Public Class CSatAdminPanelController{
    Public String RollingMonthOne{get;set;}
   
    Public String SatisPercMonthOne{get;set;}  
    Public CSatAdminPanelData__c CSatAdminPanel{get;set;}
    
    public CSatAdminPanelController() {        
            init();
    }
    Public PageReference Save(){
        PageReference pageRef = null;
        try {
            doDelete(); 
            CSatAdminPanel = new CSatAdminPanelData__c();
            CSatAdminPanel.Month__c = RollingMonthOne;
            CSatAdminPanel.CSatPercentage__c = SatisPercMonthOne;
            insert CSatAdminPanel;
            Init();
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        } 
        Return null;
    
    }
    
    Private PageReference doDelete(){
        try {
            List<CSatAdminPanelData__c> deletionAdminDataList = [Select id From CSatAdminPanelData__c LIMIT 1];
            If (deletionAdminDataList.size()>0){
                delete deletionAdminDataList;
            }
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        } 
        Return null; 
    }
    
    private void init() {
        try {
            List<CSatAdminPanelData__c> AdminDataList = [Select Month__c,CSatPercentage__c  From CSatAdminPanelData__c LIMIT 1];
            If (AdminDataList.size()>0){
               RollingMonthOne = AdminDataList[0].Month__c;
               SatisPercMonthOne = AdminDataList[0].CSatPercentage__c ;
            }
        }
        catch(Exception e) {
            ApexPages.addMessages(e);
        }    
    }
    
   
    public static testMethod void testCSatAdminPanelController() {        
        CSatAdminPanelController controller = new CSatAdminPanelController();        
        controller.RollingMonthOne = 'March';
        controller.SatisPercMonthOne = '81';
        controller.init();
        controller.save();
        controller.dodelete();
    }
}