global class BatchApexUpdateAssets Implements Database.Batchable<Asset>{
   
    global List<Asset> Asset_List;
    
    global  BatchApexUpdateAssets (){
    Asset_List=[SELECT ID FROM ASSET];
    }
    
       
    
    global Iterable<Asset> start(database.batchablecontext BC){
        return (Asset_List);    
    }
    
    global void execute(Database.BatchableContext BC, List<Asset> scope){
        for(Asset portalUser : scope){     
             
        }
        update scope;
    }    
    global void finish(Database.BatchableContext info){ }//global void finish loop
    
    
}