public class SalesTriggersUtility{

    public static Marketo_Trigger_Management__c marketoTriggerManager = Marketo_Trigger_Management__c.getInstance(); 
    
    public static Boolean isQuoteUpdatedFromOpportunityTrigger = false;
    
    public static Boolean dlrs_AccountTrigger = false;
    public static Boolean dlrs_ContractTrigger = false;
    public static Boolean dlrs_SBQQ_QuoteLineTrigger = false;
    public static Boolean dlrs_SBQQ_SubscriptionTrigger = false;
    public static Boolean AssetTriggerVA = false;
    public static Boolean QuoteLineTrigger= false;
    
     Public static Void Setvaluesfortest(){
        marketoTriggerManager.Deactivate_Account_Triggers__c= False;
        marketoTriggerManager.Deactivate_Asset_Triggers__c= False;
        marketoTriggerManager.Deactivate_Contact_Triggers__c= False;
        marketoTriggerManager.Deactivate_Contract_Triggers__c= False;
        marketoTriggerManager.Deactivate_Entitlements_Triggers__c= False;
        marketoTriggerManager.Deactivate_Legacy_QLI_Triggers__c= False;
        marketoTriggerManager.Deactivate_Legacy_Quote_Triggers__c= False;
        marketoTriggerManager.Deactivate_OLI_Triggers__c= False;
        marketoTriggerManager.Deactivate_Opportunity_Triggers__c= False;
        marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c= False;
        marketoTriggerManager.Deactivate_Subscription_Triggers__c= False;
        marketoTriggerManager.Deactivate_User_Triggers__c= False;
        marketoTriggerManager.Deactivate_Project_Triggers__c = False;
        marketoTriggerManager.Deactivate_Timecard_Split_Triggers__c = False;
        marketoTriggerManager.Deactivate_Sales_Invoice_Triggers__c = False;
        marketoTriggerManager.Deactivate_Assignment_Triggers__c = False;
        marketoTriggerManager.Deactivate_Milestone_Triggers__c = False;
        marketoTriggerManager.Deactivate_AssetTriggerVA__c = False;
    }
    Public static Void Settruevaluesfortest(){
        marketoTriggerManager.Deactivate_Account_Triggers__c= true;
        marketoTriggerManager.Deactivate_Asset_Triggers__c= true;
        marketoTriggerManager.Deactivate_Contact_Triggers__c= true;
        marketoTriggerManager.Deactivate_Contract_Triggers__c= true;
        marketoTriggerManager.Deactivate_Entitlements_Triggers__c= true;
        marketoTriggerManager.Deactivate_Legacy_QLI_Triggers__c= true;
        marketoTriggerManager.Deactivate_Legacy_Quote_Triggers__c= true;
        marketoTriggerManager.Deactivate_OLI_Triggers__c= true;
        marketoTriggerManager.Deactivate_Opportunity_Triggers__c= true;
        marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c= true;
        marketoTriggerManager.Deactivate_Subscription_Triggers__c= true;
        marketoTriggerManager.Deactivate_User_Triggers__c= true;
        marketoTriggerManager.Deactivate_Project_Triggers__c = true;
        marketoTriggerManager.Deactivate_Timecard_Split_Triggers__c = true;
        marketoTriggerManager.Deactivate_Sales_Invoice_Triggers__c = true;
        marketoTriggerManager.Deactivate_Assignment_Triggers__c = true;
        marketoTriggerManager.Deactivate_Milestone_Triggers__c = true;
        marketoTriggerManager.Deactivate_AssetTriggerVA__c = true;

    }


}