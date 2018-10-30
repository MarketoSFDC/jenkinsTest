/* Class Name  : AssetTriggerHandler 
   Created By  : Abhijeet Baneka (Jade Global Inc)
   Description : This class will handle all the trigger events and give call to helper class for running the approriate logic. 
   Date Created: 03/02/2015
*/
public class AssetTriggerHandler{
    
    //Helper class will do the logic execution from appropriate event occurance
    
    AssetTriggerHelper aHelper = new AssetTriggerHelper();
    
    //GET the SteelBrick pricebook ID stored in the custom settong. VERY IMP** : Please update Production SB pricebook id IN custom settings.  
    SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
   
   
    //START Of Before Insert Event Method with new records. 
    //Parameters = 1: 
    //Parameter 1 : List of Asset (TRIGGER.NEW)
    public void isBeforeInsert(List<Asset> newlist){
    
        AssetTriggerHelper.PopulateMaxDBOnAsset(newlist); 
        AssetTriggerHelper.updateAssetAndContracts(newlist); 
        //AssetTriggerHelper.updateRubixSubscriptions(newList);   
        //if(test.isRunningTest()){
        //    AssetTriggerHelper.updateRubixSubscriptions(newList);    
        //}
        
       
        
    }//END of "Before Insert" Method
    
    
    
    //START Of Before Update Event Method with new records. 
    //Total Parameters = 4: 
    //Parameter 1 : List of Asset (TRIGGER.NEW)
    //Parameter 2 : List of Asset (TRIGGER.OLD)
    //Parameter 3 : Map of Asset (TRIGGER.NEWMAP)
    //Parameter 4 : Map of Asset (TRIGGER.OLDMAP)
    public void isBeforeUpdate(List<Asset> newlist, List<Asset> oldlist, map<id,Asset> newMap, map<id,Asset> oldMap){
        AssetTriggerHelper.PopulateMaxDBOnAsset(newlist); 
        AssetTriggerHelper.updateAssetAndContracts(newlist);
        AssetTriggerHelper.updateRubixSubscriptions(newList);
        
    } //END of "Before Update" Method

    
    //START Of Before Delete Event Method with new records. 
    //Total Parameters = 2: 
    //Parameter 1 : List of Asset (TRIGGER.OLD)
    //Parameter 2 : Map of Asset (TRIGGER.OLDMAP)
    public void isBeforeDelete(List<Asset> oldlist,map<id,Asset> oldMap){
        
       
        
    }//END of "Before Delete" Method
    
    
    
    //START Of After Insert Event Method with new records. 
    //Total Parameters = 2: 
    //Parameter 1 : List of Asset (TRIGGER.NEW)
    //Parameter 2 : Map of Asset (TRIGGER.NEWMAP)
    public void isAfterInsert(List<Asset> newlist,map<id,Asset> newMap){
       
        AssetTriggerHelper.updateAssetAndContracts(newlist); 
        
        AssetTriggerHelper.Asset_BI_BU_AI_AU(newlist,null);
     
    } //END of "After Insert" Method
   
    
    //START Of After Update Event Method with new records. 
    //Total Parameters = 4: 
    //Parameter 1 : List of Asset (TRIGGER.NEW)
    //Parameter 2 : List of Asset (TRIGGER.OLD)
    //Parameter 3 : Map of Asset (TRIGGER.NEWMAP)
    //Parameter 4 : Map of Asset (TRIGGER.OLDMAP)
    public void isAfterUpdate(List<Asset> newlist, List<Asset> oldlist, map<id,Asset> newMap, map<id,Asset> oldMap){
        
        AssetTriggerHelper.Asset_BI_BU_AI_AU(newlist,oldlist);
        
        //Below Method Update the DataBase Size on related UsageData By -- Grazitti Interactive
        //AssetTriggerHelper.UpdateUsageDataDataBaseSize(newlist);
        
    }//END of "After Update" Method
    
    
    //START Of After Delete Event Method with new records. 
    //Total Parameters = 2
    //Parameter 1 : List of Asset (TRIGGER.OLD)
    //Parameter 2 : Map of Asset (TRIGGER.OLDMAP)
    public void isAfterDelete(List<Asset> oldlist,map<id,Asset> oldMap){
        
       // AssetTriggerHelper.Asset_BI_BU_AI_AU(null,oldlist);  
    }//END of "After Delete" Method
    
    //START Of After unDelete Event Method with new records. 
    //Total Parameters = 2
    //Parameter 1 : List of Asset (TRIGGER.NEW)
    //Parameter 2 : Map of Asset (TRIGGER.NEWMAP)
    public void isAfterUnDelete(List<Asset> newlist,map<id,Asset> newMap){
        
       
    } //END of "After UnDelete" Method
   
}