/*******************************************************
Modified By : Sumit Bhatt, Grazitti Interactive
Modified date : 7/27/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: Third_Party_Solutions__c

 Modified By :Jade Global 31th August 2018
 Change      : Removed closedWonRecordTypeId   variable from class
          
*******************************************************/
@isTest(SeeAllData=true)
public class closeWonOpportunity_ValidationTest{
    public static testmethod void  closeWonOppProvisioningValidation(){
    
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        //Insert an Account
        list<Account> accList = TestCPQUtilityClass.createAccounts(1);
        accList[0].Name = 'Jade Test Account';
        acclist[0].website ='testgf@test.com' ;
        insert accList;
        
        contact cc = new contact();
        cc.FirstName = 'grazitti';
        cc.LastName = 'test';
        cc.AccountId = accList[0].Id;
        
       Product2 pro = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
       insert pro;
       
        PriceBook2 Pb2 = [Select id from PriceBook2 where IsStandard = true limit 1]; 
       //PriceBook2 Pb2 = new PriceBook2(Name ='test',IsActive = True);
      // insert Pb2; 
       
       PriceBookEntry Pbe = new PriceBookEntry(IsActive = true,PriceBook2Id = Pb2.id, Product2Id = pro.id, UnitPrice = 200);          
       insert Pbe; 
        
        //Insert New Business Oppty
        list<Opportunity> NBOppList = TestCPQUtilityClass.createOpportunities(accList,1);
        for(Opportunity o : NBOppList){
            o.Type = 'New Business';
            o.Primary_Marketo_User_Lookup__c = cc.Id;
            o.CloseDate = System.Today() + 365;
            o.Pricebook2Id = Pb2.Id;
        }
        insert NBOppList;
        
        List < OpportunityLineItem > OplList = new List < OpportunityLineItem > ();
        OpportunityLineItem oli = new OpportunityLineItem();        
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = NBOppList[0].Id;
        oli.PricebookEntryId = Pbe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 2;
        oli.UnitPrice = 200;        
        OplList.add(oli);
        
       Test.starttest();
       insert OplList ; 
       Test.stopTest();
        
        //Insert SBQQ__Quote__c to New Business Oppty
        List<SBQQ__Quote__c> QuoteList = TestCPQUtilityClass.createQuotes(NBOppList,1);
        for(SBQQ__Quote__c q : QuoteList){
            q.SBQQ__Primary__c = TRUE;
        }
        Insert QuoteList;
        
        //************opportunity will go through signorder before closed won*********************
         for(Opportunity oo : NBOppList){
           // o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            oo.Migration__c = true;
            oo.StageName = 'Signed Order';
            oo.Needs_Pains__c = 'oppty';
            oo.Use_Case__c = 'B2B';
            //Commented as per APPS-20840
            //oo.Third_Party_Solutions__c = 'Yes'; 
            //Commented as per APPS-20840
            oo.Subscription_Language__c = 'English';
            oo.Subscription_Locale__c = 'English-United States';
            oo.Subscription_Time_Zone__c = 'Fiji Time (Pacific/Fiji)';
        }
        Update NBOppList;
        
        //Close won New Business Oppty
        for(Opportunity o : NBOppList){
            o.Migration__c = false;
           
            o.StageName = 'Closed Won';
        }
        Update NBOppList;
        
        //Insert Renewal Oppty
        list<Opportunity> RNWLOppList = TestCPQUtilityClass.createOpportunities(accList,1);
        for(Opportunity o : RNWLOppList ){
            o.Type = 'Renewal';
            o.Name = o.Name + '- Exodus';
            o.Migration__c=true;
            o.Prior_Opportunity__c = NBOppList[0].id;
        }
        insert RNWLOppList;
        
        //Insert SBQQ__Quote__c to RNWL Oppty
        List<SBQQ__Quote__c> RNWLQuoteList = TestCPQUtilityClass.createQuotes(RNWLOppList,1);
        for(SBQQ__Quote__c q : RNWLQuoteList){
            q.SBQQ__Primary__c = TRUE;
        }
        Insert RNWLQuoteList;
        
        //Close won RNWL Oppty
        for(Opportunity o : RNWLOppList){
            
            o.StageName = 'Closed Won';
        }
        Update RNWLOppList;
    }
}