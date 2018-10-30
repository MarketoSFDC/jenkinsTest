global class AutoCloseViolatedMilestones implements schedulable
{    
    global void execute( SchedulableContext SC ){ 
        try {               
            CustomMilestoneUsedInScheduler.UpdateCaseUpdateMilestoneViaScheduler();    
        } catch (Exception ex) {                    
            List<string> receiverIds = System.Label.AutoCaseMileStoneNotificationList.split(';');
            List<User> notificationReceivers = [SELECT Id, Email from User where Id in : receiverIds and isActive = true];                                                                
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();               
            for(User tmpUsr : notificationReceivers) {            
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setReplyTo('noreply@marketo.com');
                message.setSaveAsActivity(false);
                message.setSubject('Auto Close milestone exception: ' + Datetime.Now());
                // We can also just use an id for an implicit to address
                message.setTargetObjectId(tmpUsr.Id);
                message.setUseSignature(false);
                message.setPlainTextBody('This is the Exception message:'  + ex);            
                emails.add(message);     
            }
            if(emails.isEmpty() == FALSE) {
                try {
                    Messaging.sendEmail(emails);    
                } catch(Exception exc) {
                    System.debug('Exception==>' + exc);
                }
            }
        } 
        AutoCloseViolatedMilestones.start();
        // abort me and start again
        If(SC != NULL && (!Test.isRunningTest())) {
            System.abortJob( SC.getTriggerId() );
        }
    }

    public static void start(){
        // start keepalive again in 5 mins
        Datetime sysTime       = System.now().addSeconds( 300 );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'Auto Close Violated Milestones' + sysTime, chronExpression, new AutoCloseViolatedMilestones() );
    }
    
    public static testmethod void AutoCloseViolatedMilestones() {
        Test.StartTest();
            AutoCloseViolatedMilestones atmilestone = new AutoCloseViolatedMilestones();            
            String chron = '0 0 8 13 2 ?';        
            system.schedule('Test Sched', chron, atmilestone);            
        Test.StopTest();    
    }

}