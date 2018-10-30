/* ------------------------------
Created By - Shridhar Patankar
Date       - 20/01/2015
Description - For CPQ-21 Schedule Class to call AssetAutoProvisioning class after every hour
--------------------------------- */
global class SchedulerForAssetAutoProvisioning implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        AssetAutoProvisioning.processAssets(); 
        CaseAutoProvisioning.processCases();         
    }
}