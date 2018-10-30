/*********************************************************************
* Created Date       : 19th August 2016
* Create By          : Jade Global 
* Last Modified By   : Jade Global 19th August 2016
* Purpose            : This is used for
                       1.Controller class for showMDQClosedWonOpptyProducts VF component
                       2.Showing not-MDQ Opportunity Product  and MDQ product 
                       3.Used in provisioning email template Closed Won Opp Notification.
************************************************************************/
public class showMDQClosedWonOpptyProductsController {
    
    
    //To display list of OLI on VF Component
    public list<OpportunityLineItem> showOLIs {get;set;}
    public  id opportunityId;
    
    public Id getopportunityId(){
        return opportunityId;
    }
    
    //set the opportunity id 
    public void setopportunityId(ID oppId){
        opportunityId = oppId;
        showMDQClosedWonOpptyProductsController();
    }
   
    public void showMDQClosedWonOpptyProductsController() {
  
        //opportunityId                           = ApexPages.currentPage().getParameters().get('id');
        
        showOLIs                                = new  list<OpportunityLineItem>();
        list<OpportunityLineItem>showOLIList    = new  list<OpportunityLineItem>();
        list<OpportunityLineItem> nonMDQOLIs    = new  list<OpportunityLineItem>();
        list<OpportunityLineItem> segmentedOLIs = new  list<OpportunityLineItem>();
        list<date> SegmentStartDate             = new  list<date>();
    
        system.debug('############### opportunityId' + opportunityId);
        if(opportunityId!=null ){
           //showOLIs=new List<OpportunityLineItem>();
           
           showOLIList   = [SELECT  id, OpportunityId,PricebookEntry.Product2.Name,Product_Family__c,Users__c,Contract_Quantity__c,ServiceDate,ServiceEndDate__c,Months__c,SBQQ__QuoteLine__r.SBQQ__SegmentKey__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__StartDate__c,Product_Start_Date__c FROM OpportunityLineItem WHERE OpportunityId=:opportunityId ORDER BY Product_Family__c ASC];
           
            
            for(OpportunityLineItem OLI : showOLIList){
                
                if((OLI.SBQQ__QuoteLine__r.SBQQ__SegmentKey__c==null) || (OLI.SBQQ__QuoteLine__r.SBQQ__SegmentKey__c!=null && OLI.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__StartDate__c==OLI.ServiceDate))
                {  
                    showOLIs.add(OLI);
                }//End Of IF
                
          }//End of FOR loop of OpportunityLineItem
           
           // system.assertEquals(showOLIs.size(), 1);
           
          // showOLIList.addAll(nonMDQOLIs); 
           /*
           //sort showOLIList for displaying bundle product at top
           for(integer i=showOLIList.size()-1;i>=0 ; i--){
               showOLIs.add(showOLIList[i]);
           }//End of for
           */
        }//End of IF block
    }//End of constructor

}