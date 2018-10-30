/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :ShareUtilities
**************************************************************************************************************************************/
public class ShareUtilities  {

/*************************************************************************
Please note that the Share Utilities can be enabled or disabled 
by updating the custom setting Triggers field disableShareUtilities

**************************************************************************/ 
 
    

	// AddLimitedSharingSettingsforResource - Adds Project Share and Assignment Share permissions 
	// for the Project / Associated Assignments for the ID's passed
    @future
	public static void AddLimitedSharingSettingsforResource(String ProjectId, Set<Id> Ids)
	{

		pse__Triggers__c PT = pse__Triggers__c.getInstance();
		if(!PT.disableShareUtilities__c)
		{
			List<SObject> Shares = new List<SObject>();

			List<Id> ShareRecordIds = new List<Id>();
			List<sObject> newShareRecordsProjects = new List<sObject>();
			List<sObject> newShareRecordsAssignments = new List<sObject>();

			ShareRecordIds.add(ProjectId);

        
			// Grab relevant project and assignment records if the User is not the owner of that record and create a share record for them.
			for (Id UserId: Ids)
			{
				for (SObject sob : [Select Id from Pse__Proj__c where Id =: ProjectId AND Ownerid !=: UserId])
				{
					if (sob.get('Id') != null)
					{
						if (UserId != null) newShareRecordsProjects.addAll(createShareRecords(UserId,ProjectId,'Pse__Proj__Share','Edit'));
					}
				}

                for (sObject sob : [Select id,ResourceSalesforceID__c from Pse__Assignment__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId AND ResourceSalesforceID__c != null])
                {
                    if (UserId == sob.get('ResourceSalesforceID__c'))
					{
						if (sob.get('Id') != null)
						{           
							if (UserId != null) newShareRecordsAssignments.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Assignment__Share','Edit'));
						}
					}
                }
			
			}
		
			Database.insert(newShareRecordsProjects,false);
			Database.insert(newShareRecordsAssignments,false);
		}

		
	}
    
    // Same as method above except without future context to be run from batch.
    public static void AddLimitedSharingSettingsforResourceBatchMode(String ProjectId, Set<Id> Ids)
    {

        pse__Triggers__c PT = pse__Triggers__c.getInstance();
        if(!PT.disableShareUtilities__c)
        {
            List<SObject> Shares = new List<SObject>();

            List<Id> ShareRecordIds = new List<Id>();
			List<sObject> newShareRecordsProjects = new List<sObject>();
			List<sObject> newShareRecordsAssignments = new List<sObject>();

            ShareRecordIds.add(ProjectId);

        
            // Grab relevant project and assignment records if the User is not the owner of that record and create a share record for them.
            for (Id UserId: Ids)
            {
                for (sObject sob : [Select Id from Pse__Proj__c where Id =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {
                        if (UserId != null) newShareRecordsProjects.addAll(createShareRecords(UserId,ProjectId,'Pse__Proj__Share','Edit'));
                    }
                }

                for (sObject sob : [Select id,ResourceSalesforceID__c from Pse__Assignment__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId AND ResourceSalesforceID__c != null])
                {
                    if (UserId == sob.get('ResourceSalesforceID__c'))
					{
						if (sob.get('Id') != null)
						{           
							if (UserId != null) newShareRecordsAssignments.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Assignment__Share','Edit'));
						}
					}
                }
            
            }
        
			Database.insert(newShareRecordsProjects,false);
			Database.insert(newShareRecordsAssignments,false);
        }

        
    }   


    // RemoveAllSharingSettingsForProjectUser - Used when a user is removed from a Project. Goes through all related sharing records and removes the
    // associated shares.
        
    @Future
    public static void RemoveAllSharingSettingsForProjectUser(String ProjectId, Set<Id> Ids)
    {
        pse__Triggers__c PT = pse__Triggers__c.getInstance();
        if(!PT.disableShareUtilities__c)
        {        
            // Establish lists and names of the sObjects to be referenced
            List<SObject> deleteShareRecords = new List<SObject>();
            String sObjectNames = 'Pse__Proj__Share,Pse__Milestone__Share,Pse__Project_Task__Share,Pse__Budget__Share,Pse__Resource_Request__Share,Pse__Assignment__Share,Pse__Timecard_Header__Share,Pse__Expense_Report__Share,Pse__Expense__Share';
            Set<Id> ShareParentIds = new Set<Id>();

            // Loop through the User IDs provided and add them to the list of records to remove access for (assuming they are not owner of the record)
            for (Id UserId: Ids)
            {
                for (sObject sob : [Select Id from Pse__Proj__c where Id =: ProjectId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }

                for (sObject sob : [Select Id from Pse__Milestone__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
        
                for (sObject sob : [Select id from Pse__Project_Task__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
                for (sObject sob : [Select Id from Pse__Budget__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
                for (sObject sob : [Select Id from Pse__Resource_Request__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
                for (sObject sob : [Select id from Pse__Assignment__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
                for (sObject sob : [Select Id from Pse__Timecard_Header__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
                for (sObject sob : [Select Id from Pse__Expense_Report__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }
                for (sObject sob : [Select Id from Pse__Expense__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null) ShareParentIds.add(String.valueOf(sob.get('Id')));
                }       
        
            
                // Generate SOQL statement and delete the unneeded share records
                for (string sObjectName: sObjectNames.split(','))
                {
                    String SOQL = 'Select Id from ' + sObjectName + ' where parentId IN: ShareParentIds AND UserOrGroupId =: UserId AND RowCause = \'Manual\'';
                    deleteShareRecords.addAll(Database.query(SOQL));
                }

                Delete deleteShareRecords;
            } 
        }
        
    }

    // SetAllSharingSettingsForProject - Add sharing records for the project and its child records for the user IDs passed.
    @Future
    public static void SetAllSharingSettingsForProject(String ProjectId,Set<Id> Ids) //String UserId)
    {
        pse__Triggers__c PT = pse__Triggers__c.getInstance();
        if(!PT.disableShareUtilities__c)
        {       
            // Set up Lists
            List<SObject> Shares = new List<SObject>();

            List<Id> ShareRecordIds = new List<Id>();
            List<SObject> newShareRecords = new List<SObject>();

            ShareRecordIds.add(ProjectId);

            // Loop through ID's and generate sharing records       
            for (Id UserId: Ids)
            {

                for (sObject sob : [Select Id from Pse__Proj__c where Id =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,ProjectId,'Pse__Proj__Share','Edit'));
                    }
                }


                for (sObject sob : [Select Id from Pse__Milestone__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Milestone__Share','Edit'));
                    }
                }

                for (sObject sob : [Select id from Pse__Project_Task__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Project_Task__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Budget__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Budget__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Resource_Request__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Resource_Request__Share','Edit'));
                    }
                }
                for (sObject sob : [Select id from Pse__Assignment__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Assignment__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Timecard_Header__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Timecard_Header__Share','Edit'));
                    }
                }
        
                for (sObject sob : [Select Id from Pse__Expense_Report__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Expense_Report__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Expense__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Expense__Share','Edit'));
                    }
                }
            }

            Database.insert(newShareRecords,false);
        }
    }

    // Same as method above but without @future method to be run from batch scripts if needed
    public static void SetAllSharingSettingsForProjectBatchMode(String ProjectId,Set<Id> Ids) //String UserId)
    {
        pse__Triggers__c PT = pse__Triggers__c.getInstance();
        if(!PT.disableShareUtilities__c)
        {       
            // Set up Lists
            List<SObject> Shares = new List<SObject>();

            List<Id> ShareRecordIds = new List<Id>();
            List<SObject> newShareRecords = new List<SObject>();

            ShareRecordIds.add(ProjectId);

            // Loop through ID's and generate sharing records       
            for (Id UserId: Ids)
            {

                for (sObject sob : [Select Id from Pse__Proj__c where Id =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,ProjectId,'Pse__Proj__Share','Edit'));
                    }
                }


                for (sObject sob : [Select Id from Pse__Milestone__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Milestone__Share','Edit'));
                    }
                }

                for (sObject sob : [Select id from Pse__Project_Task__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Project_Task__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Budget__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Budget__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Resource_Request__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Resource_Request__Share','Edit'));
                    }
                }
                for (sObject sob : [Select id from Pse__Assignment__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Assignment__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Timecard_Header__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Timecard_Header__Share','Edit'));
                    }
                }
        
                for (sObject sob : [Select Id from Pse__Expense_Report__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Expense_Report__Share','Edit'));
                    }
                }
                for (sObject sob : [Select Id from Pse__Expense__c where pse__Project__c =: ProjectId AND Ownerid !=: UserId])
                {
                    if (sob.get('Id') != null)
                    {           
                        if (UserId != null) newShareRecords.addAll(createShareRecords(UserId,String.valueOf(sob.get('Id')),'Pse__Expense__Share','Edit'));
                    }
                }
            }

            Database.insert(newShareRecords,false);
        }
    }

    // createShareRecords - Helper to generate the share records.
    public static List<SObject> createShareRecords(String UserId, String RecordId, String sObjectName, String AccessLevel)
    {
       
        // Create sObject Dynamically based on sObjectName string
        SObjectType stype = Schema.getGlobalDescribe().get(sObjectName);
        
        sObject share1 = stype.newSObject();
        // Create the Share Record
        List<SObject> shares = new List<SObject>();
        
        share1.put('AccessLevel',AccessLevel);
        share1.put('parentId',RecordId);
        share1.put('UserOrGroupId',UserId);
        shares.add(share1);

        return shares;
        
    }

    // removeShareRecords - Helper to remove specific share record.
    public static List<SObject> removeShareRecords(String UserId, String RecordId, String sObjectName)
    {
        
        String dquery = 'Select Id from ' + sObjectName + ' where parentId =: RecordId AND UserOrGroupId =: UserId';
        List<SObject> sobs = Database.query(dquery);
        return sobs;
    }

}