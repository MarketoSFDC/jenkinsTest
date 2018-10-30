public class SalesDeploymentModelTriggerHelper{

    public static String getMonthlySDMObjectFields(){
        string monthlySDMQueryString = '';
        for(String oppField : Monthly_Data_for_SDM__c.getSobjectType().getDescribe().fields.getMap().KeySet()) {
            monthlySDMQueryString += oppField + ',';
        }
        return monthlySDMQueryString;
    }
    
    @isTest
    public static void Trgger_SalesDeployementModel() {
        Sales_Deployment_Model__c sdm = new Sales_Deployment_Model__c (
                                            Name= 'Test SDM',
                                            SDM_Plan_Start_Date__c = Date.Today()
                                        );
        insert sdm;
        Monthly_Data_for_SDM__c mds = new Monthly_Data_for_SDM__c (
                                          Name          = 'test-child-sdm',
                                          SDM_Record__c = sdm.Id
                                       );
        insert mds;
                                        
        Sales_Deployment_Model__c sdmClone = new Sales_Deployment_Model__c (
                                                Name= 'Test SDM-Clone',
                                                SDM_Plan_Start_Date__c = Date.Today(),
                                                Previous_Sales_Deployment_Model__c = sdm.Id
                                            );
        insert sdmClone;
    }
    
}