/**--****************************************************************
    * Last Modified By   : Cassandrea Steiner, Marketo
    * Last Modified Date : November 13, 2017
    * Changes            : APPS-16997: Pre-populate the Use_Case__c field from the account [Line 25, 45, 52, 56]
********************************************************************** 
/**
- TO JUST REDIRECT THE OPPORTUNITY NEW PAGE- EITHER STANDARD OR BOFU.
**/
public class CreateNewOpportunityRedirect {

    public Contact cont;
    
    public createNewOpportunityRedirect (ApexPages.StandardController sc){
       this.cont = (Contact)sc.getRecord();
    } 
    
    /**PAGE ACTION- TO REDIRECT ACCORDINGLY BASED ON BOFU IS ENABLED OR NOT**/ 
    public PageReference onLoad() {
        
        String userId = UserInfo.getUserId();
        String conDates='';
        Set<String> con2Opp = new Set<String>();
        
        User usr = [Select BOFU_Wizard_Enabled__c from User where Id =:userId];
        Contact con = [SELECT Id,Referrer_Notes__c,SDR_Owner_Look_Up__r.Id,SDR_Owner_Look_Up__r.FirstName,SDR_Owner_Look_Up__r.LastName,/*Account.CRM_System__c,*/Account.Name,AccountId,LeadSource,Lead_Source_Comments__c,/*Lead_Category__c, */Buying_Behavior__c,SDR_Owner__c,Referrer_First_Name__c,Referrer_Last_Name__c,Referrer_Email_Number__c,Referrer_Phone_Number__c,Date_Referral_Submitted__c,Referral_Indicator__c,Referring_Partner__c,account.website,account.Use_Casenew__c  FROM Contact Where ID =:Cont.Id Limit 1];
        
        string account_id = con.AccountId != null ? con.AccountId : '' ;
        string con_id = con.Id==null ?'': con.Id;
        string LeadSource = con.LeadSource==null || con.LeadSource=='' ?'': con.LeadSource;
        string Lead_Source_Comments = con.Lead_Source_Comments__c==null || con.Lead_Source_Comments__c=='' ?'': con.Lead_Source_Comments__c;
        string Buying_Behavior = con.Buying_Behavior__c==null || con.Buying_Behavior__c=='' ?'': con.Buying_Behavior__c;
        // string Lead_Category = con.Lead_Category__c==null || con.Lead_Category__c=='' ?'': con.Lead_Category__c;
        string SDR_Owner = con.SDR_Owner__c==null || con.SDR_Owner__c=='' ?'': con.SDR_Owner__c;
        string SDR_Owner_id = con.SDR_Owner_Look_Up__c==null ?'': con.SDR_Owner_Look_Up__c;
        string SDR_Owner_First_Name = con.SDR_Owner_Look_Up__c==null ?'': con.SDR_Owner_Look_Up__r.FirstName==''|| con.SDR_Owner_Look_Up__r.FirstName==null?'':con.SDR_Owner_Look_Up__r.FirstName;
        string SDR_Owner_Last_Name = con.SDR_Owner_Look_Up__c==null  ?'': con.SDR_Owner_Look_Up__r.LastName==''|| con.SDR_Owner_Look_Up__r.LastName==null?'':con.SDR_Owner_Look_Up__r.LastName;
        string Referrer_First_Name = con.Referrer_First_Name__c==null || con.Referrer_First_Name__c=='' ?'': con.Referrer_First_Name__c;
        string Referrer_Last_Name = con.Referrer_Last_Name__c==null || con.Referrer_Last_Name__c=='' ?'': con.Referrer_Last_Name__c;
        string Referrer_Email_Number = con.Referrer_Email_Number__c==null || con.Referrer_Email_Number__c=='' ?'': con.Referrer_Email_Number__c;
        string Referrer_Phone_Number = con.Referrer_Phone_Number__c==null || con.Referrer_Phone_Number__c=='' ?'': con.Referrer_Phone_Number__c;
        string Referral_Indicator = con.Referral_Indicator__c==null || con.Referral_Indicator__c=='' ?'': con.Referral_Indicator__c;
        string Referring_Partner = con.Referring_Partner__c==null || con.Referring_Partner__c=='' ?'': con.Referring_Partner__c;
        string Referrer_Notes = con.Referrer_Notes__c==null || con.Referrer_Notes__c=='' ?'': con.Referrer_Notes__c;
        string website = con.account.website==null || con.account.website==''?'':con.account.website;
        string Use_Case = con.account.Use_Casenew__c==null || con.account.Use_Casenew__c=='' ?'': con.account.Use_Casenew__c;
        PageReference pr;
        if(con.Date_Referral_Submitted__c != null){
           Date d = con.Date_Referral_Submitted__c;
           conDates= d.month()+'/'+d.day()+'/'+d.year();
        }
        if(usr.BOFU_Wizard_Enabled__c){
               string urlRedirect ='/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&save_new_url=%2F006%2Fe%3FretURL%3D%252F006%252Fo&AccountId='+account_id+ '&conid='+con_id +'&StageName='+ System.Label.DefaultOppStage +'&LeadSource='+LeadSource+'&Lead_Source_Comments__c='+Lead_Source_Comments+'&Lead_Buying_Behavior__c='+ Buying_Behavior/*+'&Lead_Category__c='+Lead_Category*/+'&SDR_Owner__c='+SDR_Owner+'&Referrer_First_Name__c='+Referrer_First_Name+'&Referrer_Last_Name__c='+Referrer_Last_Name+'&Referrer_Email_Number__c='+Referrer_Email_Number +'&Referrer_Phone_Number__c='+con.Referrer_Phone_Number__c+'&Date_Referral_Submitted__c='+conDates+'&Referrer_Indicator__c='+Referral_Indicator+'&Referral_Partner__c='+Referring_Partner+'&Referrer_Notes__c='+ Referrer_Notes+'&website__c='+ website+'&Use_Case__c='+Use_Case; //'&CRM_System__c='+con.Account.CRM_System__c+
               pr = new PageReference(urlRedirect);
             
        }else{
             string urlRedirect ='/setup/ui/recordtypeselect.jsp?ent=Opportunity&retURL=%2F006%2Fo&save_new_url=%2F006%2Fe%3FretURL%3D%252F006%252Fo&opp4='+con.Account.Name+'&opp4_lkid='+account_id+ '&conid='+con_id +'&opp11='+ System.Label.DefaultOppStage +'&&opp6='+LeadSource+'&00N50000001ODYc='+Lead_Source_Comments+'&00N50000002OaYz='+ Buying_Behavior+/*'&00N50000002OaYp='+Lead_Category+*/'&CF00N50000002OpkH='+SDR_Owner_First_Name+' '+SDR_Owner_Last_Name+'&CF00N50000002OpkH_lkid='+SDR_Owner_id+'&00N50000001vhFu='+SDR_Owner+'&00N38000003MzY3='+Referrer_First_Name+'&00N38000003MzY5='+Referrer_Last_Name+'&00N38000003MzY2='+Referrer_Email_Number +'&00N38000003MzY7='+Referrer_Phone_Number+'&00N38000003MzY1='+conDates+'&00N38000003MzY4='+Referral_Indicator+'&00N50000002Pp1t='+Referring_Partner+'&00N38000003MzY6='+Referrer_Notes+'&00N50000002qOhq='+Use_Case;//'&00N50000001fTVE='+con.Account.CRM_System__c+
             pr  = new PageReference(urlRedirect);
        }
        
      return pr.setRedirect(true);
    }

}