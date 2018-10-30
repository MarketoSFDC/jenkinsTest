/**************************************************************
last modified by : Sumit Bhatt, Grazitti Interactive
last Modified Date : 13-April-2018
changes done: #APPS-16825# Clean up Rollup Summary fields - BOFU Snapshot
Tracking : One can track the changes by searching the ticket number in the code 
*************************************************************/
public with sharing class Opportunity_ViewOverridePage_Ctrl{
    
    ApexPages.StandardController controller;
    
    public opportunity opportunity {get;set;}
    public ID OppID {get;set;}
    public Boolean BOFU_Wizard{get;set;}
    public Boolean isEditAvailable {get;set;}
    
    //Contructor
    public Opportunity_ViewOverridePage_Ctrl(ApexPages.StandardController controller) {
        
        ID currentUserID = UserInfo.getUserId();
        system.debug('====USER ID===='+ currentUserID);
        List<String> fields = new List<String>();
        fields.add('Name');
        fields.add('isClosed');
        fields.add('Type');
        fields.add('Deal_Type__c');
        fields.add('StageName');
        if(!Test.isRunningTest()){ controller.addFields(fields);}
        
        opportunity = (opportunity) controller.getRecord();
        OppID = opportunity.Id;
        system.debug('====Opp ID of current Page===='+OppID);
        
        BOFU_Wizard = [SELECT Id, BOFU_Wizard_Enabled__c FROM User WHERE ID = :currentUserID][0].BOFU_Wizard_Enabled__c;
        
        /* #APPS-16825#
		List<BOFU_Snapshot__c> bnap = new List<BOFU_Snapshot__c>([SELECT Opportunity__c FROM BOFU_Snapshot__c WHERE Opportunity__c =: OppID]);
        //bnap.isEmpty() && BOFU_Wizard && && (opportunity.Type != 'Renewal' || opportunity.Deal_Type__c !='Compliance URE')
        if(bnap.isEmpty() && BOFU_Wizard && opportunity.Type != 'Renewal' && opportunity.Deal_Type__c !='Compliance URE' && opportunity.StageName!= 'Closed Won' && opportunity.Deal_Type__c != 'Growth URE'){
            isEditAvailable = false;
        }else{
            isEditAvailable = true;
        } #APPS-16825# */
        system.debug('====BOFU_Wizard Checked or Not===='+ BOFU_Wizard);
        
    }
    
    /*public pageReference StandardOppPage(){
        
        PageReference page = new PageReference('/' + OppID); 
        page.setRedirect(true); 
        return page; //- See more at: https://www.sundoginteractive.com/blog/the-basics-of-calling-a-visualforce-page-from-a-salesforce-detail-page#sthash.OtV5fEjX.dpuf
    }
    
    public pageReference VF_OverridePage(){
    
        PageReference page = new PageReference('/' + 'Apex' + '/' + 'Opportunity_ViewOverridePage' ); 
        page.setRedirect(true); 
        return page; //- See more at: https://www.sundoginteractive.com/blog/the-basics-of-calling-a-visualforce-page-from-a-salesforce-detail-page#sthash.OtV5fEjX.dpuf
    }*/
    
    public pageReference redirectOpp()
    {
        PageReference ref;
        //ref = new PageReference('/apex/Opportunity_ViewOverridePage?id='+OppID ); 
        //else
        if(!BOFU_Wizard)
        ref= new PageReference('/'+OppID+'?nooverride=1');
        
        return ref;
 
    
    }
}