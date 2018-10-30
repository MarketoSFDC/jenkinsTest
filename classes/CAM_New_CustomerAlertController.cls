/**************************************
* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     special_integration_needs__c,third_party_solutions__c,primary_marketo_user_experience_level__c,economic_decision_maker_experience_level__c,customer_reason_for_purchasing_marketo__c
                     Customer_s_near_term_goals__c,Customer_s_long_term_goals__c, non_standard_timing_requirements_details__c,special_integration_needs_details__c
                     third_party_solutions_details__c, additional_cam_notes__c

                    



**************************************/                     
public with sharing class CAM_New_CustomerAlertController {
    /* Query  ==>  Additional_CAM_Notes__c, Third_Party_Solutions_Details__c, Special_Integration_Needs_Details__c,Non_Standard_Timing_Requirements_Details__c,Customer_s_long_term_goals__c, Customer_s_near_term_goals__c,Customer_Reason_for_Purchasing_Marketo__c,Special_Integration_Needs__c,Third_Party_Solutions__c,Primary_Marketo_User_Experience_Level__c,Economic_Decision_Maker_Experience_Level__c,    */
    public string accId {get;set;}
    public opportunity getnewlyNBOpportunity(){
        List<Opportunity> OppList = new List<Opportunity>([Select ID,Sub_Start_Date__c, Economic_Decision_Maker__c, Non_Standard_Timing_Requirements__c,   Type, Createddate, name, StageName, Closedate FROM Opportunity Where AccountID =: accID AND Type = 'New Business' AND StageName = 'Closed Won' ORDER BY CloseDate DESC, CreatedDate DESC LIMIT 1]);
        if(!OppList.isEmpty()){
            return OppList[0];
        }
        else{
            return new Opportunity();
        }
    }
    public static testmethod void test() {
        Account acc=new account(name='accounttest',type='Prospect');
        insert acc;
        CAM_New_CustomerAlertController contr=new CAM_New_CustomerAlertController();
        contr.accId=acc.id;
        contr.getnewlyNBOpportunity();
    }
}