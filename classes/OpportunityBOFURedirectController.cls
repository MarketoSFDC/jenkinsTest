public class OpportunityBOFURedirectController{
    
    public Opportunity o;
    public Boolean isBofuSnapshotCreated {get; set;}
    
    public OpportunityBOFURedirectController(ApexPages.StandardController sc) {
    
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('isClosed');
        fields.add('Type');
        fields.add('Deal_Type__c');
        fields.add('Rep_Create_ARR__c');
        if(!Test.isRunningTest()){ sc.addFields(fields);}
        this.o = (Opportunity)sc.getSubject();
        //List<Opportunity> opplist = new List<Opportunity>([SELECT Id, isClosed FROM Opportunity WHERE Id IN (SELECT Opportunity__c FROM BOFU_Snapshot__c WHERE Opportunity__c =: o.Id)]); 

        /*if((!opplist.isEmpty() || opplist.Size() > 0) || o.isClosed || o.Type =='Renewal' || o.Deal_Type__c =='Compliance URE' || o.Deal_Type__c == 'Growth URE' ){
            isBofuSnapshotCreated = true;
        }else{
            isBofuSnapshotCreated = false;
        }*/
        if(o.Rep_Create_ARR__c != null || o.isClosed || o.Type =='Renewal' || o.Deal_Type__c =='Compliance URE' || o.Deal_Type__c == 'Growth URE' ){
            isBofuSnapshotCreated = true;
        }else{
            isBofuSnapshotCreated = false;
        }
     }
    

    public static testMethod void OpportunityBOFURedirectControllerTest() {
        test.startTest();   
        PageReference pageRef = Page.OpportunityBOFURedirect;
        Test.setCurrentPage(pageRef);     
        Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
        insert acc;
        Id stdPbId = Test.getStandardPricebookId();
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.CloseDate = System.Now().Date();
                            opp.Rep_create_arr__c= 1234;
        insert opp;
        ApexPages.standardController cont = new ApexPages.standardController(opp);     
        OpportunityBOFURedirectController pag = new OpportunityBOFURedirectController(cont); 
         //Opportunity_ViewOverridePage_Ctrl ctrlobj=new Opportunity_ViewOverridePage_Ctrl(cont);
         //ctrlobj.redirectOpp();
        test.stopTest();  
    }

}