public with sharing class OppWithAttachments_Con {
    public Map<Id,List<echosign_dev1__SIGN_Agreement__c>> agreementMap{get; set;}
    public List<Opportunity> Opportunities{get;set;}
    
    public OppWithAttachments_Con(){
        init();
    }
    
    private void init(){
        agreementMap = new Map<Id,List<echosign_dev1__SIGN_Agreement__c>>();
        Opportunities = [
                            SELECT 
                                Id,
                                Name,
                                CloseDate,
                                OwnerId,
                                Owner.Name, 
                                Opportunity_ARR2012__c,
                                CurrencyIsoCode,
                                (SELECT Id,Title FROM CombinedAttachments) 
                            FROM 
                                Opportunity 
                            WHERE 
                                CloseDate >=LAST_N_DAYS:60
                            and IsWon = true
                            order by CloseDate desc
                        ];
                        
       List<echosign_dev1__SIGN_Agreement__c> agreements = [
                                                               SELECT 
                                                                    Id,
                                                                    Name,
                                                                    echosign_dev1__Opportunity__c 
                                                                FROM 
                                                                    echosign_dev1__SIGN_Agreement__c
                                                                WHERE 
                                                                    echosign_dev1__Opportunity__c  IN:Opportunities
                                                              ];
        
        for(Opportunity opp : Opportunities){
            if(agreementMap.get(opp.Id) == NULL){
                agreementMap.put(opp.Id, new List<echosign_dev1__SIGN_Agreement__c>());
            }
        }

        for(echosign_dev1__SIGN_Agreement__c esa : agreements){
            agreementMap.get(esa.echosign_dev1__Opportunity__c).add(esa);
        }
        
    }
}