/* Disabled by Passage Technology on 11/27/2012 per instruction from Creator to allow another trigger to be deployed*/

@isTest(seeAllData=true)
public class TestCovcloneOpportunityBasedOnCriteria{
public static testmethod void testingtrigger(){

Account acc= new account();
acc.name='Test Account';
acc.CurrencyIsoCode='USD';
acc.BillingCity = 'Ichalkaranji';
acc.BillingCountry = 'India';
acc.BillingStreet = 'Test Street';
acc.BillingState ='Test Billing State';
acc.BillingPostalCode ='12345';
acc.ShippingCity ='Pune';
acc.ShippingCountry ='India';
acc.ShippingPostalCode = '12345';
acc.ShippingState = 'Maharashtra';
acc.ShippingStreet = 'Test Shipping Street';
insert acc;
/*
Recordtype rtype = new recordtype();
rtype.sObjectType='Opportunity';
rtype.name = 'Closed Won';
insert rtype; 
*/
//Disabled by Passage Technology
ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
ID  ChannelId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Channel').getRecordTypeId();

list<Opportunity> ListOfOpp = new list<Opportunity>();
//Disabled by Passage Technology

Opportunity opp = new opportunity();
opp.Name='Test Name';
opp.CRM_System__c='Microsoft CRM 2011';
opp.AccountId=acc.id ;
opp.CloseDate=Date.today();
opp.stagename='Discovery';
opp.Deal_Type__c='Services';
opp.NextStep='abc';
opp.Forecast_Category__c='Commit';
opp.LeadSource='Additional User';
opp.type='New Business';
opp.recordtypeId=RenewalSalesId;
opp.Quarterly_Renewal__c='123';
insert opp;
OppProQuanPrice_TriggerClass.isFromTriggerCloneOppBasedonCriteria = false;
opp.recordtypeId=ChannelId;
update opp;

ListOfOpp.add(opp);
/*
opportunity op = new opportunity();
op.Name='Test Namee';
op.CRM_System__c='Sales Logix';
op.AccountId=acc.id ;
op.CloseDate=Date.today()+8;
op.stagename='Discovery'; 
op.Deal_Type__c='Standard';
op.NextStep='abcd';
op.Forecast_Category__c='Commit';
op.LeadSource='Additional User';
op.type='Renewal';
op.recordtypeId=ChannelId;
op.Quarterly_Renewal__c='123';
ListOfOpp.add(op);
insert op;

opportunity o = op;
ListOfOpp.add(o);
 */
upsert ListOfOpp; 
 

/*
OpportunityContactRole ocRole = new OpportunityContactRole();
ocRole.OpportunityId =opp.id;
ocRole.IsPrimary=true;
insert ocRole;


*/
}



}