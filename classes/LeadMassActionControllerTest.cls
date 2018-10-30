@isTest
private class LeadMassActionControllerTest {
    
 /***test code started***/
    static testMethod void testLeadMassActionController () {
        
        Lead led = new Lead(email='test@marketo.com', LastName='test_lead', company='test', status='Pending');
        insert led;     
        PageReference pageRef = Page.LeadMassActions;
        pageRef.getParameters().put('id', String.valueOf(lead.Id));
        pageRef.getParameters().put('LeadMassTask','LEAD_CHANGE_TOUCH_STAGE');
        pageRef.getParameters().put('key',led.Id);
        pageRef.getParameters().put('retUrl','/'+led.Id);
        Test.setCurrentPage(pageRef);
        LeadMassActionController cmc = new LeadMassActionController ();
        cmc.save();
        cmc.cancel();           
    
    }
}