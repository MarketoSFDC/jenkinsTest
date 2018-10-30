public class RS_Utilities  {

	// Clone budgets from one project and parent them to another
    public static List<pse__Budget__c> reParentBudgets(String fromProjectId, String toProjectId)
    {
         List<pse__Budget__c> Budgets = Database.query(RS_Utilities.SelectAllSOQL('pse__Budget__c','pse__Project__c',fromProjectId,'',null));

         List<pse__Budget__c> newBudgets = new List<pse__Budget__c>();
         for (pse__Budget__c Budget:Budgets)
         {
            pse__Budget__c newBudget = Budget.clone(false,false,false,false);
            newBudget.pse__Project__c = toProjectId;
            newBudget.pse__Expense_Transaction__c = null;
            newBudget.pse__Pre_Billed_Transaction__c = null;
            newBudget.pse__Transaction__c = null;
            System.debug(newBudget);
            newBudgets.add(newBudget);
         }
         
         Insert newBudgets;
         return Budgets;    
    }

	//Clone Milestones from one project and add them to another.
    public static List<pse__Milestone__c> CloneMilestones(String fromProjectId, String toProjectId)
    {
         List<pse__Milestone__c> Milestones = Database.query(SelectAllSOQL('pse__Milestone__c','pse__Project__c',fromProjectId,'',''));
         List<pse__Milestone__c> newMilestones = new List<pse__Milestone__c>();
         for (pse__Milestone__c Milestone:Milestones)
         {
            pse__Milestone__c newMilestone = Milestone.clone(false,false,false,false);
            newMilestone.pse__Project__c = toProjectId;
            newMilestone.clonedFromId__c = Milestone.Id;
            newMilestones.add(newMilestone);
         }
         
         Insert newMilestones;
          //Added byJade Global to create task for cloned Milestone
            for(pse__Milestone__c milStone: newMilestones){
                 RS_Utilities.populateProjectFromTemplate(milStone.Template_ID__c,milStone.pse__Project__c,milStone.Id,Milstone.CurrencyIsoCode);
            }


         /*
         List<pse__Project_Task__c> newProjectTasks = [Select id,pse__Milestone__c,pse__Project__c from pse__Project_Task__c where pse__Milestone__c =: toProjectId];
         
         if (newProjectTasks.size()==0) 
         {
             List<pse__Resource_Request__c> newResourceRequests = new List<pse__Resource_Request__c>();
             for (pse__Milestone__c Milestone:newMilestones)
             {
                  System.debug('MS: ' + Milestone.clonedFromId__c + 'MSID : ' + Milestone.Id + ' PRojID ' + toProjectId);
                  newProjectTasks.addAll(RS_Utilities.reParentProjectTasks2Milestone(Milestone.clonedFromId__c, Milestone.Id, toProjectId));
                  newResourceRequests.addAll(RS_Utilities.reParentResourceRequests2Milestone(Milestone.clonedFromId__c, Milestone.Id,toProjectId));
             }

             Update newProjectTasks;
             Update newResourceRequests;
         }
         */
         return Milestones;
    }

	// Change the Milstone and Project assigned to Resource requests found on the From Milestone to the To Milestone (and its project parent)
    public static List<pse__Resource_Request__c> reParentResourceRequests2Milestone(String fromMilestoneId, String toMilestoneId, String projectId)
    {
         List<pse__Resource_Request__c> ResourceRequests = [Select id,pse__Milestone__c,pse__Project__c from pse__Resource_Request__c where pse__Milestone__c =: fromMilestoneId];
         for (pse__Resource_Request__c ResourceRequest:ResourceRequests)
         {
            ResourceRequest.pse__Milestone__c = toMilestoneId;
            ResourceRequest.pse__Project__c = projectId;
         }
         
         return ResourceRequests;   
    }

	// Change the Tasks found on the FROM Milestone to the TO Milestone (and its Project parent)
    public static List<pse__Project_Task__c> reParentProjectTasks2Milestone(String fromMilestoneId, String toMilestoneId, String projectId)
    {
         List<pse__Project_Task__c> ProjectTasks = [Select id,pse__Milestone__c,pse__Project__c from pse__Project_Task__c where pse__Milestone__c =: fromMilestoneId];
         for (pse__Project_Task__c ProjectTask:ProjectTasks)
         {
            ProjectTask.pse__Milestone__c = toMilestoneId;
            ProjectTask.pse__Project__c = projectId;
         }
         
         return ProjectTasks;   
    }

	// Change just the project parent on tasks found on  the FROM Project to the TO Project
    public static List<pse__Project_Task__c> reParentProjectTasks(String fromProjectId, String toProjectId)
    {
         List<pse__Project_Task__c> ProjectTasks = [Select id,pse__Project__c from pse__Project_Task__c where pse__Project__c =: fromProjectId];
         for (pse__Project_Task__c ProjectTask:ProjectTasks)
         {
            ProjectTask.pse__Project__c = toProjectId;
         }
         
         return ProjectTasks;   
    }

	// Re-parent Resource Requests found on the FROM Project to the TO Project
    public static List<pse__Resource_Request__c> reParentResourceRequests(String fromProjectId, String toProjectId)
    {
         List<pse__Resource_Request__c> ResourceRequests = [Select id,pse__Project__c from pse__Resource_Request__c where pse__Project__c =: fromProjectId];
         for (pse__Resource_Request__c ResourceRequest:ResourceRequests)
         {
            ResourceRequest.pse__Project__c = toProjectId;
         }
         
         return ResourceRequests;   
    }
    
	// Populate Project with Tasks, Resources, Budgets, Milestones and Task Dependencies to match those of the Project template ID
    //@Future
    public static void populateProjectFromTemplate(string ProjectTemplateId, string ProjId, String ProjMilestoneId, String MSCurrency)
    {
        if (ProjectTemplateId != null)
        {

            List<pse__Milestone__c> ProjMSOrig = Database.query(RS_Utilities.SelectAllSOQL('pse__Milestone__c','Id',ProjMilestoneId,null,',pse__Project__r.pse__Region__c,pse__Project__r.pse__Practice__c'));
            Date MilestoneStartDate = ProjMSOrig[0].ffrr_exp__StartDate__c;
            String ProjectRegion = ProjMSOrig[0].pse__Project__r.pse__Region__c;
            String ProjectPractice = ProjMSOrig[0].pse__Project__r.pse__Practice__c;

            List<pse__Project_Task__c> tTasks = Database.query(RS_Utilities.SelectAllSOQL('pse__Project_Task__c','pse__Project__c',ProjectTemplateId,'order by CreatedDate',null));

            Map<Id,Id> TaskMap = new Map<Id,Id>();

            List<pse__Project_Task__c> ProjectTasks2Create = new List<pse__Project_Task__c>();

            // Loop through Tasks <<Create Project Tasks>>
            for (pse__Project_Task__c tTask:tTasks)
            {
                pse__Project_Task__c ProjectTask = tTask.clone(false,true,false,false);
                if(ProjectTask.pse__Parent_Task__c == null)
                {   
                    //Overrides
                    ProjectTask.pse__Project__c = ProjId;
                    if (ProjectTask.Start_Date_Gap_Days__c != null && ProjectTask.Start_Date_Gap_Days__c != null)
                    {
                        Date SD = MilestoneStartDate.addDays(Integer.valueOf(ProjectTask.Start_Date_Gap_Days__c));
                        Date ED = MilestoneStartDate.addDays(Integer.valueOf(ProjectTask.End_Date_Gap_Days__c));
 
                        ProjectTask.pse__Start_Date_Time__c = datetime.newInstance(SD.year(), SD.month(), SD.day());
                        ProjectTask.pse__End_Date_Time__c = datetime.newInstance(ED.year(), ED.month(), ED.day());
                    }
                    //ProjectTask.pse__Milestone__c = tMileStone.Id;
                    ProjectTask.pse__Milestone__c = ProjMilestoneId;
					//ProjectTask.pse__Project__c = ProjId;
                    ProjectTask.pse__Task_Key__c = null;
                    ProjectTask.pse__Task_Key_Chain__c = null;

                    ProjectTasks2Create.add(ProjectTask);
                }
            }

            Insert ProjectTasks2Create;

            for(pse__Project_Task__c ProjectTask:ProjectTasks2Create)
            {
                TaskMap.put(ProjectTask.TemplateRecordKey__c,ProjectTask.Id);
            }


            ProjectTasks2Create.clear();
            for (pse__Project_Task__c tTask:tTasks)
            {
                pse__Project_Task__c ProjectTask = tTask.clone(false,true,false,false);
                if(ProjectTask.pse__Parent_Task__c != null)
                {   
                    //Overrides
                    ProjectTask.pse__Project__c = ProjId;
                    //ProjectTask.pse__Milestone__c = tMileStone.Id;
                    ProjectTask.pse__Milestone__c = ProjMilestoneId;
                    if (ProjectTask.Start_Date_Gap_Days__c != null && ProjectTask.End_Date_Gap_Days__c != null)
                    {
                        Date SD = MilestoneStartDate.addDays(Integer.valueOf(ProjectTask.Start_Date_Gap_Days__c));
                        Date ED = MilestoneStartDate.addDays(Integer.valueOf(ProjectTask.End_Date_Gap_Days__c));
 
                        ProjectTask.pse__Start_Date_Time__c = datetime.newInstance(SD.year(), SD.month(), SD.day());
                        ProjectTask.pse__End_Date_Time__c = datetime.newInstance(ED.year(), ED.month(), ED.day());
                    }
                    ProjectTask.pse__Task_Key__c = null;
                    ProjectTask.pse__Task_Key_Chain__c = null;
    
                    if(ProjectTask.pse__Parent_Task__c != null)
                        ProjectTask.pse__Parent_Task__c = TaskMap.get(ProjectTask.pse__Parent_Task__c);
                    if(ProjectTask.pse__Top_level_Parent_Task__c != null)
                        ProjectTask.pse__Top_level_Parent_Task__c = TaskMap.get(ProjectTask.pse__Parent_Task__c);
                    
                    ProjectTask.External_ID__c = null;
                    ProjectTasks2Create.add(ProjectTask);
        
                }
            }

            Insert ProjectTasks2Create;
            for(pse__Project_Task__c ProjectTask:ProjectTasks2Create)
            {
                TaskMap.put(ProjectTask.TemplateRecordKey__c,ProjectTask.Id);
            }

            List<pse__Project_Task_Dependency__c> projectdependencies = Database.query(RS_Utilities.SelectAllSOQL('pse__Project_Task_Dependency__c','pse__Dependent_Task__r.pse__Project__c',ProjectTemplateId,null,null));


            List<pse__Project_Task_Dependency__c> ProjectDependencies2Create = new List<pse__Project_Task_Dependency__c>();

            for(pse__Project_Task_Dependency__c projectdependency: projectdependencies)
            {
                pse__Project_Task_Dependency__c ProjectTaskDependency = projectdependency.clone(false,true,false,false);
    
                // Overrides
                ProjectTaskDependency.pse__Dependent_Task__c = TaskMap.get(ProjectTaskDependency.pse__Dependent_Task__c);
    
                if (ProjectTaskDependency.pse__Preceding_Task__c != null)
                    ProjectTaskDependency.pse__Preceding_Task__c = TaskMap.get(ProjectTaskDependency.pse__Preceding_Task__c);
    
                ProjectDependencies2Create.add(ProjectTaskDependency);
            }

            Insert ProjectDependencies2Create;

            List<pse__Resource_Request__c> tResourceRequests = Database.query(RS_Utilities.SelectAllSOQL('pse__Resource_Request__c','pse__Project__c',ProjectTemplateId,null,null));


            Map<Id,Id> ResourceRequestMap = new Map<Id,Id>();

            List<pse__Resource_Request__c> ResourceRequests2Create = new List<pse__Resource_Request__c>();
            for(pse__Resource_Request__c tResourceRequest: tResourceRequests)
            {
                pse__Resource_Request__c ResourceRequest = tResourceRequest.clone(false,true,false,false);

                // Overrides
                ResourceRequest.pse__Project__c = ProjId;
                ResourceRequest.pse__Milestone__c = ProjMilestoneId;
                ResourceRequest.pse__Region__c = ProjectRegion;
                ResourceRequest.pse__Practice__c = ProjectPractice;
				ResourceRequest.CurrencyIsoCode = MSCurrency;
                ResourceRequest.External_ID__c = null;
                if (ResourceRequest.Start_Date_Gap_Days__c != null && ResourceRequest.End_Date_Gap_Days__c != null && !Test.isRunningTest())
                {
                    ResourceRequest.pse__Start_Date__c = MilestoneStartDate.addDays(Integer.valueOf(ResourceRequest.Start_Date_Gap_Days__c));
                    ResourceRequest.pse__End_Date__c = MilestoneStartDate.addDays(Integer.valueOf(ResourceRequest.End_Date_Gap_Days__c));                   
                }
    
                ResourceRequests2Create.add(ResourceRequest);
            }

            try
            {
                Database.Insert(ResourceRequests2Create,true);
            }
            catch(Exception e)
            { 
                System.debug('Resource Request Creation Error:' + e);
                System.debug(ResourceRequests2Create);
            }
            list<pse__Resource_Request__c> psResource =[Select id from pse__Resource_Request__c where id In:ResourceRequests2Create];

            
            for(pse__Resource_Request__c ResourceRequest: ResourceRequests2Create)
            {
                TaskMap.put(ResourceRequest.TemplateRecordKey__c,ResourceRequest.Id);
            }


            List<pse__Resource_Skill_Request__c> tResourceSkillRequests = Database.query(RS_Utilities.SelectAllSOQL('pse__Resource_Skill_Request__c','ProjectId__c',ProjectTemplateId,null,null));


            List<pse__Resource_Skill_Request__c> ResourceSkillRequests2Create = new List<pse__Resource_Skill_Request__c>();
            for(pse__Resource_Skill_Request__c tResourceSkillRequest: tResourceSkillRequests)
            {
                pse__Resource_Skill_Request__c ResourceSkillRequest = tResourceSkillRequest.clone(false,true,false,false);

                // Overrides
                ResourceSkillRequest.pse__Resource_Request__c = TaskMap.get(ResourceSkillRequest.pse__Resource_Request__c);

                ResourceSkillRequests2Create.add(ResourceSkillRequest);
            }

            Insert ResourceSkillRequests2Create;            
        }

    }

    // Utility method to select all SOQL fields
	// sObject name = API Name of the sObject
	// filterField = API Name of the field to filter by for example ID
	// filterValue = String value to use for the evaluation for example the ID associated with a record
	// misc = Anything  you want to add on after the Where clause such as additional clauses or a limit command.
	// extrafields = Additional fields related to the record such as parent references to add to the query results

    public static string SelectAllSOQL(string sObjectName,string filterField,string filterValue,string misc,string extrafields)
    {       
        List<String> fields = GetAllFieldsFromsObject(sObjectName);
        if (misc == null) misc = '';
        if (extrafields == null) extrafields = '';
        String SOQL = 'SELECT '+String.join(fields,',') + extrafields + ' FROM ' + sObjectName + ' where ' + filterField + ' = \'' + filterValue + '\' ' + misc;
        return SOQL;
    }

	// Utility method for the utility method above. Grabs all the fields and places them in a Set of strings.
    public static List<string> GetAllFieldsFromsObject(string sObjectName)
    {
        SObjectType stype = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = stype.getDescribe().fields.getMap();
        return new List<String>(mfields.keySet());      
    }

}