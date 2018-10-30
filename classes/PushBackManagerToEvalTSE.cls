global class PushBackManagerToEvalTSE implements schedulable{    
    
    global void execute( SchedulableContext SC ){
        EmailNotificationToManager.fetchDefaulterManager();
        //PushBackManagerToEvalTSE.start();
        // abort me and start again
        //If(SC != NULL){
        //    System.abortJob( SC.getTriggerId() );
        //}
    }
    /*
    public static void start(){        
        String executionFreq       = System.Label.P1_Tracker_Frequency;
        Integer executionTimPeriod = Integer.valueof(executionFreq.trim());
        System.Debug('___Execution Flag__'+executionTimPeriod);
        Datetime sysTime = System.now().addSeconds( executionTimPeriod );      
        String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        System.schedule( 'TSE Eval Status Tracker' + sysTime, chronExpression, new PushBackManagerToEvalTSE() );        
    }
    */
}