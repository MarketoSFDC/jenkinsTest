@istest
public class test_trigger
{

    static testmethod void mytest()
    { 
     RecordType Rc=[select id from RecordType where SobjectType='Opportunity' and Name='Closed Won' limit 1];
     Account acc=new Account(Name='test Account');
     insert acc;
     //Opportunity Opp=new Opportunity(RecordTypeId=Rc.id,Name='test Opp',AccountId=acc.id,CloseDate=Date.today(),StageName='Not Contacted',LeadSource='Email');
     //insert Opp;
     Product2 Pro=new Product2();
     
     PriceBook2 ProBook=[select id from PriceBook2 where isstandard=true limit 1];
    // PriceBookEntry pricebook=[select id from PriceBookEntry where isActive=true limit 1];
     //Opportunitylineitem opl=new OpportunityLineItem(OpportunityId=Opp.id,Quantity=1,PriceBookEntryId=pricebook.id);
  
//  insert opl;   
     
    //  Opportunity opp=[select id,Description from Opportunity ];//where RecordTypeId=: Rc.id and HasOpportunityLineitem=true limit 1];
     // system.debug('This is Opp '+opp.Name);
     // opp.Description='test';
    //  update opp;
    }
}