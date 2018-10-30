/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
@isTest(seealldata=true)
public class UpdateCLSOnAccountFromClzProject_Test{
    
	/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		public static testMethod void SearchRecord1(){
			List<clzV5__Clarizen_Project__c> CLZList = new List<clzV5__Clarizen_Project__c>();
			for(clzV5__Clarizen_Project__c clz : [SELECT Id, clzV5__CLZ_State__c, Project_Type_Name__c, clzV5__CLZ_ProjectType__c, clzV5__CLZ_Parent__c, clzV5__CLZ_Parent__r.Project_Type_Name__c, clzV5__CLZ_Parent__r.clzV5__CLZ_ProjectType__c from clzV5__Clarizen_Project__c WHERE clzV5__CLZ_Parent__r.Project_Type_Name__c = 'Opportunity Level Project' and clzV5__CLZ_Parent__r.clzV5__CLZ_ProjectType__c = 'OPPTY' limit 1]){
				clzV5__Clarizen_Project__c pclz = new clzV5__Clarizen_Project__c(Id = clz.clzV5__CLZ_Parent__c);
				pclz.Fillout_Form_Count_Avg_Last_26_Weeks__c=123;
				CLZList.add(pclz);
			}
			if(!CLZList.isEmpty()){
				update CLZList;
			}
		}
	********************************************************************************************************************* */
}