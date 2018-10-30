public class Trigger_CSM_Handler {
	public static void beforeInsertHandler(List<CSM_Ticket__c> newList, Map<Id,CSM_Ticket__c> newMap)
		{
			for(CSM_Ticket__C ticket :newList)
				{
                ticket.Account__c = ticket.Bizible_Account_Id__c;
				}
		}
  }