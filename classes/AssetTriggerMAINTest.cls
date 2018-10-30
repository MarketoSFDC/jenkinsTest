@isTest
public class AssetTriggerMAINTest {
    static testMethod void CoverAssetTrig() {
        Test.startTest();
		//String s = Label.TriggerSwitch;
        date toCloseDate = Date.newInstance(2013,12,30);
        Account acc = UtilityToCreateTestData.insertAccount();
        Contact con = UtilityToCreateTestData.insertContact(acc.id);
        Opportunity opp = UtilityToCreateTestData.insertOpportunityWithPrimaryMarketoUser(acc.id, 'Closed Won', 'New Business', toCloseDate, con.Id, con.Email);
        system.debug('******* Opportunity : '+opp);
        
        Asset a = new Asset();
        a.Name = 'TestAsset';
        a.installdate = System.today();
        a.UsageEndDate = System.today().addMonths(1);
        a.Opportunity__c = opp.id;
        a.AccountId = acc.Id;
        a.ContactId = con.Id;
        insert a; 
        ID assetId=a.id;
        update a;
        Asset asset_test=[SELECT name from asset where id=:assetId];
        System.assertNotEquals(asset_test,null);
        delete asset_test;
        undelete asset_test;
        Test.stopTest();
    }
}