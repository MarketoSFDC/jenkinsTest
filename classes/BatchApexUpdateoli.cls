global class BatchApexUpdateoli Implements Database.Batchable<OpportunityLineItem>{
    global List<ID> AccountIDs= New list<Id>();
    global List<ID> Act_IDs= New list<Id>();
    global Map < ID, ID > Prod_ass_map = new Map < ID, ID > ();
    global List < OpportunityLineItem > Oli_List = new List < OpportunityLineItem > ();
    global MAP <ID,LIST<ASSET>> ACCNTASSMAP= NEW MAP<ID,LIST<ASSET>>(); 
    global LIST<ASSET> AST= NEW LIST<ASSET>();
    global List < OpportunityLineItem > newOli_List = new List < OpportunityLineItem > ();
    //global List < OpportunityLineItem > Oli_List = new List < OpportunityLineItem > ();
        global  BatchApexUpdateoli(){
        newOli_List=[SELECT ID, OpportunityID, Pricebookentry.Product2ID, Opportunity.AccountID,
                    related_asset__c FROM OpportunityLineItem
                    WHERE Opportunity.stageName = 'Not Contacted'
                    and Opportunity.type = 'Renewal' and related_asset__c= null];
                
            }
            
             
    
        global Iterable<OpportunityLineItem> start(database.batchablecontext BC){
            return (newOli_List);    
        }
        
        global void execute(Database.BatchableContext BC, List<OpportunityLineItem> scope){
           for(OpportunityLineItem oli:scope)
                {
                    Act_IDs.Add(oli.Opportunity.AccountID);
                
               } 
               for (ACCOUNT A: [SELECT ID, (SELECT ID, AccountID, Product2ID FROM AssetS) FROM ACCOUNT where id In:Act_IDs]) {
                    ACCNTASSMAP.PUT(A.ID, A.ASSETS);
                    IF(A.ASSETS.SIZE() > 0) {
                    AccountIDs.ADD(A.ID);
                    }
                }
            for(OpportunityLineItem oli : scope){    
                
                AST = ACCNTASSMAP.GET(OLI.Opportunity.AccountID);
                    FOR(ASSET AB: AST) {
                    system.debug('>*'+AB.PRODUCT2ID);
                        IF(AB.PRODUCT2ID == OLI.Pricebookentry.Product2ID) {
                            OLI.RELATED_ASSET__C = AB.ID;
                        }

                    }
                Oli_List.add(oli);
            }
            system.debug('>*'+Oli_List.size());
            update  Oli_List;
        }    
        global void finish(Database.BatchableContext info){ }//global void finish loop
    
    
}