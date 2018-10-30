public class ResultElement {
    public String title {get; set;}
    public String id {get; set;}

    public resultElement(String tempTitle, String tempId){
        title = tempTitle;
        id    = tempId;    
    }
    public resultElement(){
    
    }
	/**TEST CODE**/
	public static testMethod void ResultElement(){
		resultElement res1 = new resultElement();
		resultElement res2 = new resultElement('temp_title','tempid_12345');
	}
}