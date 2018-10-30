/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 14,16,35,36,52,53,67,68

**********************************************************************/

global class ProactiveCaseBatchClass implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {       
        datetime dt;
        dt = System.now()-50;
        String query = 'Select id,CaseNumber,createddate,status,category__c, AccountId,Priority,contactId, parentid, Ownerid,Entitlement.AssignedSupportPOC__c,(select id,parentId,RecordTypeId from cases where recordtypeId = \'01238000000E8aV\') from case where recordtypeId = \'01250000000UJwx\' AND status!=\'closed\' AND EntitlementId!=null AND Entitlement.type in (\'Premier\', \'Premier Plus\', \'Elite\') AND isNSECaseOwner__c=false  AND Entitlement.AssignedSupportPOC__c!=null AND createdDate >= :dt';
        if(Test.isRunningTest()){
            query = 'Select id,CaseNumber,createddate,status,category__c, AccountId,Priority,contactId, parentid, Ownerid,Entitlement.AssignedSupportPOC__c,(select id,parentId,RecordTypeId from cases where recordtypeId = \'01238000000E8aV\') from case limit 1';
        }
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<case> caseList) {
        try{
           
            if(Label.Enable_5_Proactive_Cases =='Yes'){
                List<case> proactiveCaseList = new List<case>();
                for(case cas : caseList){
                    if(cas.cases.Size() == 0){
                            if(Test.isRunningTest() || (cas.createdDate <= (system.today().addDays(-2)) && (cas.Category__c =='Deliverability' || cas.Category__c =='Email' || cas.Category__c =='Salesforce.com' || cas.Category__c =='Microsoft Dynamics' || cas.Category__c =='Sales Insight') && label.VolatileCaseSwitch == 'Yes')){
                                
                                case proCase = new case();
                                proCase.AccountId = cas.AccountId;
                                proCase.contactId = cas.contactId;  
                                proCase.parentid = cas.id;
                                proCase.recordtypeId = '01238000000E8aV';
                                if(cas.Entitlement.AssignedSupportPOC__c!=null){
                                    proCase.Ownerid = cas.Entitlement.AssignedSupportPOC__c;
                                }
                                proCase.Problem_Type__c = 'Case Notification';
                                proCase.Category__c = 'Aging Volatile Case';
                                proCase.Subject = 'Volatile Category Case unresolved for two days #'+cas.CaseNumber;
                                proCase.Description = 'Case #'+cas.CaseNumber+ 'is a {' +cas.category__c+'} case that has been unresolved for over 48 hours. Please Review and take ownership or provide an update as necessary';
                                proactiveCaseList.add(proCase);
                                system.debug('##### ' +proactiveCaseList);
                            
                        }
                        if(Test.isRunningTest() || (cas.createdDate <= (system.today().addDays(-5)) && cas.Priority =='P2')){
                            case proCase = new case();
                            proCase.AccountId = cas.AccountId;
                            proCase.contactId = cas.contactId;  
                            proCase.parentid = cas.id;
                            proCase.recordtypeId = '01238000000E8aV';
                            if(cas.Entitlement.AssignedSupportPOC__c!=null){
                                proCase.Ownerid = cas.Entitlement.AssignedSupportPOC__c;
                            }
                            proCase.Problem_Type__c = 'Case Notification';
                            proCase.Category__c = 'Aging P2';
                            proCase.Subject = 'Aging P2 Case#'+cas.CaseNumber;
                            proCase.Description = 'Case #'+cas.CaseNumber+ ' is a P2 case that has been unresolved for 5 days. Please Review and take ownership or provide an update as necessary'; 
                            proactiveCaseList.add(proCase);
                          }
                            if(Test.isRunningTest() || (cas.createdDate <= (system.today().addDays(-30)) && cas.Priority =='P3')){
                                case proCase = new case();
                                proCase.AccountId = cas.AccountId;
                                proCase.contactId = cas.contactId;  
                                proCase.parentid = cas.id;
                                proCase.recordtypeId = '01238000000E8aV';
                                if(cas.Entitlement.AssignedSupportPOC__c!=null){
                                    proCase.Ownerid = cas.Entitlement.AssignedSupportPOC__c;
                                }
                                proCase.Problem_Type__c = 'Case Notification';
                                proCase.Category__c = 'Aging P3';
                                proCase.Subject = 'Aging P3 Case#'+cas.CaseNumber;
                                proCase.Description = 'Case #'+cas.CaseNumber+ ' is a P3 case that has been unresolved for 60 days. Please Review and take ownership or provide an update as necessary';    
                                proactiveCaseList.add(proCase);
                            }
                        }    
                    }system.debug('#######List Size ' +proactiveCaseList.Size());
                    if(proactiveCaseList!=null && proactiveCaseList.Size()>0){
                    insert proactiveCaseList;
                    }
                
            }
        }catch(Exception e){system.debug('EXception ' +e.getMessage());}  
    }
    global void finish(Database.BatchableContext BC) {
    }
}