/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestOpportunityAutoProvisioning 
{
    static testMethod void testMethods1() 
    {
        OpportunityAutoProvisioning.processOpportunities([SELECT Id FROM Opportunity WHERE (Type = 'New Business' OR Type = 'Upsell/Crossell') LIMIT 100]);
    }
    
    static testMethod void testTrigger1()
    {
        
        // run this as sales ops
        List<User> users = [select u.Name from User u where u.UserRole.Name = 'System Admins' AND IsActive = True];
        User salesOpsUser = users.get(0);
        Account a = Utility.insertAccountInTestClasses();        
        insert a;
        Contact c = Utility.insertContactInTestClasses(a.Id);
        insert c;
        Opportunity o = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Closed Won', 'Renewal',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
        RecordType rt = new RecordType();
        rt.Name = 'Enterprise Sales';
        
        
        // Create opportunity product (line item) list
        /*List<OpportunityLineItem> oppProds = [SELECT Id, Product_Family__c, Users__c, MLM_Edition__c, OpportunityId, 
            PricebookEntry.Product2.Name, PricebookEntry.Product2.Family 
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :oppIds 
            AND (PricebookEntry.Product2.Family = 'Lead Management' OR PricebookEntry.Product2.Family = 'Sales Insight')];
        */
        
        
       /* Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
        List<PriceBookEntry> pbe_list = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id , p.CreatedById , p.LastModifiedById From PricebookEntry p WHERE
            p.Pricebook2.Name = 'Standard Price Book' and p.Name = 'Lead Management - Professional 100K' and p.IsActive = true];
        PricebookEntry pbe = pbe_list.get(0);
                
        OpportunityLineItem oli = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.Opportunity = o;
        oli.PricebookEntry = pbe; */
              
        o.RecordType = rt;
        o.StageName = 'test stage';
        o.Name = 'test2';
        o.Deal_Type__c = 'deal1';
        o.Payment_Frequency__c = 'Monthly';
        System.runAs(salesOpsUser){
            insert o;
            //o.RecordType.Name = OpportunityAutoProvisioning.prerequisite_record_type_value;
            
            //Opportunity newOp = [SELECT o.Id, o.RecordType.Name FROM Opportunity o WHERE o.Id = :o.Id];
            
            o.StageName = OpportunityAutoProvisioning.changed_state_value;
            o.RecordType.Name = OpportunityAutoProvisioning.prerequisite_record_type_value;
            
            update o;
        }
    }
}