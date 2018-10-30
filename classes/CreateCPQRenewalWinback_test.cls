/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :19th May 2018
Apex Class    :Test Class of CreateCPQRenewalWinback
**************************************************************************************************************************************/
@isTest
public class CreateCPQRenewalWinback_test {
      @testSetup static void methodName() {
      List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<Contract> contract_list = TestCPQUtilityClass.createContracts(acc_list, 1);
        insert acc_list; 
        insert contact_list;
        contract_list[0].Accountid=acc_list[0].id;
        contract_list[0].StartDate=System.today().adddays(-3);
        contract_list[0].ContractTerm=12;
        insert Contract_List;
        User newManager =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testManagerUser', 'Mkto', 'cfsId');
        newManager.isActive=true;
        //insert newManager;
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfIds');
        newUser.isActive=true;
        newUser.Managerid=UserInfo.getUserId();
        insert newUser;
        opp_list[0].SBQQ__RenewedContract__c=Contract_List[0].id;
        opp_list[0].StageName='Not Contacted';
        opp_list[0].Ownerid=newUser.id;
        opp_list[0].Is_Winback_Created__c=false;
        insert opp_list;
    }
    @isTest static void CreateCPQRenewalWinbk() {
     List<opportunity> opp_list=[Select id,Name,SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.EndDate,owner.isActive,owner.ManagerId,owner.Manager.isActive,Is_Winback_Created__c from Opportunity];
     //id OpportunityId= Opp_list[0].id;
     CreateCPQRenewalWinback.GetWinBackOpportunity(Opp_list[0].id);
    }
    }