global class Inv_ConvergeProjectDataOnOpportunity  {

    @InvocableMethod(label='Converge Project')
    global static void ConvergeProjectDataOnOpportunity(List<PBInputs> Inputs) {
        if (Inputs.size() > 0)
        {
            if (Inputs[0].OppId != null)
            {
                String OppId = Inputs[0].OppId;
                Opportunity ParentOpp = [Select pse__primary_project__c from Opportunity where Id =: OppId][0];
                pse__Proj__c Project = [Select id,Primary_Project__c from pse__Proj__c where Primary_Project__c !=null and pse__Opportunity__c =: OppId limit 1][0];
                System.debug('ParentOpp (ToProjectId) = ' + ParentOpp.pse__primary_project__c);
                System.debug('Project (FromProjectid) = ' + Project.Id);
                if (Project.Id != null)
                {
                    String FromProjectId = Project.Id;
                    String ToProjectId = Project.Primary_Project__c;
                    if (ToProjectId != null && FromProjectId != ToProjectId)
                    {
                        List<pse__Milestone__c> Milestones = RS_Utilities.CloneMilestones(FromProjectId,ToProjectId);
                        List<pse__Budget__c> Budgets = RS_Utilities.reParentBudgets(FromProjectId,ToProjectId);
                       
                       
                        Delete Budgets;
                        Delete Milestones;
                        Delete Project;
                        //ParentOpp.pse__primary_project__c = ToProjectId;
                        //Update ParentOpp;
                    }
                }           
            } 

        }
    }

    global class PBInputs {
        @InvocableVariable(required=true)
        global ID OppId;
    }
}