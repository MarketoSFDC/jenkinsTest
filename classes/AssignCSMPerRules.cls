/*
   Created Date: 3/31/2013
   Purpose: Accept a list of Accounts and for each account, update the CSM based on assignment rules
*/
public class AssignCSMPerRules {
   public static boolean ARFirstPass = False;
   public static Map<Id,Id> getAccountCSM(List<Account> Accts)
   {
	// **************** COMMENTING THE BELOW CODE AS Customer_Success_Manager__c IS DELETED ************ //   
	Map<Id,Id> emptyMap = new Map<Id,Id>();
	/*	
      Set <String> Zip5Set = new Set<String>();
      Set <String> BusinessUnitSet = new Set<String>();
      Set <String> CountrySet = new Set<String>();
      Set <String> StateSet = new Set<String>();
      Boolean result;
      
      for (Account a : Accts){
         if (a.BillingPostalCode <> 'n/a' && a.BillingPostalCode <> null) {result = Zip5Set.add(a.BillingPostalCode.left(5));}
         if (a.business_unit__c <> 'n/a' && a.business_unit__c <> null) {result = BusinessUnitSet.add(a.business_unit__c);}
         if (a.billingstate <> 'n/a' && a.billingstate <> null) {result = StateSet.add(a.billingstate);}
         if (a.billingcountry <> 'n/a' && a.billingcountry <> null) {result = CountrySet.add(a.billingcountry);}
      }
      //system.debug('####'+Zip5Set);

      Map<String,Id> ARuleBUmap = new Map<String,Id>();
      for (Assignment_Rule__c arb : [select Id, business_Unit__c, User__c from Assignment_Rule__c
          where Rule_Name__c = 'Account CSM Assignment' and business_unit__c in :BusinessUnitSet
          and Country__c = 'n/a' and Country_Code__c = 'n/a' and
          State__c = 'n/a' and State_Code__c = 'n/a' and Zip5__c = 'n/a']){
         ARuleBUmap.put(arb.business_unit__c, arb.User__c);
      }
      List<Assignment_Rule__c> arcList = [select Id, Business_Unit__c, Country__c, Country_Code__c, User__c from Assignment_Rule__c
          where Rule_Name__c = 'Account CSM Assignment' and (Country__c in :CountrySet or Country_Code__c in :CountrySet)
          and State__c = 'n/a' and State_Code__c = 'n/a' and Zip5__c = 'n/a'];
      Map<String,Map<String,Id>> ARuleCountrymap = new Map<String,Map<String,Id>>();
      for (Assignment_Rule__c arco : arcList){
         Map <String,Id> ARuleCountryInnermap = new Map<String,Id>();
         for (Assignment_Rule__c arci : arcList){
            ARuleCountryInnermap.put(arci.Country__c, arci.User__c);
            ARuleCountryInnermap.put(arci.Country_Code__c, arci.User__c);
         }
         ARuleCountrymap.put(arco.Business_Unit__c, ARuleCountryInnermap);
      }
      List<Assignment_Rule__c> arsList = [select Id, Business_Unit__c, State__c, State_Code__c, User__c from Assignment_Rule__c
          where Rule_Name__c = 'Account CSM Assignment' and (State__c in :StateSet or State_Code__c in :StateSet)
          and Zip5__c = 'n/a'];
      Map<String,Map<String,Id>> ARuleStatemap = new Map<String,Map<String,Id>>();
      for (Assignment_Rule__c arso : arsList){
         Map <String,Id> ARuleStateInnermap = new Map<String,Id>();
         for (Assignment_Rule__c arsi : arsList){
            ARuleStateInnermap.put(arsi.State__c, arsi.User__c);
            ARuleStateInnermap.put(arsi.State_Code__c, arsi.User__c);
         }
         ARuleStatemap.put(arso.Business_Unit__c, ARuleStateInnermap);
      }
      List<Assignment_Rule__c> arzList = [select Id, Business_Unit__c, Zip5__c, User__c from Assignment_Rule__c
          where Rule_Name__c = 'Account CSM Assignment' and Zip5__c in :Zip5set];
      Map<String,Map<String,Id>> ARuleZip5map = new Map<String,Map<String,Id>>();
      for (Assignment_Rule__c arzo : arzList){
         Map <String,Id> ARuleZip5Innermap = new Map<String,Id>();
         for (Assignment_Rule__c arzi : arzList){
            ARuleZip5Innermap.put(arzi.Zip5__c, arzi.User__c);
         }
         ARuleZip5map.put(arzo.Business_Unit__c, ARuleZip5Innermap);
      }
      List <Assignment_Rule__c> ARuledflt = [select User__c from Assignment_Rule__c where Rule_Name__c = 'Account CSM Assignment' and
         business_Unit__c = 'n/a' and Country_Code__c = 'n/a' and Country__c = 'n/a' and State__c = 'n/a' and 
         State_Code__c = 'n/a' and Zip5__c = 'n/a' limit 1];
      List <Account> ParentCSMList = [select Id, parent.Customer_Success_Manager__c from Account where id in :Accts];

      Map<Id, Id> ParentCSMMap = new Map<id,Id>();
      Map <Id,Id> rCSMMap = new Map <Id,Id>();
      String catchallCSM;
      Id parent_CSM1;
      Id Parent_CSM;
      Id currentCSM;
      String Zip5;

      if (Aruledflt.size() > 0){
         catchallCSM = Aruledflt[0].User__c;
      }
	
      for (Account ac : ParentCSMList){
         Parent_CSM1 = ac.parent.Customer_Success_Manager__c;
         ParentCSMMap.put(ac.Id, Parent_CSM1);
      }
	
      for (Account acc : Accts) {
         //Parent_CSM = ParentCSMMap.get(acc.Id);
         currentCSM = acc.Customer_Success_Manager__c;
         //system.debug('L@@P0'+currentCSM);

         if (acc.ParentId <> null && currentCSM == null && Parent_CSM <> null) {
            currentCSM = Parent_CSM;
            //system.debug('L@@P1'+currentCSM);
         } else
         if (currentCSM == null && acc.business_unit__c <> 'n/a' && acc.business_unit__c <> null && ARuleBUmap.get(acc.business_unit__c) <> null) {
            currentCSM = ARuleBUmap.get(acc.business_unit__c);
            //system.debug('L@@P2'+currentCSM);
         } else
         if (currentCSM == null && acc.BillingPostalCode <> 'n/a' && acc.BillingPostalCode <> null && ARuleZip5map.get(acc.business_unit__c.left(4)) <> null) {
            if (ARuleZip5map.get(acc.business_unit__c.left(4)).get(acc.billingpostalcode.left(5)) <> null) {
               currentCSM = ARuleZip5map.get(acc.business_unit__c.left(4)).get(acc.billingpostalcode.left(5));
            //system.debug('L@@P3'+currentCSM);
            }
         } else
         if (currentCSM == null && acc.billingstate <> 'n/a' && acc.billingstate <> null && ARuleStatemap.get(acc.business_unit__c) <> null) {
            if (ARuleStatemap.get(acc.business_unit__c).get(acc.billingstate) <> null) {
               currentCSM = ARuleStatemap.get(acc.business_unit__c).get(acc.billingstate);
            //system.debug('L@@P4'+currentCSM);
            }
         } else
         if (currentCSM == null && acc.billingcountry <> 'n/a' && acc.billingcountry <> null && ARuleCountrymap.get(acc.business_unit__c) <> null) {
            if (ARuleCountrymap.get(acc.business_unit__c).get(acc.billingcountry) <> null) {
               currentCSM = ARuleCountrymap.get(acc.business_unit__c).get(acc.billingcountry);
            //system.debug('L@@P5'+currentCSM);
            }
         } else
         if (catchallCSM <> null) {
            currentCSM = catchallCSM;
            //system.debug('L@@P6'+currentCSM);
         }
         rCSMMap.put(acc.Id, currentCSM);
         currentCSM = null;
      }
      return rCSMMap;
	  */
	  return emptyMap;
   }
}