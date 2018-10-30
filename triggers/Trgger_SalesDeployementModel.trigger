trigger Trgger_SalesDeployementModel on Sales_Deployment_Model__c (after insert) {
    
    Map<String, String> newSMDWithOldSMDMap = new Map<String, String>();
    for(Sales_Deployment_Model__c sdm : trigger.new){
        if(sdm.Previous_Sales_Deployment_Model__c != null){
            string prev_sdmId = sdm.Previous_Sales_Deployment_Model__c;
            if(prev_sdmId.length()>15) prev_sdmId = prev_sdmId.subString(0, prev_sdmId.length()-3);
            newSMDWithOldSMDMap.put(prev_sdmId, sdm.Id);    
        }
    }
    
    if(newSMDWithOldSMDMap.isEmpty()) return;
    
    string montlySDMQueryString   = SalesDeploymentModelTriggerHelper.getMonthlySDMObjectFields();
    montlySDMQueryString = montlySDMQueryString.Substring(0,montlySDMQueryString.length()-1);
    Map<String, List<Monthly_Data_for_SDM__c>> monthlydataOfSalesDepModel = new Map<String, List<Monthly_Data_for_SDM__c>>();
    List<Monthly_Data_for_SDM__c> montlySdmRecordsToBeCloned = new List<Monthly_Data_for_SDM__c>();
    system.debug('SELECT Id,'+'(Select ' + montlySDMQueryString + ' From Monthly_Data_for_SDM__r ) '+'FROM Sales_Deployment_Model__c Where Id IN: newSMDWithOldSMDMap.keySet()');
    Set<String> parentIds = new Set<String>(newSMDWithOldSMDMap.keySet());
    for(Sales_Deployment_Model__c sdm : DataBase.query('SELECT Id, '+ '(Select ' + montlySDMQueryString + ' From Monthly_Data_for_SDM__r )'+' FROM Sales_Deployment_Model__c Where Id IN:parentIds')){
        for(Monthly_Data_for_SDM__c montlhly_record : sdm.Monthly_Data_for_SDM__r.deepClone()){
            string sdmId = sdm.Id;
            if(sdmId.length()>15) sdmId = sdmId .subString(0, sdmId.length()-3);
            system.debug(newSMDWithOldSMDMap.get(sdm.Id)+'=='+sdmId+'=='+newSMDWithOldSMDMap);
            montlhly_record.SDM_Record__c = newSMDWithOldSMDMap.get(sdmId);
            montlySdmRecordsToBeCloned.add(montlhly_record);
        }
    }
    
    try{        
        if(!montlySdmRecordsToBeCloned.isEmpty()){
            insert montlySdmRecordsToBeCloned;
        }        
    }catch(Exception e){
        
    }     

}