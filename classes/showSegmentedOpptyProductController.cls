/*********************************************************************
* Created Date       : 18th August 2016
* Create By          : Jade Global 
* Last Modified By   : Jade Global 18th August 2016
* Purpose            : This is used for
                       1.Controller class for showSegmentedOpportunityProduct VF component
                       2.Showing Segemented Opportunity Product 
                       3.used in provisioning email template.
************************************************************************/
public class showSegmentedOpptyProductController {

    public list<SegmentedOpptyLineItems> showSegmentedOLI{get;set;}
    public  id opportunityLineId;

    //get the opportunity id from visualforce component
    public ID getopportunityLineId(){ 
        return opportunityLineId; 
    }
    
    //set the OLI id 
    public void setopportunityLineId(ID OLIID){
        opportunityLineId = OLIID;
        showSegmentedOpptyProductController();
    }
    
    
    public void showSegmentedOpptyProductController() {
       //wrapper class list declaration 
       showSegmentedOLI=new list<SegmentedOpptyLineItems>();
       list<SBQQ__Subscription__c> showSegSubscription;
       OpportunityLineItem SegOLI;
       list<OpportunityLineItem> showSegOLIs = new  list<OpportunityLineItem>();
       
       //declare Quote line Id set
       Set<Id> QLIIds= new Set<id>();
       
       //declare Quote line Id and OLI Users map
       Map<Id, Double> QLIIdWithUsersMap=new Map<Id, Double>();
       
       system.debug('#############opportunityLineId'+opportunityLineId);  
       if(opportunityLineId!=null){
          //get current opportunity segmented OLI details
          SegOLI=[SELECT  id, Segment_Start_Date__c, OpportunityId,PricebookEntry.Product2.Name,Product_Family__c,Users__c,Contract_Quantity__c,ServiceDate,ServiceEndDate__c,Months__c,SBQQ__QuoteLine__c FROM OpportunityLineItem WHERE ID=: opportunityLineId];
          id OpptyId = SegOLI.OpportunityId;
          system.debug('SegOLI=================='+SegOLI);
            
          //Get Segment start date from OLI
          date segmentStartDate = SegOLI.Segment_Start_Date__c;
          system.debug('segmentStartDate=================='+segmentStartDate);

          //Get segmented OLIs related to Opportunity and with Segment_Start_Date__c same as segmentStartDate
          showSegOLIs = [SELECT  id, Segment_Start_Date__c, OpportunityId,PricebookEntry.Product2.Name,Product_Family__c,Users__c,Contract_Quantity__c,ServiceDate,ServiceEndDate__c,Months__c,Product_Start_Date__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c FROM OpportunityLineItem WHERE OpportunityId =:OpptyId AND Product_Start_Date__c=:segmentStartDate];
          
          system.debug('#########showSegOLIs'+showSegOLIs );
          
          //prepare QLI Id set and QLI Id and  Oli users map
          for(OpportunityLineItem oli:showSegOLIs){
                QLIIds.add(oli.SBQQ__QuoteLine__c);
                if(oli.Users__c!=null){
                    QLIIdWithUsersMap.put(oli.SBQQ__QuoteLine__c,oli.Users__c);
                }
          }
          
        //Get segmented OLIs-> subscription related to Opportunity and with Segment_Start_Date__c same as segmentStartDate
		
		//Modified this SOQL to add SBQQ__SegmentQuantity__c field
		//Modified By: Jade Global Inc
		//Date: 15th March 2017
		//JIRA Reference --> APPS-12423:RE: Segmented Product list for Closed Won MDQ Opportunity
		showSegSubscription=[SELECT id,SBQQ__ProductName__c,SBQQ__QuoteLine__r.SBQQ__ProductFamily__c,SBQQ__Quantity__c,SBQQ__SegmentQuantity__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__QuoteLine__r.MKTO_Effective_Term__c FROM SBQQ__Subscription__c where SBQQ__QuoteLine__c IN :QLIIds]; 

         
        system.debug('##########showSegSubscription'+showSegSubscription);
        if(showSegSubscription!=null){
             for(SBQQ__Subscription__c sub:showSegSubscription){
                system.debug('########### sub'+sub);
                SegmentedOpptyLineItems SegOLIs=new SegmentedOpptyLineItems();
                SegOLIs.ProductName=sub.SBQQ__ProductName__c;
                SegOLIs.ProductFamily=sub.SBQQ__QuoteLine__r.SBQQ__ProductFamily__c;
                SegOLIs.startDate=sub.SBQQ__StartDate__c;
                SegOLIs.endDate=sub.SBQQ__EndDate__c;
                SegOLIs.Term=sub.SBQQ__QuoteLine__r.MKTO_Effective_Term__c;
				
				//Assigning Segment Quantity to its SegOLIs Qty
				//Changed on 15th Feb 2017
				//JIRA Reference --> APPS-12423:RE: Segmented Product list for Closed Won MDQ Opportunity
                SegOLIs.Quantity=sub.SBQQ__SegmentQuantity__c;
				
                if(QLIIdWithUsersMap.containsKey(sub.SBQQ__QuoteLine__c)){
                  system.debug('Inside the contains key ##########'+QLIIdWithUsersMap.get(sub.SBQQ__QuoteLine__c));
                  SegOLIs.User=QLIIdWithUsersMap.get(sub.SBQQ__QuoteLine__c);
                }
                system.debug('SegOLIs #########'+SegOLIs);
                showSegmentedOLI.add(SegOLIs);
             }
             system.debug('############ showSegmentedOLI'+showSegmentedOLI);
        }
        system.debug('showSegOLIs=================='+showSegOLIs);
 
        }//End of IF block
        

    }
    
            // Wrapper Class
    public class SegmentedOpptyLineItems{
        public String ProductName{get;set;}
        public String ProductFamily{get;set;}
        public date startDate{get;set;}
        public date endDate{get;set;}
        public decimal Term{get;set;}
        public Double Quantity{get;set;}
        public Double User{get;set;}
    }
    
}