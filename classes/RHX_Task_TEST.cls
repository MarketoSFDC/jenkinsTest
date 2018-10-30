@isTest(SeeAllData=true)
public class RHX_Task_TEST {
	
    static testMethod void triggerTest() {
        
        List<Task> sourceList = [SELECT Id
			                           		FROM Task
                    				       		LIMIT 1
                           				];
        if(sourceList.size() == 0) {
            sourceList.add(
                	new Task()
                );
        }
        upsert sourceList;
        
    }

}