/*
   Created Date: 4/09/2013
   Purpose: Accept a list of Accounts and map the New Business Account Executive for each account
*/
public class AssignNBAEPerRules {
   public static boolean ANFirstPass = False;
   public static Map<Id,Id> getAccountNBAE(List<Id> AcctIds)
   {
      Map <Id,Id> rNBAEMap = new Map <Id,Id>();
      Id currentCSM;
      List<Opportunity> OppList = [select AccountId, OwnerId from Opportunity 
           where AccountId in :AcctIds and Type='New Business'
           and StageName = 'Closed Won'
           order by AccountId desc, CloseDate asc];
      for (Opportunity opp : OppList){
         rNBAEMap.put(opp.AccountId, opp.OwnerId);
      }
      return rNBAEMap;
   }
}