public class marketoASC606pluginClass {
    
    
    @InvocableMethod(Label='Closed Won Process' description='Update Opportunity Lines with Entity and Schedules')
    public static void updateLines(List<Opportunity> opps)
    {
        for(Opportunity o :opps)
        {
        intaact606(o.id);    
        }
    }
   
    
    
    
    public static void intaact606(string OppId)
    {
    Opportunity opp = [SELECT Id, Payment_Frequency__c, ORC_Geo__c, SBQQ__PrimaryQuote__c,
                       SBQQ__PrimaryQuote__r.Show_All_Bundles__c, SBQQ__PrimaryQuote__r.Show_Platform_Only__c
                       from opportunity where id = :oppId];
    
        List<OpportunityLineItem> lines = [SELECT ID, Product_Type__c, Product_Start_Date__c,TotalPrice, Package_Total__c,
                                       Quote_Line_End_Date__c, ia_crm__Start_Date__c, Quote_End_Date__c,
                                       ia_crm__End_Date__c, Quantity, Months__c from OpportunityLineItem where OpportunityId = :oppId];
    if(opp.Orc_Geo__c == NULL)
    {
        opp.Orc_Geo__c = 'NA';
    }
        
    ia_crm__Intacct_Entity__c entity = [SELECT Id, Name, Geo__c from ia_crm__Intacct_Entity__c 
                                        where ia_crm__Status__c = true and Geo__c = :opp.ORC_Geo__c];
    string frequency = opp.Payment_Frequency__c;
    if (frequency == 'Semi-Annually')
    {
        frequency = 'semiAnnual';
    }
    List<ia_crm__Billing_Template__c> templateList = [SELECT ID, Type__c, Months__c from ia_crm__Billing_Template__c where Type__c = :frequency];
    
        map<Decimal, ID> templateMap = new Map<Decimal,Id>();
        for(ia_crm__Billing_Template__c t :TemplateList)
        {
            templateMap.put(t.Months__c, t.ID);
        }
        
    for(OpportunityLineItem l : lines )
    {
        	l.ia_crm__Intacct_Location__c = entity.id;
            l.ia_crm__Intacct_Entity__c = entity.id;
            l.ia_crm__End_Date__c =  l.Quote_Line_End_Date__c;
            if(l.ia_crm__End_Date__c == NULL)
            {
            l.ia_crm__End_Date__c =  l.Quote_End_Date__c;  
            }
            l.ia_crm__Start_Date__c = l.Product_Start_Date__c;
            l.ia_crm__Amount__c = l.TotalPrice;
            l.ia_crm__Multiplier__c = l.Quantity;
            l.ia_crm__Billing_Method__c = 'Fixed price';
                	if((l.Product_Type__c == 'Subscription' || l.Product_Type__c == 'Subscription Services'))
                    {
                     l.ia_crm__Amount__c = l.Package_Total__c; 
                     l.UnitPrice = l.Package_Total__c/l.Quantity; 
                    }
        	if((l.Product_Type__c == 'Subscription' || l.Product_Type__c == 'Subscription Services') &&  (l.Months__c == 12 && frequency != 'Annually'))
            {
                    if(templateMap.containsKey(l.Months__c))
                    {
                    l.ia_crm__Billing_Template__c =  templateMap.get(l.Months__c);
                    }
                    else
                    {
                    l.ia_crm__Billing_Template__c = 'aKS1F0000000018';  
                    }
                 	l.ia_crm__Billing_End_Date__c = l.Quote_Line_End_Date__c;
                    if(l.ia_crm__Billing_End_Date__c == NULL)
                    {
                      l.ia_crm__Billing_End_Date__c = l.Quote_End_Date__c; 
                    }                        
                 	l.ia_crm__Billing_Start_Date__c = l.Product_Start_Date__c;
                    l.ia_crm__Contract_Line_Save_Cancel_He__c = 'Use billing template';
            }
        else if(l.Months__c == 12 && frequency == 'Annually' )
        {
        l.ia_crm__Contract_Line_Save_Cancel_He__c = 'One-time';    
        }
        else
        {
        l.ia_crm__Contract_Line_Save_Cancel_He__c = 'One-time';    
        }
    }
        update lines;
    }
    

}