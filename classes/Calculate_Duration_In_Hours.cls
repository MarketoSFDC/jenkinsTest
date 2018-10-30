public with sharing class Calculate_Duration_In_Hours{
    
    public static Integer duration_between_two_date_times(DateTime start_date_time, DateTime end_date_time) {
        Integer start_year_as_int = start_date_time.year(); //grab the start year
        Integer start_day_as_int = start_date_time.dayOfYear(); //grab the start day
        Integer start_hour_as_int = start_date_time.hour(); //grab the start hour
        Integer start_minute_as_int = start_date_time.minute(); //grab the start minute
        Integer start_second_as_int = start_date_time.second(); //grab the start second
        Integer start_in_seconds = (start_year_as_int * 31556926) + (start_day_as_int * 86400) + (start_hour_as_int * 3600) + (start_minute_as_int * 60) + (start_second_as_int * 1); //convert the start date to a value in seconds
        //there are 31556926 seconds in one year and that is why we are mutiplying the start_year_as_int value by 31556926 > this same logic applies to the days, hours & minutes logic which is why there are weird multipliers in that line of code
        Integer end_year_as_int = end_date_time.year(); //grab the end year
        Integer end_day_as_int = end_date_time.dayOfYear(); //grab the end day
        Integer end_hour_as_int = end_date_time.hour(); //grab the end hour
        Integer end_minute_as_int = end_date_time.minute(); //grab the end minute
        Integer end_second_as_int = end_date_time.second(); //grab the end second
        Integer end_in_seconds = (end_year_as_int * 31556926) + (end_day_as_int * 86400) + (end_hour_as_int * 3600) + (end_minute_as_int * 60) + (end_second_as_int * 1); //convert the end date to a value in seconds
        Integer total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
        Integer year_result = math.mod(math.floor(total_duration_in_seconds/31556926).intValue(),10000000); //number of years
        Integer day_result = math.mod(math.floor(total_duration_in_seconds/86400).intValue(),365); //number of days
        Integer hour_result = math.mod(math.floor(total_duration_in_seconds/3600).intValue(),24); //number of hours
        Integer minute_result = math.mod(math.floor(total_duration_in_seconds/60).intValue(),60); //number of minutes
        Integer second_result = math.mod(math.floor(total_duration_in_seconds/1).intValue(),60); //number of seconds
        System.Debug('___day_result___'+day_result*24+hour_result+'___hour_result___'+hour_result+'minute_result'+minute_result+'second_result'+second_result);
        
        return day_result*24+hour_result;
        /*String year_text_string = segment_text('Year', year_result, ''); //string variable for text regarding Year
        String day_text_string = segment_text('Day', day_result, year_text_string); //string variable for text regarding Day
        String hour_text_string = segment_text('Hour', hour_result, year_text_string + day_text_string); //string variable for text regarding Hour
        String minute_text_string = segment_text('Minute', minute_result, year_text_string + day_text_string + hour_text_string); //string variable for text regarding Minute
        String second_text_string = segment_text('Second', second_result, year_text_string + day_text_string + hour_text_string + minute_text_string); //string variable for text regarding Second
        String return_string = year_text_string + day_text_string + hour_text_string + minute_text_string + second_text_string;//concatenate all the strings into one for our resutling test string
        return return_string;*/ //pass back the final string
    }
}