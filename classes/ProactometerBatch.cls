global class ProactometerBatch implements Database.Batchable<sObject> {
   
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = Label.ProactoCaseQuery;
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<Proactive_Data__c> proactiveDataList = new List<Proactive_Data__c>();
          List<Proactive_Data__c> existingProactiveData = new List<Proactive_Data__c>();
        List<Proactive_Activities__c > activitiesDataList = new List<Proactive_Activities__c>();
        List<Proactive_Activities__c > OldDataList = new List<Proactive_Activities__c>();
        
        Map<Id,List<Case>> caseMap = new Map<Id,List<Case>>();
        Map<Id,Id> contEntMap = new Map<Id,Id>();
        Map<Id,String> contDmlMap = new Map<Id,String>();
        
        for(Case cse : scope){
            contEntMap.put(cse.contactId,cse.entitlementId);
            if(!caseMap.ContainsKey(cse.contactId)){
                List<Case> cseList = new List<Case>();
                cseList.add(cse);
                caseMap.put(cse.contactId,cseList);
            }
            else{
                caseMap.get(cse.contactId).add(cse);
            }
        }
        
        /*************************************  Check For Existing Records   ************************************************************/
        for(Proactive_Data__c pro: [Select Id,contact__c,Entitlement__c from Proactive_Data__c limit 5000]){
            existingProactiveData.add(pro);
            if(!contEntMap.containsKey(pro.contact__c)){ // when new contact came
                contDmlMap.put(pro.contact__C,null);
            }
            else if(contEntMap.containsKey(pro.contact__c) && contEntMap.get(pro.contact__c) != pro.Entitlement__c){// old contact but ent changed
                contDmlMap.put(pro.contact__c,pro.Id);
            }
        }         
        for(Authorized_Contact__c auth : [SELECT id,contact__c,Entitlement__c,Entitlement__r.type from Authorized_Contact__c where Entitlement__r.type IN ('Elite','Premier','Premier Plus') and Entitlement__r.status = 'active' and contact__c In :contEntMap.keySet()]){
            if(!contDmlMap.containsKey(auth.contact__c)){
                Proactive_Data__c pro = new Proactive_Data__c();
                pro.contact__c = auth.contact__c;
                pro.entitlement__c = auth.entitlement__c;
                proactiveDataList.add(pro);
            }
            else if(contDmlMap.containsKey(auth.contact__c) && contDmlMap.get(auth.contact__c) != null){
                Proactive_Data__c pro = new Proactive_Data__c(id = contDmlMap.get(auth.contact__c),entitlement__c = auth.Entitlement__c);
                proactiveDataList.add(pro);
            }
        }
        /*******************  Insert Parent Proactive Data Records  ***********************************************/
        if(proactiveDataList.isEmpty() == False && proactiveDataList.Size() > 0){
            upsert proactiveDataList;
            existingProactiveData.addAll(proactiveDataList);
        }
        
 
        /*******************  Inserting Child Activities Records  ***************************************************/
        if(existingProactiveData != null){
            for(Proactive_Data__c pac : existingProactiveData ){
                if(caseMap.ContainsKey(pac.contact__c)){
                    for(Case cse : caseMap.get(pac.contact__c)){
                        Proactive_Activities__c pa = new Proactive_Activities__c(); 
                        pa.case__c = cse.Id;
                        pa.Case_Category__c= cse.category__c;
                        pa.Proactive_Data__c = pac.Id;
                        pa.isEligibleActivity__c = true;
                        activitiesDataList.add(pa);
                    }
                }
            }
        }
        if(activitiesDataList != null && activitiesDataList.Size() > 0) insert activitiesDataList;
        
        /*****************************  Updating Old Activities *********************************************************************/
        for(Proactive_Activities__c pro : [Select id,isEligibleActivity__c From Proactive_Activities__c Where CreatedDate > LAST_90_DAYS and isEligibleActivity__c = true]){
                pro.isEligibleActivity__c = False;
                OldDataList.add(pro);
        }
        if(OldDataList.isEmpty() == False && OldDataList.Size() > 0) update OldDataList;
     }   
     
    global void finish(Database.BatchableContext BC) {
        
  }
}