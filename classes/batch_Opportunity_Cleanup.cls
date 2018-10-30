/*********************************************************************
*
* Last Modified By   : Jade Global 19th July 2016
                       Updated on 22nd September 2016 to update Quote Payment frequency from Contract (Quote :Payment_Frequency__c)
* Purpose            : This is used for
                       1.Updating Upsell Opportunity fields
             (Primary Quote,Sub_Start_Date__c,Sub_End_Date__c,Promotional_End_Date__c,Payment_Frequency__c)  
                       2. Updating primary quote fields
                 AmendNewBusinessOpportunityId__c
             3. Updating old primary Quote to non primary
                SBQQ__Primary__c = false
             4. Deleting NB Opportunity created by Steelbrick
                           
************************************************************************/

// ################ Whole Batch Commented For Amends Decommissioning #################

@isTest
global class batch_Opportunity_Cleanup /*implements Database.Batchable<sObject>*/ {
    /*
    String query;
    
    global batch_Opportunity_Cleanup() {
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT id, SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Name, AmendNewBusinessOpportunityId__c FROM SBQQ__Quote__c WHERE AmendNewBusinessOpportunityId__c != null]);
        
    }

    global void execute(Database.BatchableContext BC, List<SBQQ__Quote__c> scope) {
        
    // Update Upsell Opportunity
        List<Opportunity> UpsellOpptyUpdate=new List<Opportunity>();
    
        Set<id> AmendedUpsellOpptyIds=new Set<id>();
    
    //To store the New Business Opportunity IDs
    set<id> NewBusinessOpptyIDs = new set<id>();
    //list of NB opportunity used to delete Opportunity
        List<Opportunity> AmendsNewBusinessOpptyToBeDeleted = new List<Opportunity>();

        List<Opportunity> opps = new List<Opportunity>();
        //Added by Jade on 11th May 2016
        Map<id,double> OpptyWithMaxDataSize = new map<id,double>();
    //Map<id,Opportunity> OpportunityMap = new map<id,Opportunity>();
    //List of Quote to Update
        list<SBQQ__Quote__c> QuoteListToUpdate = new list<SBQQ__Quote__c>();
    //Set of Primary Quote IDs
    set<id> PrimaryQuoteIds  = new set<id>();

    //Map to get the opportunity values to be populated on Upsell Quote
    Map<id,Opportunity> MapUpsellOpptyIdAndUpsellOppty = new Map<id,Opportunity>();
    
    //Map of Quoteid And Quote
    Map<id,SBQQ__Quote__c> MapQuoteIdsWithQuote = new Map<id,SBQQ__Quote__c>();
    
    id QuoteId;
        
        for(SBQQ__Quote__c qt:scope){
            
       AmendedUpsellOpptyIds.add(qt.SBQQ__Opportunity2__c);
       NewBusinessOpptyIDs.add(qt.AmendNewBusinessOpportunityId__c);
        }//End of FOR loop of SBQQ__Quote__c 
        

        if(!AmendedUpsellOpptyIds.isEmpty()){   
            opps = [SELECT id,SBQQ__PrimaryQuote__c,Sub_Start_Date__c,Sub_End_Date__c,Promotional_End_Date__c,Payment_Frequency__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c,SBQQ__AmendedContract__r.ContractTerm,(SELECT id,SBQQ__Primary__c,Promotional_End_Date__c,Payment_Frequency__c,SBQQ__StartDate__c,MKTO_Effective_End_Date__c,Opportunity_Type__c FROM SBQQ__Quotes2__r WHERE Opportunity_Type__c = 'Upsell/Crossell' AND SBQQ__Primary__c = TRUE  and AmendNewBusinessOpportunityId__c!=null LIMIT 1) FROM Opportunity WHERE id IN:AmendedUpsellOpptyIds ];
            
        }
        
        //Logic to Update the Payment Frquency, Master Sub End date and Promotional End date on Oportunity
        //Added by Jade on 7th July 2016
        
        if(!opps.isEmpty()){
            for(Opportunity opp:opps){
            
                if(!MapUpsellOpptyIdAndUpsellOppty.containsKey(opp.id)){
                    MapUpsellOpptyIdAndUpsellOppty.put(opp.id,opp);
                }
      
                if(!(opp.SBQQ__Quotes2__r).isEmpty()){
                    list<SBQQ__Quote__c> primaryQuoteList = opp.SBQQ__Quotes2__r;
        
                    opp.Sub_Start_Date__c = primaryQuoteList[0].SBQQ__StartDate__c != null ? primaryQuoteList[0].SBQQ__StartDate__c : opp.Sub_Start_Date__c;
      
                    opp.Sub_End_Date__c = primaryQuoteList[0].MKTO_Effective_End_Date__c != null ? primaryQuoteList[0].MKTO_Effective_End_Date__c : opp.Sub_End_Date__c;
          
                    opp.Promotional_End_Date__c = primaryQuoteList[0].Promotional_End_Date__c != null ? primaryQuoteList[0].Promotional_End_Date__c : opp.Promotional_End_Date__c;
      
                    opp.Payment_Frequency__c = primaryQuoteList[0].Payment_Frequency__c != null ? primaryQuoteList[0].Payment_Frequency__c : opp.Payment_Frequency__c;
          
                    //Adding Primary Quote id on Opportunity 
                    opp.SBQQ__PrimaryQuote__c = primaryQuoteList[0].id;
          
                    PrimaryQuoteIds.add(primaryQuoteList[0].id);
                    //OpportunityMap.put(opp.id,Opp);
                    UpsellOpptyUpdate.add(opp);
                }//End of IF block Primary Quote List
            }//End of Opportunity FOR loop

        }//End IF block of Opportunity List  
    
    AmendsNewBusinessOpptyToBeDeleted = [SELECT id FROM Opportunity WHERE Id IN :NewBusinessOpptyIDs ];
    //Get all old primary quote to False
    list<SBQQ__Quote__c> OtherPrimaryQuote  = [SELECT id, SBQQ__Opportunity2__c, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Primary__c=true AND SBQQ__Opportunity2__c IN :AmendedUpsellOpptyIds AND id NOT IN :PrimaryQuoteIds ];
    //Update old Primary quote to False
    
    for(SBQQ__Quote__c Quote:OtherPrimaryQuote){
        if(!MapQuoteIdsWithQuote.containskey(Quote.id)){
            Quote.SBQQ__Primary__c = false;
            MapQuoteIdsWithQuote.put(Quote.id,Quote);
        }
        else{
            MapQuoteIdsWithQuote.get(Quote.id).SBQQ__Primary__c = false;
        }
    }
    //Update Main Primary Quote setting AmendNewBusinessOpportunityId__c flag to NULL
    //Updated on 22nd September 2016 to update Quote Payment_Frequency__c from Contract (Quote:Payment_Frequency__c).
       for(SBQQ__Quote__c q : scope){
    if(MapQuoteIdsWithQuote.Containskey(q.id)){
      MapQuoteIdsWithQuote.get(q.id).AmendNewBusinessOpportunityId__c = null;
      
      //Updating Payment Frequency on Amended Quote
      if(!MapUpsellOpptyIdAndUpsellOppty.isEmpty() && MapUpsellOpptyIdAndUpsellOppty.containsKey(q.SBQQ__Opportunity2__c)){
      MapQuoteIdsWithQuote.get(q.id).Payment_Frequency__c = MapUpsellOpptyIdAndUpsellOppty.get(q.SBQQ__Opportunity2__c).SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
      }
      
    }
    else{
      q.AmendNewBusinessOpportunityId__c = null;
      
      //Updating Payment Frequency on Amended Quote
      if(!MapUpsellOpptyIdAndUpsellOppty.isEmpty() && MapUpsellOpptyIdAndUpsellOppty.containsKey(q.SBQQ__Opportunity2__c)){
      q.Payment_Frequency__c = MapUpsellOpptyIdAndUpsellOppty.get(q.SBQQ__Opportunity2__c).SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
      
      MapQuoteIdsWithQuote.put(q.id,q);
    }
              
    }//End of IF
    }
  
    // Update upsell Opportunity 
    if(!UpsellOpptyUpdate.isEmpty()){
      UPDATE UpsellOpptyUpdate;
    }
  
      if(!MapQuoteIdsWithQuote.isEmpty()){
        UPDATE MapQuoteIdsWithQuote.values();
      }
      
      //Delete NB Opportunity created by Steelbrick
      if(!AmendsNewBusinessOpptyToBeDeleted.isEmpty()){
        DELETE AmendsNewBusinessOpptyToBeDeleted;
      }
    }//End of Execute Method   
    
    global void finish(Database.BatchableContext BC) {
        
    }//End of Finish Method
    */
}