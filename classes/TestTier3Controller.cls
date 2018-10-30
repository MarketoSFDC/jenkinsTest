@istest(SeeAllData=True)
public class TestTier3Controller{
    Private Static testmethod void TestTier3Ctrl(){  
        case caseObj = new case();
        caseobj = [select id from case where recordtypeid = '01250000000UJwx' and Entitlementid!=null limit 1];
        caseobj.Problem_Type__c = 'Beta';
        caseobj.Category__c = 'ABM';
        caseobj.Sub_Category__c = 'RCA';
        update caseobj;
        ApexPages.currentPage().getParameters().put('id',caseObj.id);
        ApexPages.StandardController stdCase = new ApexPages.StandardController(caseObj);
        Tier3caseController CaseController  = new Tier3caseController(stdCase);     
        CaseController.populateTier3Section();
    }
}