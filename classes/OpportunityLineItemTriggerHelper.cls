/* Class Name  : OpportunityLTriggerHelper
   Created By  : Abhijeet Baneka (Jade Global Inc)
   Description : This class will handle all the trigger events and give call to helper class for running the approriate logic. 
   Date Created: 31/1/2015
*/

public class OpportunityLineItemTriggerHelper{

    public static boolean isBeforeTriggerOnPLI_OnceMore      = false;
    public static set<id> setOfIdsToAvoidRecursion           = new set<id>();
    public static set<id> setOfOpporunityIdsToAvoidRecursion = new set<id>();
    public static set<id> setOfQLIId = new set<id>();
    
	public static set<id> setRNWLOLIs = new set<id>();
    
    
    
    public static void Trigger_OpportunityProduct(List<Opportunitylineitem> newlist){
        /*
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Set<Id> exculudedOpptyIds = new Set<Id>();
        
        for(OpptyProduct_ARR_Calculation_Setting__c setting : OpptyProduct_ARR_Calculation_Setting__c.getall().values()){
            exculudedOpptyIds.add(setting.Opportunity_Id__c);
        }
        for(OpportunityLineItem oli : newlist){
            if(!exculudedOpptyIds.contains(oli.OpportunityId)){
                if(!setOfIdsToAvoidRecursion.contains(oli.id)){
                    setOfIdsToAvoidRecursion.add(oli.id);
                    if(oli.Total_ARR__c != null && oli.Total_ARR_for_RUSF__c != oli.Total_ARR__c){
                        OpportunityLineItem oliClone = new OpportunityLineItem(id=oli.Id);
                        oliClone.Total_ARR_for_RUSF__c = oli.Total_ARR__c;
                        oppLineItems.add(oliClone);
                        system.debug(oli.Total_ARR__c+' : OPPORTUNITYPRODUCT__ISSUE 1234 : '+oliClone.Total_ARR_for_RUSF__c);
                    } 
                }
            }
            //system.debug(oli.Total_ARR__c+'===OPPORTUNITYPRODUCT__ISSUE'+oli.Total_ARR_for_RUSF__c);
        }
        For(OpportunityLineItem oli : oppLineItems){
        System.debug('After Update @@@@@@@@@@ Total ARR : '+oli.Total_ARR__c);
        System.debug('After Update $$$$$$$$$$ RUSF : '+oli.Total_ARR_for_RUSF__c);
        }
        
        try{
            isBeforeTriggerOnPLI_OnceMore = true;  
            
            if(!oppLineItems.isempty()){ 
                update oppLineItems;   
             }
        }catch(Exception e){
            newlist[0].addError(e.getMessage()); 
        }  */  
    }
    
    //####################
    //Added method "copyTotalARRToRUSF()" By Jade for ARR to RUSF calculation Feb 5th 2016
    //####################
    
    public static void copyTotalARRToRUSF(List<Opportunitylineitem> newlist){
        System.Debug('##########################Inside copyTotalARRToRUSF##########################');
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            Set<Id> exculudedOpptyIds = new Set<Id>();
            for(OpptyProduct_ARR_Calculation_Setting__c setting : OpptyProduct_ARR_Calculation_Setting__c.getall().values()){
                exculudedOpptyIds.add(setting.Opportunity_Id__c);
            }
            for(OpportunityLineItem oli : newlist){
                if(!exculudedOpptyIds.contains(oli.OpportunityId)){
                    if(oli.Total_ARR__c != null && oli.Total_ARR_for_RUSF__c != oli.Total_ARR__c){
                        //OpportunityLineItem oliClone = new OpportunityLineItem(id=oli.Id);
                        oli.Total_ARR_for_RUSF__c = oli.Total_ARR__c;
                    }                
                }
                system.debug(oli.Total_ARR__c+'===OPPORTUNITYPRODUCT__ISSUE'+oli.Total_ARR_for_RUSF__c);
                
                System.debug('Before Update @@@@@@@@@@ Total ARR : '+oli.Total_ARR__c);
                System.debug('Before Update $$$$$$$$$$ RUSF : '+oli.Total_ARR_for_RUSF__c);
            }   
    }
    
    /*
    public static void populateOLIFields(list<OpportunityLineItem> newOLIList,map<id,OpportunityLineItem> OldOLIMap){
        for(OpportunityLineItem OLI :newOLIList){
            system.debug('======OLI cond 1======================='+( oli.Is_Advantage_Bundle__c &&  OLI.TotalPrice!=null && (Trigger.isInsert ||(Trigger.isUpdate && oli.Is_Advantage_Bundle__c!=OldOLIMap.get(oli.id).Is_Advantage_Bundle__c))));
            system.debug('======OLI cond 2======================='+( oli.Is_Advantage_Bundle__c &&  OLI.TotalPrice!=null));
            if(oli.Is_Advantage_Bundle__c &&  OLI.TotalPrice!=null && (Trigger.isInsert ||(Trigger.isUpdate && oli.Is_Advantage_Bundle__c!=OldOLIMap.get(oli.id).Is_Advantage_Bundle__c))){
                OLI.TotalPrice = OLI.TotalPrice - 3500;//OLI.Advantage_Bundle_Adjustment__c;
            }
            system.debug('======OLI result======================='+OLI.TotalPrice);
        }//End of FOR loop of OpportunityLineItem
        
    }//End of Method populateOLIFields
    */
    
    /*---------------------------------------------------------------------
     * This method is used to update Opportunity if quote is Rubik Solution Quote
     * Created By: Jade Team
     * Update Max DB Size on Opportunity
     * --------------------------------------------------------------------*/
   public static void UpdateOpportunityFields(List<OpportunityLineItem> newOliList, map<id,OpportunityLineItem> OLIOldMap){     // Custom Setting Map - Rubik_Product_Code_Quote_Contacts__c
        Map<String,String> rubikProdCodeMap = new Map<String,String>();
        for(Rubik_Product_Code_Quote_Contacts__c thisCustSetRec :Rubik_Product_Code_Quote_Contacts__c.getAll().values()){
            rubikProdCodeMap.put(thisCustSetRec.Product_Code__c, thisCustSetRec.Name);
        }
        System.debug('rubikProdCodeMap***********' + rubikProdCodeMap);
        
        Map<Id,List<OpportunityLineItem>> oppToOLIMap = new Map<Id,List<OpportunityLineItem>>();
        set<ID> OLIIdSet=new set<ID>();
        
        for(OpportunityLineItem oli :newOliList){
            OLIIdSet.add(oli.opportunityId);
            if(oli.Rubiks_Quote_Id__c !=null && rubikProdCodeMap.containsKey(oli.ProductCode)){
                if(oppToOLIMap.containsKey(oli.OpportunityId)){
                    oppToOLIMap.get(oli.OpportunityId).add(oli);
                }else{
                    oppToOLIMap.put(oli.OpportunityId, new list<OpportunityLineItem>{oli});
                }           
            }
        }       
        System.debug('oppToOLIMap***********' + oppToOLIMap);
        
        List<OpportunityLineItem> oppLineList=new List<OpportunityLineItem>();
        Map<Id, String> OLIIdToOLIMap = new Map<Id,String>();
        if(newOliList!=NULL){
            oppLineList=[SELECT id,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__SegmentLabel__c,opportunityId FROM OpportunityLineItem WHERE opportunityId IN: OLIIdSet];
        }
        for( OpportunityLineItem OLI:oppLineList){
                OLIIdToOLIMap.put(OLI.Id, OLI.SBQQ__QuoteLine__r.SBQQ__SegmentLabel__c);
        }  
        
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        if(!oppToOLIMap.isEmpty()){
         map<id,Opportunity> OpptyMap = new map<id,Opportunity>([SELECT id,Maximum_Database_Size__c FROM Opportunity WHERE id IN :oppToOLIMap.keyset() limit 200]);       
           
            for(Id oppId :oppToOLIMap.keySet()){
             opportunity oppty = OpptyMap.get(oppId);
               // if(!setOfOpporunityIdsToAvoidRecursion.contains(oppId)){
                    Decimal sumOfOliQty = 0.0;
                    for(OpportunityLineItem rubikQuoteOli :oppToOLIMap.get(oppId)){
                        system.debug('Inside OLI for Loop , Segment Lable '+rubikQuoteOli.SBQQ__QuoteLine__r.SBQQ__SegmentLabel__c);
                        string segmentLable;
                        if(OLIIdToOLIMap.containskey(rubikQuoteOli.Id)){
                            segmentLable=OLIIdToOLIMap.get(rubikQuoteOli.Id);
                        }
                        system.debug('segmentLable'+segmentLable);
                        if((rubikProdCodeMap.containsKey(rubikQuoteOli.ProductCode))&& (segmentLable==NULL || segmentLable=='') ){                                                
                            system.debug('Inside If loop');
                            //sumOfOliQty = sumOfOliQty + rubikQuoteOli.Quantity_from_Quote_Line__c;
                            //To get workflow automation's Quantity from Quotline
                            sumOfOliQty = sumOfOliQty + rubikQuoteOli.QuoteLine_Quantity__c;
                        }                   
                    }//End of OpportunityLineItem FOR loop
                    System.debug('sumOfOliQty***********' + sumOfOliQty);
                    //Updated the if condition to handle recursion
                    //Modified By Jade Team
                    if(!setOfOpporunityIdsToAvoidRecursion.contains(oppId)|| oppty.Maximum_Database_Size__c != sumOfOliQty) {
                         Opportunity opp = new Opportunity(Id = oppId, Maximum_Database_Size__c = sumOfOliQty);
                        setOfOpporunityIdsToAvoidRecursion.add(oppId);
                        oppToUpdateList.add(opp);     
                        
                    }
                //}//End of IF block to avoid DML in multiple transaction             
            }//End of Opportunity Id FOR loop
        }          
        System.debug('oppToUpdateList before update***********' + oppToUpdateList);
        
        if(!oppToUpdateList.isEmpty()){
            update oppToUpdateList;
        }   
    }//End of method UpdateOpportunityFields
    
    //Method: UpdateLineSortFieldOnOLI()
    //Added by Jade on 24th Aug 2016
    //Reference JIRA ticket: CPQ-126 LineSortField on Opp Line Item
    //This method will be invoked on Before Insert on OLI to populate the LineSortField__c on OLI from respective value on it's QLI
  
    public static void UpdateLineSortFieldOnOLI (List<Opportunitylineitem> newlist){
        system.debug('Entered In UpdateOLIFields method**********');
        
        SBQQ__QuoteLine__c QLIInstance1=new SBQQ__QuoteLine__c();
        set<Id> QLIID=new set<Id>();
        Map<Id,SBQQ__QuoteLine__c> QLIIdtoQLIMap=new Map<Id,SBQQ__QuoteLine__c>();
        
        for(OpportunityLineItem OLI:newlist){
            if(OLI.SBQQ__QuoteLine__c!=null){
                QLIID.add(OLI.SBQQ__QuoteLine__c);
            }//End of IF
        }//End of FOR
        System.debug('%^%^%^%^%^%^ QLIID: '+QLIID);
        
        if(!QLIID.isEmpty()){
            List<SBQQ__QuoteLine__c> RelatedQLIList=[select Id,LineSortField__c from SBQQ__QuoteLine__c where ID IN:QLIID];

            system.debug('RelatedQLIList**********'+RelatedQLIList);
            if(!RelatedQLIList.IsEmpty()){
                for(SBQQ__QuoteLine__c q:RelatedQLIList){ 
                    if(!QLIIdtoQLIMap.containsKey(q.Id)){
                        QLIIdtoQLIMap.put(q.Id,q);
                        system.debug('QLIIdtoQLIMap********'+QLIIdtoQLIMap);                
                    }//End of IF
                }//End of FOR
            }//End of IF
            
            for(OpportunityLineItem OLI:newlist){
                if(OLI.SBQQ__QuoteLine__c != NULL && QLIIdtoQLIMap.containsKey(OLI.SBQQ__QuoteLine__c)){
                    QLIInstance1=QLIIdtoQLIMap.get(OLI.SBQQ__QuoteLine__c);
                    if((QLIInstance1.LineSortField__c!=null && QLIInstance1.LineSortField__c!=OLI.LineSortField__c) ){
                        OLI.LineSortField__c=QLIInstance1.LineSortField__c;    
                        system.debug('Value of QLI after assigning'+OLI.LineSortField__c);
                    }//End of If                
                }//End of IF
            }//End of FOR
        }//End of IF 
    }//End of method UpdateOLIFields
    
    public static void createAsset(List<Opportunitylineitem> newlist,  map<id,OpportunityLineItem> oldMap){
        List<Account> accountList=new List<Account>();
        for(Opportunitylineitem oli: newlist){
            if(oli.Create_Asset__c==True && oli.Create_Asset__c!=oldMap.get(oli.id).Create_Asset__c){
                Account acc=new Account();
                acc.RecordTypeId='01250000000ULc5'; 
                acc.name='Create Asset - Segment Test Acc ';
                acc.CurrencyIsoCode='AUD';
                accountList.add(acc); 
             }
        }
        insert accountList;
    }
}