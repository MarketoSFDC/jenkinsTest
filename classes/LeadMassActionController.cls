public class LeadMassActionController {

    public Lead lead {get;set;}
    String buttonInfo;
    Set<String> leadIds= new Set<String>();
    PageReference returnUrl = null;
    public LeadMassActionController() {       
        lead = new Lead();
        lead.Touch_Stage__c = 'Untouched';
        buttonInfo = ApexPages.currentPage().getParameters().get('LeadMassTask');
        leadIds.addAll(ApexPages.currentPage().getParameters().get('key').split(','));        
        returnUrl = new PageReference(ApexPages.currentPage().getParameters().get('retUrl'));
    } 
     
    public PageReference save(){
        
        List<Lead> leads = new List<Lead>([SELECT Touch_Stage__c,Status,Recycled_Reason__c FROM Lead WHERE Id IN : leadIds]);
        system.debug(buttonInfo);
        if(buttonInfo == 'LEAD_CHANGE_TOUCH_STAGE'){
            for(Lead ld : leads){
                ld.Touch_Stage__c = lead.Touch_Stage__c ;
                system.debug(ld);
            }
        }
        else if(buttonInfo == 'LEAD_Recycle_Lead'){
            for(Lead ld : leads){
                ld.Status= lead.Status;
                ld.Recycled_Reason__c = lead.Recycled_Reason__c;
                system.debug(ld);
            }
        }
        update leads;        
        return returnUrl;      
    }
    
    public PageReference cancel(){
        
        return returnUrl;
    }
}