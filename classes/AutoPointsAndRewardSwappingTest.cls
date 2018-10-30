@isTest (SeeAllData = true)
private class AutoPointsAndRewardSwappingTest {
    static testMethod void swapPointsandRewardTrigger() {
        Test.startTest();
           AutoPointsAndRewardSwappingController ctrlrObject = new AutoPointsAndRewardSwappingController();
                   
          
         
           ctrlrObject.userIdOld = '00550000001uXNJAA2';
           ctrlrObject.userIdNew = '00550000001wblMAAQ';
           ctrlrObject.hasNotFailed = true;
           ctrlrObject.isSuccess = true;
           ctrlrObject.swap();
           ctrlrObject.automateEmailSwappingCallout();
           
         
         
        Test.stopTest();
    } 

    static testMethod void swapPointsandRewardTrigger2() {
        Test.startTest();
            AutoPointsAndRewardSwappingController ctrlrObject = new AutoPointsAndRewardSwappingController();
            ctrlrObject.userIdOld = '';
            ctrlrObject.userIdNew = '';
            ctrlrObject.swap();
            
                          
            ctrlrObject.userIdOld = '00550000001uXNJ';
            ctrlrObject.userIdNew = '00550000001wblM';
            ctrlrObject.hasNotFailed = true;
            ctrlrObject.isSuccess = true;
            ctrlrObject.swap();
            
         
          
            //ctrlrObject.automateEmailSwappingCallout();
        Test.stopTest();
    }
    
     static testMethod void swapPointsandRewardTrigger3() {
        Test.startTest();
            AutoPointsAndRewardSwappingController ctrlrObject = new AutoPointsAndRewardSwappingController();
                      
            ctrlrObject.userIdOld = '14536363737';
            ctrlrObject.userIdNew = '16378484844';
            ctrlrObject.swap();
        Test.stopTest();
    }
}