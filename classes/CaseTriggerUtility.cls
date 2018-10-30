/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 24,31-36

**********************************************************************/
public class CaseTriggerUtility{
    public static boolean AutoCloseMilestoneOnCaseCloseisBeforeUpdate = false;
    public static boolean AutoCloseMilestoneOnCaseCloseisAfterUpdate  = false;
    public static boolean queueOwnedCaseCloseCheckisBeforeUpdate      = false;
    public static boolean UpdateBusinessHoursisBeforeUpdate           = false; 
    public static boolean attendedBVRewards                           = false;   
    public static boolean caseCreateOnBehalfOfCust                    = false;
    public static boolean NotifyTechSuppOrNamedSuppSwitch             = false;
    public static boolean GainsightCaseTriggerSwitch                  = false;
    public static boolean firstRunInUpdateSalesCase                   = true;
    public static boolean ForwardEmailToCaseValidatorReopenControl    = true; 

    public static void emailToNamSupEngOrTechAcctMan(List<Case> targetCases, List<Id> entitlementIds) {
        System.Debug('I AM IN MAILER CODE');
        System.Debug('________targetCases_________'+targetCases);
        System.Debug('________entitlementIds_________'+entitlementIds);
        Map<Id,Entitlement> entitlmentIdToEntitlement = new Map<Id,Entitlement>([Select Id, Type, AssignedSupportPOC__c from Entitlement Where Id IN : entitlementIds]);
        EmailTemplate emailTemplateTechnAccMan  = [Select id from EmailTemplate where name = 'P1 Notification To Manager'];
        EmailTemplate emailTemplateNamSuppEngi  = [Select id from EmailTemplate where name = 'P1 Notification To Named Support Engineer'];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress where displayname='Marketo Customer Support'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            for (Case caseItr : targetCases) {
                Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
                Id tempIdSuppEngineerOrTechAccMan;
                If(entitlmentIdToEntitlement.get(caseItr.EntitlementId).Type == 'Elite' && entitlmentIdToEntitlement.ContainsKey(caseItr.EntitlementId) && entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c != Null){
                    tempIdSuppEngineerOrTechAccMan = entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c;
                    message.setTemplateId(emailTemplateTechnAccMan.Id);
                }else If(entitlmentIdToEntitlement.get(caseItr.EntitlementId).Type == 'Premier' && entitlmentIdToEntitlement.ContainsKey(caseItr.EntitlementId) && entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c != Null){
                    tempIdSuppEngineerOrTechAccMan = entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c;
                    message.setTemplateId(emailTemplateNamSuppEngi.Id);
                    System.Debug('________tempIdSuppEngineerOrTechAccMan______'+tempIdSuppEngineerOrTechAccMan);
                }
                System.Debug('________tempIdSuppEngineerOrTechAccMan______'+tempIdSuppEngineerOrTechAccMan);
                message.setTargetObjectId(tempIdSuppEngineerOrTechAccMan);
                message.setOrgWideEmailAddressId(owa.id);
                message.setWhatId(caseItr.Id);
                message.setSaveAsActivity(false);
                allmsg.add(message);
            }
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('mailResult'+mailResult);
        System.Debug('entitlmentIdToEntitlement'+entitlmentIdToEntitlement);
    }  
    
    public static Boolean isValidRecordTypeId(Id recordTypeId){
        Set<Id> recordTypeIdToBeIgnored = new Set<Id>();
        /*List<RecordType> ignoreRecordTypeIds = [Select Id from RecordType where Name = 'Situation Management - Support Feedback' OR Name = 'Situation Management - Support' OR Name = 'Situation Management - Services' OR Name = 'Sales Cases' OR Name = 'Legal Cases'];    
        for (RecordType temprecordTypeIds : ignoreRecordTypeIds){
            recordTypeIdToBeIgnored.add(temprecordTypeIds.Id);
        }*/
        recordTypeIdToBeIgnored.add('01250000000UK1EAAW');      
        recordTypeIdToBeIgnored.add('01250000000UKa9AAG');
        recordTypeIdToBeIgnored.add('01250000000UKpsAAG');
        recordTypeIdToBeIgnored.add('01250000000URtXAAW');
        recordTypeIdToBeIgnored.add('01250000000USEVAA4');
        Boolean finalResult = recordTypeIdToBeIgnored.Contains(recordTypeId)?false:true;
        return finalResult;
    }
    
    public static string returnCaseRecordTypeId(String recordTypeName){
       string recordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
       return recordTypeId;
    }
}