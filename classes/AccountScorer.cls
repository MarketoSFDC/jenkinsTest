/*
@Description: Function to evaluate the various rules to score on Account object
@Author: vishals@grazitti.com
*/

/**************************************************************
last modified by : Sumit Bhatt, Grazitti Interactive
last Modified Date : 13-April-2018
changes done: #APPS-10924# Remove functionality that is not needed for Account Score
Tracking : This class is completely commented as per the APPS-10924 ticket requirement 
**************************************************************/ 

public class AccountScorer{ /*
    public Decimal scoreOnRule{get;set;}
    public Account oldAccount;
    public Account newAccount;
    Map <String, Decimal> statesScoreMap;
    Map <String, String> statesRuleMap;
    String executionType;
    
    public Decimal accScore{get;set;}
    public String  accHistory{get;set;}
    
    private static boolean alreadyRunTrigger = false;
    
    public AccountScorer() {

    }
    
    public static boolean hasAlreadyRunTrigger() {
        return alreadyRunTrigger;
    }
    
    public static void setAlreadyRunTrigger() {
        alreadyRunTrigger = true;
    }  
      
    public void evaluateRule (String ruleGroupName, Map <String, Decimal> stScores, Map <String, String> stRuleMap, Account nAccount, String exectype) {
        //System.debug('XYZXY-->'+nAccount);
      
        newAccount = nAccount;

        statesScoreMap     = stScores;
        statesRuleMap      = stRuleMap;
        executionType      = exectype;  

        //System.debug(''+);
        Decimal ruleResult = 0;
        if (ruleGroupName == 'Rule Group 1') { 
            ruleGroup1();
        } else if (ruleGroupName == 'Rule Group 2') {
            ruleGroup2();          
        } else if (ruleGroupName == 'Rule Group 3') {
            ruleGroup3();          
        } else if (ruleGroupName == 'Rule Group 4') {
            ruleGroup4();          
        } else if (ruleGroupName == 'Rule Group 5') {
            ruleGroup5();          
        } else if (ruleGroupName == 'Rule Group 6') {
            ruleGroup6();          
        } else if (ruleGroupName == 'Rule Group 7') {
            ruleGroup7();          
        } else if (ruleGroupName == 'Rule Group 8') {
            ruleGroup8();          
        } else if (ruleGroupName == 'Rule Group 9') {
            ruleGroup9();          
        }
        //System.debug('XYZXY ruleResult-->'+ruleResult);
        //return ruleResult;
    }
    
    public void ruleGroup1() {
        String newState = 'Other CRM';
      
        DataSet categ1_crms = new DataSet(new Set<String>{'SalesForce','Salesforce.com'});
        DataSet categ2_crms = new DataSet(new Set<String>{'Microsoft CRM 2011', 'Microsoft CRM Online', 'Microsoft Dynamics'});       
        
        // Capture new state
        /*if (categ1_crms.partialMatch(newAccount.CRM_System__c)) {
            newState = 'Salesforce';
        } else if (categ2_crms.partialMatch(newAccount.CRM_System__c)) {
            newState = 'MS';            
        } *     

        //System.Debug('_NEW_STATE_'+newState);
        evaluateResult(newState);
    } 
       
    public void ruleGroup2() {

        String newState = 'Other + Other';

        DataSet tier1_mas    = new DataSet(new Set<String>{'eloqua', 'Aprimo', 'Unica'});
        DataSet tier2_mas    = new DataSet(new Set<String>{'Pardot', 'Act-On', 'ClickDimensions', 'Silverpop', 'HubSpot', 'Genius', 'CoreMotives', 'Manticore'});       
        DataSet desired_type = new DataSet(new Set<String>{'Customer','Customer & Partner'});
       
                
        Decimal smb_employees_limit = 1500;     

        // Capture new state
        if (tier1_mas.contains(newAccount.Current_MRM_MA_Solution__c) && typeOfCompany(newAccount, smb_employees_limit) == 'Enterprise' && !desired_type.contains(newAccount.Type)) {
            newState = 'TIER-1 MA + Enterprise';            
        } else if (tier1_mas.contains(newAccount.Current_MRM_MA_Solution__c) && typeOfCompany(newAccount, smb_employees_limit) == 'SMB' && !desired_type.contains(newAccount.Type)) {
            newState = 'TIER-1 MA + SMB';           
        } else if (tier1_mas.contains(newAccount.Current_MRM_MA_Solution__c) && typeOfCompany(newAccount, smb_employees_limit) == 'Other' && !desired_type.contains(newAccount.Type)) {
            newState = 'TIER-1 MA + Other';         
        } else if (tier2_mas.contains(newAccount.Current_MRM_MA_Solution__c) && typeOfCompany(newAccount, smb_employees_limit) == 'Enterprise' && !desired_type.contains(newAccount.Type)) {
            newState = 'TIER-2 MA + Enterprise';            
        } else if (tier2_mas.contains(newAccount.Current_MRM_MA_Solution__c) && typeOfCompany(newAccount, smb_employees_limit) == 'SMB' && !desired_type.contains(newAccount.Type)) {
            newState = 'TIER-2 MA + SMB';           
        } else if (tier2_mas.contains(newAccount.Current_MRM_MA_Solution__c) && typeOfCompany(newAccount, smb_employees_limit) == 'Other' && !desired_type.contains(newAccount.Type)) {
            newState = 'TIER-2 MA + Other';         
        } else if (typeOfCompany(newAccount, smb_employees_limit) == 'Enterprise' && !desired_type.contains(newAccount.Type)) {
            newState = 'Other + Enterprise';            
        } else if (typeOfCompany(newAccount, smb_employees_limit) == 'SMB' && !desired_type.contains(newAccount.Type)) {
            newState = 'Other + SMB';           
        } else if (typeOfCompany(newAccount, smb_employees_limit) == 'Other' && !desired_type.contains(newAccount.Type)) {
            newState = 'Other + Other';         
        }       
        
        //System.Debug('MA_SOL__'+tier2_mas.contains(newAccount.Current_MRM_MA_Solution__c)+' TYPE_'+typeOfCompany(newAccount, smb_employees_limit)+' DESIRED_'+desired_type.contains(newAccount.Type)); 

        //System.Debug('_NEW_STATE_'+newState+'NEW_ACCOUNT_'+newAccount.Current_MRM_MA_Solution__c);
        evaluateResult(newState);
    }

    public void ruleGroup3() {

        String newState = 'Country not USA + Canada + Top 13 EMEA';
      
        DataSet countries = new DataSet(new Set<String>{'United States','United States of America','US','USA','U.S.','U.S.A.','Canada','CA','Israel','Netherlands','Sweden','Belgium','Finland','Spain','Switzerland','Ireland','Germany','France','United Kingdom','Norway','South Africa','IL','NL','SE','BE','FI','ES','CH','IE','DE','FR','DE','UK','NO','ZA'});

        // Capture new state
        if (countries.contains(newAccount.BillingCountry)) {
           newState = 'Country USA + Canada + Top 13 EMEA';                
        }

        //System.Debug('_NEW_STATE_'+newState);

        evaluateResult(newState);
    }

    public void ruleGroup4() {

        String newState = 'Non Tech Center';

        Set <String> techcenterAreaCodes = new Set<String>{'408','1408','(408','1-408','1.408','1 408','+1408','+1-408','+1 408','415','1415','(415','1-415','1.415','1 415','+1415','+1.415','+1-415','+1 415','650','1650','(650','1-650','1.650','1 650','+1650','+1.650','+1-650','+1 650','617','1617','(617','1-617','1.617','1 617','+1617','+1.617','+1-617','+1 617','404','1404','(404','1-404','1.404','1 404','+1404','+1.404','+1-404','+1 404','512','1512','(512','1-512','1.512','1 512','+1512','+1.512','+1-512','+1 512','919','1919','(919','1-919','1.919','1 919','+1919','+1.919','+1-919','+1 919','212','1212','(212','1-212','1.212','1 212','+1212','+1.212','+1-212','+1 212','916','1916','(916','1-916','1.916','1 916','+1916','+1.916','+1-916','+1 916','416','1416','(416','1-416','1.416','1 416','+1416','+1.416','+1-416','+1 416','425','1425','(425','1-425','1.425','1 425','+1425','+1.425','+1-425','+1 425','781','1781','(781','1-781','1.781','1 781','+1781','+1.781','+1-781','+1 781','925','1925','(925','1-925','1.925','1 925','+1925','+1.925','+1-925','+1 925','206','1206','(206','1-206','1.206','1 206','+1206','+1.206','+1-206','+1 206','510','1510','(510','1-510','1.510','1 510','+1510','+1.510','+1-510','+1 510','512','1512','(512','1-512','1.512','1 512','+1512','+1.512','+1-512','+1 512','503','1503','(503','1-503','1.503','1 503','+1503','+1.503','+1-503','+1 503','603','1603','(603','1-603','1.603','1 603','+1603','+1.603','+1-603','+1 603','703','1703','(703','1-703','1.703','1 703','+1703','+1.703','+1-703','+1 703','707','1707','(707','1-707','1.707','1 707','+1707','+1.707','+1-707','+1 707'};

        // Capture new state
        //System.Debug('NPHONE__'+newAccount.Global_HQ_Phone_Number__c+' '+newAccount.Phone+' '+newAccount.Phone_Number__c+' '+newAccount.Inferred_Phone_Area_Code__c);
        if (customStartsWith(newAccount.Phone, techcenterAreaCodes)) {
            newState = 'Tech Center';
        }

        //System.Debug('_NEW_STATE_'+newState);

        evaluateResult(newState);

    } 
       
    public void ruleGroup5() {

        String newState = 'Not Competitor of Customer';

        DataSet typeOfAccount = new DataSet(new Set <String>{'customer', 'Customer & Partner'});

        // Capture new state
        //System.Debug('NNAME_OF_COMPETITOR__'+newAccount.Name_of_Competitor__c);
        if (newAccount.Competes_with_Current_Marketo_Customer__c!= null && !typeOfAccount.contains(newAccount.Type)){
            newState = 'Competitor of Customer';
        }      

        //System.Debug('_NEW_STATE_'+newState);

        evaluateResult(newState);
                                
    }
    
    public void ruleGroup6() {

        String newState = 'Other';
        
        // Capture new state
        //System.Debug('NNAME_OF_ESP__'+newAccount.Current_ESP_Solution__c);
        if (newAccount.Current_ESP_Solution__c == 'Lyris'){
            newState = 'Lyris';
        } else if(newAccount.Current_ESP_Solution__c == 'MailChimp') {
            newState = 'MailChimp';         
        } else if(newAccount.Current_ESP_Solution__c == 'Constant Contact') {
            newState = 'Constant Contact';          
        } else if(newAccount.Current_ESP_Solution__c == 'ExactTarget') {
            newState = 'ExactTarget';           
        }       

        //System.Debug('_NEW_STATE_'+newState);

        evaluateResult(newState);
                                
    }
        
    public void ruleGroup7() {

        String newState = 'No longer Top 15 target industry';

        DataSet desiredSiteDesc = new DataSet(new Set <String>{'Custom Computer Programming Services','Prepackaged software','Business Services','Management Consulting Services','Computer Related Services','Telephone Communication, Except Radio','Computers,Peripherals and Software','Computer Integrated Systems Design','Information Retrieval Services','Management Services','Business Consulting','Data Processing and Preparation','Radio and T.v. Communications Equipment','Semiconductors and Related Devices','Communication Services'});
        DataSet desiredNaics    = new DataSet(new Set <String>{'Custom Computer Programming Services','Software Publishers','Computer Systems Design Services','All Other Support Services','Computer and Computer Peripheral Equipment and Software Merchant Wholesalers','Administrative Management and General Management Consulting Services','All Other Telecommunications','Wired Telecommunications Carriers','All Other Business Support Services','Office Administrative Services','Data Processing, Hosting, Related Services','Semiconductor and Related Device Manufacturing','Radio and Television Broadcasting and Wireless Communications Equipment Manufacturing','Other Management Consulting Services','Analytical Laboratory Instrument Manufacturing'});

        // Capture new state
        //System.Debug('SiteDesc '+newAccount.SicDesc+' NAICS '+newAccount.NAICS_Name__c);
        if (desiredSiteDesc.contains(newAccount.SicDesc) || desiredNaics.contains(newAccount.NAICS_Name__c)) {
            newState = 'Top 15 target industry';
        }      

        //System.Debug('_NEW_STATE_'+newState);

        evaluateResult(newState);
                                
    }
    public void ruleGroup8() {

        String newState = 'Has no target keywords';

        DataSet desiredSiteDesc    = new DataSet(new Set <String>{'Computer','equipment','Business Services'});
        DataSet nonDesiredSiteDesc = new DataSet(new Set <String>{'Custom Computer Programming Services','Prepackaged Software','Business Services','Management Consulting Services','Computer Related Services','Telephone Communication, Except Radio','Computers, Peripherals and Software','Computer Integrated Systems Design','Information Retrieval Services','Management Services','Business Consulting','Data Processing and Preparation','Radio and T.v. Communications Equipment','Semiconductors and Related Devices','Communication Services'});
        DataSet desiredNaics       = new DataSet(new Set <String>{'Manufacturing','Equipment','Computer','Wholesalers','Merchant','Business Services'});
        DataSet nonDesiredNaics    = new DataSet(new Set <String>{'Custom Computer Programming Services','Software Publishers','Computer Systems Design Services','All Other Support Services','Computer and Computer Peripheral Equipment and Software Merchant Wholesalers','Administrative Management and General Management Consulting Services','All Other Telecommunications','Wired Telecommunications Carriers','All Other Business Support Services','Office Administrative Services','Data Processing, Hosting, Related Services','Semiconductor and Related Device Manufacturing','Radio and Television Broadcasting and Wireless Communications Equipment Manufacturing','Other Management Consulting Services','Analytical Laboratory Instrument Manufacturing'});

        // Capture new state
        //System.Debug('SiteDesc '+newAccount.SicDesc+' NAICS '+newAccount.NAICS_Name__c);
        if (
            (desiredSiteDesc.partialMatch(newAccount.SicDesc) || desiredNaics.partialMatch(newAccount.NAICS_Name__c)) &&
            !nonDesiredSiteDesc.contains(newAccount.SicDesc) &&
            !nonDesiredNaics.contains(newAccount.NAICS_Name__c)         
        ) {
            newState = 'Has target keywords';
        }      

        //System.Debug('_NEW_STATE_'+newState);

        evaluateResult(newState);
                                
    }
    public void ruleGroup9() {
    
        String newState = 'Jigsaw no match';
       //CHange Requested by kim Stites on Jan 22-2013
    /*    DataSet desiredJigsaw = new DataSet(new Set<String>{'Matching','Different'});
        
        // Capture new state
        //System.Debug('newJigsaw '+newAccount.jigsaw_clean__Sync_Status_Summary__c);
        if (desiredJigsaw.partialMatch(newAccount.jigsaw_clean__Sync_Status_Summary__c)) {
            newState = 'Jigsaw match';
        }
        
        //System.Debug('_NEW_STATE_'+newState);
        
        evaluateResult(newState);
    
    } 
    
    public void evaluateResult(String newState) {
    
        if (executionType == 'create') {
            //newAccount.Account_Score_History__c += statesRuleMap.get(newState)+': '+ String.valueOf(statesScoreMap.get(newState)) + '<br/>';
            accScore   = statesScoreMap.get(newState);
            accHistory = statesRuleMap.get(newState)+': '+ String.valueOf(statesScoreMap.get(newState)) + '<br/>';
            //System.debug('statesScoreMap.get(newState)CREATE-->'+statesScoreMap.get(newState)+'STATE'+newState);
            //return statesScoreMap.get(newState);
        } else {
            accScore   = statesScoreMap.get(newState);
            accHistory = statesRuleMap.get(newState)+': '+ String.valueOf(statesScoreMap.get(newState)) + '<br/>';
        }        
    }

    public String typeOfCompany(Account account, Decimal employeelimit) {  // RuleGroup2 helper
        if (
            (account.Hoovers_Employee_Number__c > employeelimit) || 
            (account.Global_Number_of_Employees__c > employeelimit && account.Hoovers_Employee_Number__c == null) ||
            (account.NumberOfEmployees > employeelimit && account.Global_Number_of_Employees__c == null && account.Hoovers_Employee_Number__c == null)
        ) {
            return 'Enterprise';
        } else if (
            (account.Hoovers_Employee_Number__c < employeelimit+1) || 
            (account.Global_Number_of_Employees__c < employeelimit+1 && account.Hoovers_Employee_Number__c == null) ||
            (account.NumberOfEmployees < employeelimit+1 && account.Global_Number_of_Employees__c == null && account.Hoovers_Employee_Number__c == null)        
        ) {
            return 'SMB';           
        } else {
            return 'Other';
        }
    }
    
    public Boolean customStartsWith (String target, Set<String> subjectSet) { // RuleGroup4 Helper

        if (target == null) return false;
        //System.Debug('__subjectSet__'+subjectSet);
        for (String subject:subjectSet) {
            //System.Debug('__subject__'+subject);
            if (target.startsWith(subject)) {
                return true;
            }
        }
        return false;
    }
    
    public class DataSet{
        public Set <String> data;
        public DataSet(Set<String> dataSet){
            data = new Set<String>();
            for(String setVal:dataSet) {
                data.add(setVal.toLowerCase());    
            }
        }
        public boolean contains(String pattern) {
            if(pattern == null){
                return false;
            } else {
                return data.contains(pattern.toLowerCase());
            }
        }
        
        public boolean partialMatch(String pattern) {
             if(pattern == null){
                return false;
             } else {
                 for(String dataVal:data) {
                     //System.debug('kp==== '+pattern+'kp==== '+dataVal);
                     if(pattern.toLowerCase().contains(dataVal)) {
                         return true;
                     }
                 }
                 return false;
             }
        }
    } */ 
}