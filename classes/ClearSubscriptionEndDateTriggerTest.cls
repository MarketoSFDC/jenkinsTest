/* Author : Jade Global Inc.
 * Test Class : ClearSubscriptionEndDateTriggerTest
 * Date : 5th March, 2015
 * Description : This is the test class for ClearSubscriptionEndDate trigger.
 */

@isTest
public class ClearSubscriptionEndDateTriggerTest {
    
    testMethod static void testEntitlements(){
        List<Account> ListAcc = new List<Account>();
        List<Entitlement> ListEntitle = new List<Entitlement>();
        
        Test.startTest();

        for(Integer i = 0; i < 5; i++) {
          Account a = new Account(Name='TestAccount'+i, ShippingCountry='Australia', Sales_Region__c='Australia',ABN_No__c=' Test 1111'+i);
            ListAcc.add(a);
        }
        insert ListAcc;
    	
		// insert entitlements
        for(integer j = 0; j < ListAcc.size(); j++){
          Entitlement ent = new Entitlement(name='Test Entitlement'+j,AccountId=ListAcc[1].id, StartDate =Date.today(), EndDate = Date.today().addMonths(6),Processed_For_grace__c = TRUE );
            ListEntitle.add(ent);
        }
        insert ListEntitle;
			
		// update entitlements		
        for(integer k = 0; k < ListEntitle.size(); k++){
          ListEntitle[k].Support_Region__c = 'Other';
        }		       
		
        for(integer l = 0; l < ListEntitle.size(); l++){
          ListEntitle[l].EndDate = Date.today().addMonths(8);
        }		
        update ListEntitle;		
        
        for(integer m = 0; m < ListEntitle.size(); m++){
          ListEntitle[m].Processed_For_grace__c = false;
        }
        update ListEntitle;
        
        Test.stopTest();        
    }
}