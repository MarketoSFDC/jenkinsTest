/**@@
    #USE THIS HANDLER WILL GET REQUEST AND NAVIGATE TO EXECUTOR BASED ON EVENT**
    #PLEASE ADD YOUR LOGIC IN HANDLER CLASS RATHER THAN THIS TRIGGER.
    #CREATED BY: Marketo IT (GRAZITTI)
@@**/
public class QuoteLineItem_MAIN_TriggerHandler {
    
    public static boolean isQuoteLineItem_MAIN_Trigger_Executed = false;    
    static boolean hasUpdateApprovalOnQuoteCompleted = false;
    static set<id> quoteIds = new set<id>();

    public static void afterInsertTriggerInBulk(List<QuoteLineItem> newVersions, Map<Id, QuoteLineItem> newVersionMap){
        for(QuoteLineItem  Q : newVersions){
           quoteIds.add(Q.QuoteId);
        }  
        
        /**@@-----UPDATED APPROVAL INFO ON QUOTE @@-----**/
        updateApprovalOnQuote();      
    }
    
    public static void afterUpdateTriggerInBulk(List<QuoteLineItem> newVersions, Map<Id, QuoteLineItem> newVersionMap, Map<Id, QuoteLineItem> oldVersionMap){
        for(QuoteLineItem  Q : newVersions){
           quoteIds.add(Q.QuoteId);
        } 
        
        /**@@----- UPDATED APPROVAL INFO ON QUOTE -----@@**/
        updateApprovalOnQuote();  
    }  
    
    public static void afterDeleteTriggerInBulk(List<QuoteLineItem> oldVersions){
        for(QuoteLineItem  Q : oldVersions){
           quoteIds.add(Q.QuoteId);
        }
        
        /**@@----- UPDATED APPROVAL INFO ON QUOTE-----@@**/
        updateApprovalOnQuote();  
    } 
    
    /**@@ ------- HELPER METHOD STARTED-------------------------------------------------
    ------------------------------------------------------------------------------ @@**/    
    public static void updateApprovalOnQuote(){
        if(hasUpdateApprovalOnQuoteCompleted) return;
        hasUpdateApprovalOnQuoteCompleted = true;
        
        if(!quoteIds.isEmpty()){
             List<Quote> QuotesANdQuoteLineItems = [SELECT  Id ,Sales_Approval__c, PS_Approval__c,Support_Approval__c,
                                                    (
                                                        SELECT Id, QuoteID,Discount,
                                                            pricebookentry.product2.Edition__c,
                                                            pricebookentry.product2.ProductCode,
                                                            pricebookentry.product2.Family,
                                                            pricebookentry.product2.Name
                                                        FROM QuoteLineItems  
                                                    )
                                                    FROM Quote WHERE Id IN: quoteIds];
            string Sales_Approval ;//= '';
            string PS_Approval ;//= '';
            string Support_Approval ;//= '';  
            Boolean HasEnterprise;
            
            for(Quote quo : QuotesANdQuoteLineItems){
                Sales_Approval = '';
                PS_Approval = '';
                Support_Approval = '';
                HasEnterprise = false; 
                for(Quotelineitem ql : quo.Quotelineitems){
                    if(ql.pricebookentry.product2.Edition__c=='Enterprise'){
                         HasEnterprise = true;
                         break;
                     }
                } 
                for(Quotelineitem ql : quo.Quotelineitems){
                    //Quote sales approval start body 
                    if((ql.pricebookentry.product2.Edition__c=='Enterprise' && ql.Discount >= 30) || (ql.pricebookentry.product2.Edition__c!='Enterprise' && ql.Discount >0)){
                        // quo.Sales_Approval__c = 'Approval Needed';
                        Sales_Approval = 'Approval Needed';
                    }              
                    if(ql.pricebookentry.product2.ProductCode=='INT-CUST' || ql.pricebookentry.product2.ProductCode=='SV-SOW'   ||
                      (ql.pricebookentry.product2.Family == 'Services' && ql.Discount >0) ||(ql.pricebookentry.product2.Name.contains('Launch Pack')  && HasEnterprise))                      
                    {
                        // quo.PS_Approval__c = 'Approval Needed';
                        PS_Approval = 'Approval Needed';
                    }
                    //Quote PS Approval end body
                    
                    //Quote Support Approval start body
                    if(ql.pricebookentry.product2.Family == 'Services'){
                        //quo.Support_Approval__c = 'Approval Needed';
                        Support_Approval = 'Approval Needed';  
                    }
                    //Quote Support Approval end body    
                
                }
         
                if(Sales_Approval != '')
                    quo.Sales_Approval__c = 'Approval Needed';
                else
                    quo.Sales_Approval__c = 'Approved';
                
                if(PS_Approval != '') 
                    quo.PS_Approval__c = 'Approval Needed'; 
                else
                    quo.PS_Approval__c = 'Approved';
                
                if(Support_Approval != '')
                    quo.Support_Approval__c = 'Approval Needed'; 
                else
                    quo.Support_Approval__c = 'Approved';        
                
            }
            
            if(!QuotesANdQuoteLineItems.isEmpty()){
                update QuotesANdQuoteLineItems ;
            } 
        }    
    }   

}