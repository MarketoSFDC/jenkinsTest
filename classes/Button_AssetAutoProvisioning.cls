/* ********************************************************************************************************************
 * Created this class to Send Subscriptions along with Assets to SPA system.
 * Created Date: Sept 21, 2016
 * Created By: Jade Team
 * *******************************************************************************************************************/
/* *******************************************************************************************************************
 * Last Modified By: Priyanka Shende, on 19th July 2017
 * Purpose         : Created method to send case to Provisioning and Invoked this method from Case Send to Provision Button.
 * ******************************************************************************************************************* */ 
global class Button_AssetAutoProvisioning {
    
    webservice static void callAssetAutoProvisioning(Id assetId){ 
      List<Id> astId=new List<Id>();
      if(assetId!=null){
        astId.add(assetId);
      }
      AssetAutoProvisioning.processAssetAutoProvisioningBatch(astId);
   }
   webservice static void callCaseAutoProvisioning(Id caseId){ 
      system.debug('######## caseId'+caseId);
      List<Id> CaseIdlist=new List<Id>();
      if(CaseId!=null){
        CaseIdlist.add(caseId);
      }
      system.debug('CaseIdlist ############'+CaseIdlist);
      CaseAutoProvisioning.processCaseAutoProvisioningBatch(CaseIdlist);
   }
}