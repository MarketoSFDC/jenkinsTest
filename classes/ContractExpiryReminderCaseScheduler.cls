/*
 * This class needs to be scheduled in order for it to run.
 *
 * The following code can be executed anonymously via the
 * System Log to schedule this class to run:
 *
 * // Run Everday at 4AM.
 * System.Schedule('Case d Contracto',  '0 0 4 ? * *', new ContractExpiryReminderCaseScheduler());
 *
 * // Run on demand.
 * ContractExpiryReminderCaseScheduler schedulable = new ContractExpiryReminderCaseScheduler ();
 * schedulable.execute(null);
 */
 
 /*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 35,64,65,76,77

**********************************************************************/
global class ContractExpiryReminderCaseScheduler implements Schedulable {    
    global void execute(SchedulableContext context) {
        insertNewCases();
    }    
    global List<Case> insertNewCases() {    
        Date currDate=Date.Today();     
        System.debug('currDate:' + currDate);
        Set<Id> selectedEntitlements = new Set<Id>();
        //stage recordTypeID = '012W00000008qrC';                         
        Id proactiveCaseRecord = '01238000000E8aVAAS'; 
        Id premierQueueId = '00G50000001Qtj6EAC';
        List<Case> newCases = new List<Case>();
        Set<Id> premierEntitlements = new Set<Id>();        
        for(Entitlement tmpEnt : [SELECT Id,StartDate,account.Temperature__c,AssetId, Type, AssignedSupportPOC__c,AssignedSupportPOC__r.IsActive,(SELECT Contact__c, Contact__r.AccountId, Contact__r.Account.Name FROM Authorized_Contacts__r WHERE Customer_Admin__c = True Limit 1) FROM Entitlement WHERE Status = 'Active' AND Type in ('Premier Plus', 'Premier', 'Elite', 'Microsoft','UPS' ,'Premier Support US')]) {
            List<Authorized_Contact__c> tmpACn = tmpEnt.Authorized_Contacts__r;
            if(tmpACn != NULL && tmpACn.isEmpty() == FALSE) {
                Boolean contractValidFor = false; Integer monthIncrementor = 6;            
                Date entStartDate = tmpEnt.StartDate;
                Date tmpStDate = tmpEnt.StartDate;
                system.debug(tmpStDate);                
                if(tmpEnt.Type == 'Elite' || tmpEnt.Type == 'UPS' || tmpEnt.Type == 'Microsoft') monthIncrementor = 3;       
                while(tmpStDate <= currDate) {
                    if(tmpStDate == currDate && entStartDate != currDate) {
                        contractValidFor = true;
                        break;
                    } tmpStDate = tmpStDate.addMonths(monthIncrementor);
                }
                System.Debug('contractValidFor==> '+ contractValidFor + ' Dates : ' + tmpStDate  + ' '  + entStartDate);                
                if(contractValidFor){
                    String tmpAccountId =  tmpACn[0].Contact__r.accountId;
                    String tmpContactId =  tmpACn[0].Contact__c;            
                    Case cs = new Case(AccountId=tmpAccountId,ContactId = tmpContactId, Problem_Type__c = 'Support Review', RecordTypeId=proactiveCaseRecord, Origin='Proactive');
                    //Database.DMLOptions dmlOpts = new Database.DMLOptions();dmlOpts.assignmentRuleHeader.useDefaultRule = true;cs.setOptions(dmlOpts);                
                    if(monthIncrementor == 3) {
                        cs.Subject = tmpACn[0].Contact__r.Account.Name + ' Quarterly Review.'; 
                        cs.Description = tmpACn[0].Contact__r.Account.Name + '  is due for a quarterly review.';
                        cs.Category__c = 'Quarterly Review';
                    } else {
                            if(tmpEnt.Account.Temperature__c == 'Red'){
                                cs.Subject = '**ACTION REQUIRED**'+ tmpACn[0].Contact__r.Account.Name + ' Half Yearly Review'; 
                                cs.Description = tmpACn[0].Contact__r.Account.Name+ ' is a red account and requires a 6-month review. Please Coordinate an outreach with their CAM';
                                cs.Category__c = 'Half-Yearly Review'; 
                                if(tmpEnt.AssignedSupportPOC__c != NULL && tmpEnt.AssignedSupportPOC__r.IsActive) {
                                    cs.OwnerId = tmpEnt.AssignedSupportPOC__c;
                                }  
                            }
                            if(tmpEnt.Account.Temperature__c != 'Red'){
                                cs.Subject = tmpACn[0].Contact__r.Account.Name + ' Half Yearly Review'; 
                                cs.Description = 'An email reminder about an upcoming half-yearly review was sent to the authorized contacts of ' +tmpACn[0].Contact__r.Account.Name;
                                cs.Category__c = 'Half-Yearly Review';
                                cs.status = 'Closed';
                                cs.OwnerId = Label.ProActiveUserId;      // proactive User. 
                            } 
                    }
                    if(monthIncrementor == 3 && tmpEnt.AssignedSupportPOC__c != NULL && tmpEnt.AssignedSupportPOC__r.IsActive) {
                        cs.OwnerId =  tmpEnt.AssignedSupportPOC__c;//Elite
                    }
                      else if(monthIncrementor != 6) {
                        cs.OwnerId = premierQueueId;//Queue
                        cs.Description += 'Please Create a new case for the customer to arrange for a service review, or get confirmation from the customer that they will not need one.\n A few things to remember \n Put the case number of the new case in the "Parent Case" field of this case. Update this case with a note when the review is either completed or when the customer declines the review.\n ';                        
                        cs.Description += URL.getSalesforceBaseUrl().toExternalForm()+'/'+tmpAccountId;
                    } 
                     cs.EntitlementId = tmpEnt.Id;
                    newCases.add(cs); 
                }
            }
        }
        if(newCases != null && newCases.size() > 0){
            insert newCases; 
        }
        return newCases;        
    }    
}