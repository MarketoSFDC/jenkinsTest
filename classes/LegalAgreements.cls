public class LegalAgreements {
    
    private static Boolean executed = false;
    
    /**************
Private Methods
***************/
    /*private static boolean triggersEnabled() {
        Legal_Agreements_Settings__c settings = Legal_Agreements_Settings__c.getInstance();     
        return settings.Triggers_Enabled__c;
    }*/
    
    private static void onAfterInsert(Map<Id,Legal_Agreements__c> newLegalAgreementsMap, Map<Id,Legal_Agreements__c> oldLegalAgreementsMap) {
        LegalAgreementsService.processManagedClausesForLegalAgreements(newLegalAgreementsMap, oldLegalAgreementsMap);       
    }
    
    private static void onAfterUpdate(Map<Id,Legal_Agreements__c> newLegalAgreementsMap, Map<Id,Legal_Agreements__c> oldLegalAgreementsMap) {
        LegalAgreementsService.processManagedClausesForLegalAgreements(newLegalAgreementsMap, oldLegalAgreementsMap);
    }
    
    private static void onBeforeDelete(Map<Id,Legal_Agreements__c> oldLegalAgreementsMap) {
        LegalAgreementsService.deleteManagedClauses(oldLegalAgreementsMap.keySet());
    }
    
    /*************
Public Methods
**************/
    public static void onTrigger(Map<Id,Legal_Agreements__c> newLegalAgreementsMap, Map<Id,Legal_Agreements__c> oldLegalAgreementsMap) {
        if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Legal_Agreement_Triggers__c)){
            
            System.debug('Triggers Enabled');
            if(executed) return;
            executed = true;    
            
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    onAfterInsert(newLegalAgreementsMap, oldLegalAgreementsMap);
                }
                else if (Trigger.isUpdate) {
                    onAfterUpdate(newLegalAgreementsMap, oldLegalAgreementsMap);
                }
            }
            else if (Trigger.isBefore) {
                if (Trigger.isDelete) {
                    onBeforeDelete(oldLegalAgreementsMap);
                }
            }
            
            executed = false;
        }
    }
}