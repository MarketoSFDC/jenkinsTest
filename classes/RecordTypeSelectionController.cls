/* Name: RecordTypeSelectionController
     Description : Controller for RecordTypeSelectionComponent_LEX component
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
public class RecordTypeSelectionController {
    
    public Case caseRecord{get;set;}
    public static Map<Id, String> recordtypemap {get;set;}
    
   @AuraEnabled        
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        
        for(RecordTypeInfo rt : recordtypes){
            //Check the availability of recordtype for the respective users
            if(rt.isAvailable()){
            
                if(rt.getName() != 'Master')
                recordtypemap.put(rt.getRecordTypeId(), rt.getName());
            }
        }        
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
       // system.debug('===recordTypeLabel======'+recordTypeLabel);
        Id recid = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();
       // system.debug('===recid======'+recid);
        return recid;
    }
    @AuraEnabled
    
    public Static Case fetchCaseRecordDetail(Id caseId)
    {
        //system.debug('=caseId=='+caseId);
        return  [Select Id,CaseNumber,AccountId,ContactId From Case Where Id =: caseId ];
    }

}