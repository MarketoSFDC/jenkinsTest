global class SendEmailForP1ServiceBreach implements schedulable{    
    /*
    --------------------------------------------    --------------------------------------------    --------------------------------------------
    Boolean Variable Used To Prevent The Execution Of EmailNotificationToTSE at the scheduler is put into action using Developer console. 
    --------------------------------------------    --------------------------------------------    --------------------------------------------
        Developer Console Code To Execute This Job:::
        SendEmailForP1ServiceBreach tempObj = new SendEmailForP1ServiceBreach();
        tempObj.runFirstTime = true;
        tempObj.execute(null);
    --------------------------------------------    --------------------------------------------    --------------------------------------------        
    */
    public Boolean runFirstTime = false;
        global void execute( SchedulableContext SC ){        
            If(runFirstTime == false){
                    EmailNotificationToTSE.fetchValidCasedForNotification();
                }
                SendEmailForP1ServiceBreach.start();
                // abort me and start again
                If(SC != NULL){
                    System.abortJob( SC.getTriggerId() );
                }
            
        }

        public static void start(){
            // start keepalive again in 5 mins
            String executionFreq       = System.Label.P1_Tracker_Frequency;
            Integer executionTimPeriod = Integer.valueof(executionFreq.trim());
            System.Debug('___Execution Flag__'+executionTimPeriod);
            Datetime sysTime = System.now().addSeconds( executionTimPeriod );      
            String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule( 'P1BreachTracker' + sysTime, chronExpression, new SendEmailForP1ServiceBreach() );
        }
}