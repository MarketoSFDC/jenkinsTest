/* Class Name  : OpportunityLineItemTriggerHandler 
   Created By  : Abhijeet Baneka (Jade Global Inc)
   Description : This class will handle all the trigger events and give call to helper class for running the approriate logic. 
   Date Created: 03/02/2015
*/
public class OpportunityLineItemTriggerHandler{
    
    //Helper class will do the logic execution from appropriate event occurance
    
    OpportunityLineItemTriggerHelper oliHelper = new OpportunityLineItemTriggerHelper();
    
    //GET the SteelBrick pricebook ID stored in the custom settong. VERY IMP** : Please update Production SB pricebook id IN custom settings.  
    SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
   
   
    //START Of Before Insert Event Method with new records. 
    //Parameters = 1: 
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.NEW)
    public void isBeforeInsert(List<OpportunityLineItem> newlist){
    //  OpportunityLineItemTriggerHelper.populateOLIFields(newlist,null);
       
    //Added By Jade@@@@@@@@@@@@@@@@ Feb 5th 2016
       OpportunityLineItemTriggerHelper.copyTotalARRToRUSF(newlist);
    
    //Added Method call to update LineSortField__c on OLI on insertion of QLIs
    //Added on 24th Aug 2016
       OpportunityLineItemTriggerHelper.UpdateLineSortFieldOnOLI(newList);
           
    }//END of "Before Insert" Method
    
    
    
    //START Of Before Update Event Method with new records. 
    //Total Parameters = 4: 
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.NEW)
    //Parameter 2 : List of OpportunityLineItem (TRIGGER.OLD)
    //Parameter 3 : Map of OpportunityLineItem (TRIGGER.NEWMAP)
    //Parameter 4 : Map of OpportunityLineItem (TRIGGER.OLDMAP)
    public void isBeforeUpdate(List<OpportunityLineItem> newlist, List<OpportunityLineItem> oldlist, map<id,OpportunityLineItem> newMap, map<id,OpportunityLineItem> oldMap){
       //OpportunityLineItemTriggerHelper.populateOLIFields(newlist,oldMap);
     
     //Added By Jade@@@@@@@@@@@@@@@@ Feb 5th 2016
       OpportunityLineItemTriggerHelper.copyTotalARRToRUSF(newlist);
        
     // Added by Jade - Feb 5 2016
     OpportunityLineItemTriggerHelper.UpdateOpportunityFields(newlist,oldMap);
       
    } //END of "Before Update" Method

    
    //START Of Before Delete Event Method with new records. 
    //Total Parameters = 2: 
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.OLD)
    //Parameter 2 : Map of OpportunityLineItem (TRIGGER.OLDMAP)
    public void isBeforeDelete(List<OpportunityLineItem> oldlist,map<id,OpportunityLineItem> oldMap){
        
       
        
    }//END of "Before Delete" Method
    
    
    
    //START Of After Insert Event Method with new records. 
    //Total Parameters = 2: 
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.NEW)
    //Parameter 2 : Map of OpportunityLineItem (TRIGGER.NEWMAP)
    public void isAfterInsert(List<OpportunityLineItem> newlist,map<id,OpportunityLineItem> newMap){
       
       
        //This trigger will map Total_ARR_for_RUSF__c to Total_ARR__c in case of excluded opportunity related line items. 
        OpportunityLineItemTriggerHelper.Trigger_OpportunityProduct(newlist);
        

    } //END of "After Insert" Method
   
    
    //START Of After Update Event Method with new records. 
    //Total Parameters = 4: 
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.NEW)
    //Parameter 2 : List of OpportunityLineItem (TRIGGER.OLD)
    //Parameter 3 : Map of OpportunityLineItem (TRIGGER.NEWMAP)
    //Parameter 4 : Map of OpportunityLineItem (TRIGGER.OLDMAP)
    public void isAfterUpdate(List<OpportunityLineItem> newlist, List<OpportunityLineItem> oldlist, map<id,OpportunityLineItem> newMap, map<id,OpportunityLineItem> oldMap){
        
        //This trigger will map Total_ARR_for_RUSF__c to Total_ARR__c in case of excluded opportunity related line items. 
       //OpportunityLineItemTriggerHelper.Trigger_OpportunityProduct(newlist);
      //OpportunityLineItemTriggerHelper.createAsset(newlist,oldMap);
      createSandboxAssetForMDQ.createAsset(newlist,oldMap);
        
    }//END of "After Update" Method
    
    
    //START Of After Delete Event Method with new records. 
    //Total Parameters = 2
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.OLD)
    //Parameter 2 : Map of OpportunityLineItem (TRIGGER.OLDMAP)
    public void isAfterDelete(List<OpportunityLineItem> oldlist,map<id,OpportunityLineItem> oldMap){
        
      
    }//END of "After Delete" Method
    
    
    //START Of After unDelete Event Method with new records. 
    //Total Parameters = 2
    //Parameter 1 : List of OpportunityLineItem (TRIGGER.NEW)
    //Parameter 2 : Map of OpportunityLineItem (TRIGGER.NEWMAP)
    public void isAfterUnDelete(List<OpportunityLineItem> newlist,map<id,OpportunityLineItem> newMap){
        
       
    } //END of "After UnDelete" Method
   
}