public with sharing class MKT_CalendarController {

	public String Msg { get; set; }
	public List<Week> Weeks { get; set; }
	public Boolean CalView { get; set; }
	public Boolean showEnrolledSession;
	public Boolean showAssignmentSession;
	Datetime StartDate;
	Datetime EndDate;
	Date CurrD;
	public Set<Id> EventsIds;

	public String CurrentMonth { get; set; }
	public String CurrentYear { get; set; }

	public MKT_CalendarController() {
		CalView = true;
		CurrD = system.today();
		showEnrolledSession = false;
		showAssignmentSession = false;
		EventsIds = new Set<Id>();
		//ShowScreen();
	}

	public class Week {
		public Week() {
			Days = new List<Day>();
		}
		public List<Day> Days { get; set; }
	}

	public class Day {
		public String DayNum { get; set; }
		public Boolean ThisMonth { get; set; }
		public Date Dt { get; set; }
		public List<CustomEvent> Events { get; set; }
	}

	public class CustomEvent {
		public String EventName { get; set; }
		public String ClassName { get; set; }
		public String SessionName { get; set; }
		public String Type { get; set; }
		public Id EventId { get; set; }
		public Id ClassId { get; set; }
		public Id SessionId { get; set; }
		public Id AssignId { get; set; }
		//public List<String> Session { get; set; }
		public List<CustomSession> Session { get; set; }
	}
	public class CustomSession {
		public String SessionName { get; set; }
		public String Type { get; set; }
		public Id EventId { get; set; }
		public Id ClassId { get; set; }
		public Id SessionId { get; set; }
		public String Location { get; set; }
		public Boolean ExistLocation { get; set; }
		public String StartTime { get; set; }
	}

	private String TranslateMonth(Integer i) {
		List<String> MonthD = new List<String>{'-', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'Octomber', 'November', 'December'};
		return MonthD.get(i);
	}

	public PageReference ThisMonth() {
		CurrD = date.newinstance(System.today().Year(), System.today().Month(), 1);
		ShowScreen();
		return null;
	}

	public PageReference MonthBack() {
		CurrD = CurrD.addMonths(-1);
		ShowScreen();
		return null;
	}

	public PageReference MonthForward() {
		CurrD = CurrD.addMonths(1);
		ShowScreen();
		return null;
	}

	public void CreateEmptyCal() {

		CurrentMonth = TranslateMonth(CurrD.Month());
		CurrentYear = String.valueOf(CurrD.Year());

		Date StMth = CurrD.toStartOfMonth();
		StMth = StMth.toStartOfWeek();

		StartDate = DateTime.valueOf(StMth+' 00:00:00');
		EndDate = DateTime.valueOf(StMth.adddays(43) + ' 00:00:00');

		Integer Mth = CurrD.month();
		Integer Br = StMth.daysBetween(StMth.toStartOfWeek());
		Br = Br * -1;
		Integer DaysInMonth = date.daysInMonth(CurrD.year(), CurrD.Month());
		Msg = string.valueOf(DaysInMonth);

		Weeks = new List<Week>();
		Week Week = new Week();

		List<Day> Days = new List<Day>();
		Set<Date> DueDatesSet = new Set<Date>();

		Day d;
		Integer dy = 1;
		Integer Mt = 0;

		for (Integer i = 0; i < 6*7; i++) {
			mt++;
			d = new Day();

			if (Mth == StMth.month()) {
				d.ThisMonth = true;
			}
			else {
				d.ThisMonth = false;
			}

			d.Dt = StMth;
			DueDatesSet.add(StMth);

			d.DayNum = String.valueOf(StMth.day());

			if (mt != 1 && mt != 7) {
				Week.Days.add(d);
			}

			StMth = StMth.addDays(1);


			if (mt == 7) {
				mt = 0;
				Weeks.add(Week);
				Week = new Week();

				if (StMth.month() != Mth ) break;
			}
		}
		if (Week.Days.size() > 0) {
			Weeks.add(Week);
		}
	}

	public void GetEventsIdsFromCatalog() {

		Set<Id> idsCatalogs = new Set<Id>();

		Set<String> Groups = HelperWithoutSharing.getGroupsIds(new Set<Id>());

		// default groups logic
		String PublicGroupName = 'none';
		User curr_user = [SELECT Id, UserType, AccountId FROM User WHERE Id=: UserInfo.getUserId()];

		if (curr_user.UserType.equalsIgnoreCase('Standard')) {
			PublicGroupName = 'All Internal Users';
		}
		else if (curr_user.UserType.equalsIgnoreCase('PowerPartner')) {
			PublicGroupName = 'All Partner Users';
		}
		else if (curr_user.UserType.equalsIgnoreCase('CSPLitePortal') || curr_user.UserType.equalsIgnoreCase('CustomerSuccess') || curr_user.UserType.equalsIgnoreCase('PowerCustomerSuccess')) {
			PublicGroupName = 'All Customer Portal Users';
		}

		List<lmscons__Catalog_Profile__c> cps = [SELECT lmscons__Catalog__c FROM lmscons__Catalog_Profile__c WHERE lmscons__Profile_Id__c LIKE:'%'+UserInfo.getProfileId()+'%'];
		List<lmscons__Catalog_Group__c> cgs = [SELECT lmscons__Catalog__c FROM lmscons__Catalog_Group__c WHERE lmscons__Group_Id__c IN : Groups OR lmscons__Group_Name__c =: PublicGroupName];

		for (lmscons__Catalog_Profile__c cp : cps){
			idsCatalogs.add(cp.lmscons__Catalog__c);
		}

		for (lmscons__Catalog_Group__c cg : cgs) {
			idsCatalogs.add(cg.lmscons__Catalog__c);
		}

		for (lmsilt__Event_Catalog__c a : [SELECT Id, lmsilt__Event__r.lmsilt__Description__c, lmsilt__Event__r.Name, lmsilt__Event__r.Id, lmsilt__Event__c, lmsilt__Catalog__c FROM lmsilt__Event_Catalog__c WHERE lmsilt__Catalog__c IN : idsCatalogs ]) {
			EventsIds.add(a.lmsilt__Event__c);
		}
	}

	public void fillCal() {

		Map<Date, List<CustomEvent>> EventsMap = new Map<Date, List<CustomEvent>>();

		Set<Id> idsClasses = new Set<Id>();
		Map<Id,lmscons__Transcript_Line__c> EventIdAssignmentMap = HelperWithoutSharing.getAssignmentEvents();

		if (showAssignmentSession && EventIdAssignmentMap.size() > 0) {
			EventsIds = EventIdAssignmentMap.keySet();
		}

		for (lmsilt__Class__c a : [SELECT lmsilt__Enroll_Users__c, lmsilt__Start_Date__c, Name, Id, lmsilt__Event__r.Name, lmsilt__Event__r.Id, lmsilt__Event__c, lmsilt__End_Date__c FROM lmsilt__Class__c WHERE lmsilt__Event__c IN : EventsIds]) {
			idsClasses.add(a.Id);
		}

		List<lmsilt__Session__c> session_list = [SELECT lmsilt__Class__r.Name, lmsilt__Class__r.lmsilt__Event__c, lmsilt__Time_Zone__c, lmsilt__Start_Date_Time__c, lmsilt__Session_Location__c,lmsilt__Session_Location__r.Name, Name, lmsilt__Meeting__c, lmsilt__Meeting_Type__c, Id, lmsilt__ILT_vILT__c, lmsilt__Event__c, lmsilt__End_Date_Time__c, lmsilt__Class__c FROM lmsilt__Session__c WHERE lmsilt__Start_Date_Time__c >= : StartDate AND lmsilt__End_Date_Time__c < : EndDate AND lmsilt__Class__c IN : idsClasses];

		Map<Id, lmsilt__Event__c> EventsObjMap = new Map<Id, lmsilt__Event__c>([SELECT Id, Name FROM lmsilt__Event__c WHERE Id IN : EventsIds]);
		for (lmsilt__Session__c s : session_list) {
			CustomSession Session = new CustomSession();
			Session.SessionName = s.Name;
			Session.SessionId = s.Id;
			Session.ClassId = s.lmsilt__Class__c;
			Session.EventId = s.lmsilt__Class__r.lmsilt__Event__c;
			Session.StartTime = String.valueOf(s.lmsilt__Start_Date_Time__c.format('h:mm a'));
			//String SessionNameAndDate = s.Name + ': '+String.valueOf(s.lmsilt__Start_Date_Time__c.format('dd h:mm a'))+' - '+String.valueOf(s.lmsilt__End_Date_Time__c.format('dd h:mm a'));

			if (s.lmsilt__ILT_vILT__c == 'ILT') {
				if (s.lmsilt__Session_Location__c != NULL) {
					//SessionNameAndDate += '<br/>Location: <a href ="javascript: void(0);" onclick = "GetSessionLocation(\''+ s.Id +'\')">'+ s.lmsilt__Session_Location__r.Name + '</a>';
					Session.Location = s.lmsilt__Session_Location__r.Name;
					Session.ExistLocation = true;
				}
				else {
					Session.Location = 'Classroom';
					Session.ExistLocation = false;
				}
				Session.Type = 'Classroom';
			}
			if (s.lmsilt__ILT_vILT__c == 'vILT') {
				Session.Type = 'Virtual';
				if (s.lmsilt__Meeting_Type__c != NULL) {
					Session.Location = s.lmsilt__Meeting_Type__c;
				}
				else {
					Session.Location = 'Virtual';
				}
			}
			Date dte = Date.newInstance(s.lmsilt__Start_Date_Time__c.year(),s.lmsilt__Start_Date_Time__c.month(),s.lmsilt__Start_Date_Time__c.day());
			Date dte2 = Date.newInstance(s.lmsilt__End_Date_Time__c.year(),s.lmsilt__End_Date_Time__c.month(),s.lmsilt__End_Date_Time__c.day());

			if (dte2 < dte) dte2 = dte;
			Boolean addNewEvent = true;
			while (dte <= dte2) {
				List<CustomEvent> ce_list = new List<CustomEvent>();
				if (EventsMap.containsKey(dte)) {
					ce_list = EventsMap.get(dte);
					for (CustomEvent ce1 : ce_list) {
						if (ce1.EventId == s.lmsilt__Class__r.lmsilt__Event__c) {
							ce1.Session.add(Session);
							addNewEvent = false;
						}
					}
				}
				if (!EventsMap.containsKey(dte) || addNewEvent) {
					CustomEvent ce = new CustomEvent();
					ce.Session = new List<CustomSession>();
					ce.EventId = s.lmsilt__Class__r.lmsilt__Event__c;
					if (EventIdAssignmentMap.containsKey(ce.EventId)) {
						lmscons__Transcript_Line__c trLine = EventIdAssignmentMap.get(ce.EventId);
						ce.ClassId = trLine.lmsilt__Class__c;
						ce.AssignId = trLine.Id;
					}
					ce.EventName = EventsObjMap.get(s.lmsilt__Class__r.lmsilt__Event__c).Name;
					ce.Session.add(Session);
					ce.Type = 'Event';
					ce_list.add(ce);
					addNewEvent = true;
				}
				EventsMap.put(dte,ce_list);
				dte = dte.addDays(1);
			}
		}


		List<lmscons__Transcript__c> transcr = [SELECT Id FROM lmscons__Transcript__c WHERE lmscons__Trainee__c =: UserInfo.getUserId()];
		for (Week w : weeks) {
			for (Day dayc : w.Days) {

				if (EventsMap.containsKey(dayc.Dt))	{
					dayc.Events = EventsMap.get(dayc.Dt);
				}
			}
		}
	}

	public void ShowScreen() {
		CreateEmptyCal();
		if (EventsIds == NULL || EventsIds.size() == 0) {
			GetEventsIdsFromCatalog();
		}
		fillCal();
	}

}