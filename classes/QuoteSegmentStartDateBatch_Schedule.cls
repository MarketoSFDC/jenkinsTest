/*********************************************************************
* Created Date       : 18th August 2016
* Create By          : Jade Global 
* Last Modified By   : Jade Global 18th August 2016
* Purpose            : This is used for
                       1.To execute batch class QuoteSegmentStartDateBatch at scheduled time.
************************************************************************/
global class QuoteSegmentStartDateBatch_Schedule implements Schedulable  {

	global void execute(SchedulableContext sc) {
		QuoteSegmentStartDateBatch QuoteSegObj = new QuoteSegmentStartDateBatch();
		database.executebatch(QuoteSegObj,1);
	}//End of execute method
}