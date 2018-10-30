public with sharing class MKT_Courses {

	public class DebugException extends Exception {}

	public String SortColumnNumber { get; set; }
	public String AscDesc { get; set; }
	public String SelectedCourseType { get; set; }
	public String SelectedLocation { get; set; }
	public Boolean AdvancedSearch { get; set; }
	public Map<Id,Set<String>> LocationMap { get; set; }
	public String searchKeyWord { get; set; }

	public String Name_Quiz { get; private set; }
	public String Name_Event { get; private set; }
	public String Name_Module { get; private set; }
	public String Name_Course { get; private set; }
	public String Name_LP { get; private set; }
	public String Name_Curriculum { get; private set; }
	public String Name_Task { get; private set; }

	public List<lmsilt__Event__c> ListEvents { get; set; }
	public List<lmscons__Quiz__c> ListQuizes { get; set; }
	public List<lmscons__Training_Content__c> ListModules { get; set; }
	public List<lmscons__Training_Path__c> ListCourses { get; set; }
	public List<lmscons__Learning_Path__c> ListLP { get; set; }
	public List<lmscons__Curriculum__c> ListCurr { get; set; }
	public List<lmsilt__Development_Plan_Task__c> ListTasks { get; set; }

	public String idTraining { get; set; }
	public String RedirectUrl { get; set; }
	public lmscons__Transcript_Line__c Dummy { get; set; }
	public String idObjectToAdd { get; set; }
	public String TypeObj { get; set; }
	public Integer CartCount { get; set; }

	public String AssignedContentId { get; set; }
	public String AssignObjectType { get; set; }

	public Boolean Search_Quiz { get; set; }
	public Boolean Search_Event { get; set; }
	public Boolean Search_Module { get; set; }
	public Boolean Search_Course { get; set; }
	public Boolean Search_LP { get; set; }
	public Boolean Search_Curr { get; set; }

	public NewCourses LeftLandingCourse {get;set;}
	public NewCourses CenterLandingCourse {get;set;}
	public NewCourses RightLandingCourse {get;set;}
	public NewCourses LeftTopCourse {get;set;}
	public NewCourses LeftBottomCourse {get;set;}
	public NewCourses RightTopCourse {get;set;}
	public NewCourses RightBottomCourse {get;set;}
	public Map<Id, PricebookEntry> ProductIdPricebookEntry;
	public Boolean Search_Description { get; set; }
	Set<Id> CartItemsProductsSet;
	Set<Id> PaidItemsProductsSet;
	String LastValue = '1';
	public Boolean CalView { get; set; }
	public MKT_CalendarController calendar { get; set; }

	public Boolean getIsUserUS() {
		return HelperWithoutSharing.getIsUserUS();
	}
	public String getResp() {
		String partnerURL = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+'/services/Soap/u/7.0/'+UserInfo.getOrganizationId();
		String sPostData = 'https://www.intacct.com/ia/acct/sforcerouter.phtml?.action=SYNC_CUSTOMER&.account_id=0015000000krdZP&.sforcekey=' + UserInfo.getSessionId() + '&.endpoint='+partnerURL+'.mega=shared&.root=Mega-SFDC&.userentity=marketo-copy';
		return sPostData;
	}
	public MKT_Courses() {


		Name_Quiz = lmscons__Quiz__c.sObjectType.getDescribe().getLabel();
		Name_Module = lmscons__Training_Content__c.sObjectType.getDescribe().getLabel();
		Name_Event = lmsilt__Event__c.sObjectType.getDescribe().getLabel();
		Name_Course = lmscons__Training_Path__c.sObjectType.getDescribe().getLabel();
		Name_LP = lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel();
		Name_Curriculum = lmscons__Curriculum__c.sObjectType.getDescribe().getLabel();
		Name_Task = lmsilt__Development_Plan_Task__c.sObjectType.getDescribe().getLabel();
		ProductIdPricebookEntry = new Map<Id, PricebookEntry>();
		CartItemsProductsSet = new Set<Id>();
		PaidItemsProductsSet = new Set<Id>();
		LocationMap = new Map<Id,Set<String>>();
		//GetNewCoursesOnThePage ();
		SelectedCourseType = Label.MKT_All;
		SelectedLocation = Label.MKT_All;
		AscDesc = 'asc';
		AdvancedSearch = false;
		SortColumnNumber = '1';
		SearchItemAll = new List<s_record>();
		Dummy = new lmscons__Transcript_Line__c();

		Search_Quiz = true;
		Search_Event = true;
		Search_Module = true;
		Search_Course = true;
		Search_LP = true;
		Search_Curr = true;

		Search_Description = false;
		if (ApexPages.currentPage().getParameters().get('calView') != NULL) {
			calView();
		}
		else {
			CalView = false;
			SearchCoursesModules();
		}

		trainingFilter = Label.MKT_All;

	}
	public void calView() {
		CalView = true;
		calendar = new MKT_CalendarController();
		calendar.ShowScreen();
	}
	public void ThisMonth() {
		calendar.ThisMonth();
	}
	public void MonthBack() {
		calendar.MonthBack();
	}
	public void MonthForward() {
		calendar.MonthForward();
	}

	public void listView () {
		CalView = false;
	}

	public PageReference ToggleSearch() {
		if (AdvancedSearch) {
			AdvancedSearch = false;
		}
		else {
			AdvancedSearch = true;
		}
		Search_Quiz = true;
		Search_Event = true;
		Search_Module = true;
		Search_Course = true;
		Search_LP = true;
		Search_Curr = true;
		return null;
	}
	public List<String> getCourseTypes() {
		List<String> options = new List<String>();
		options.add(Label.MKT_All);
		options.add(Label.MKT_On_Demand);
		options.add(Label.MKT_Classroom);
		options.add(Label.MKT_Virtual);
		//options.add(Label.MKT_ClassroomVirtual);
		options.add(Label.MKT_Course);
		//options.add(Label.MKT_LearningPath);
		//options.add(Label.MKT_Curriculum);
		return options;
	}


	public List<String> getLocations() {
		List<String> options = new List<String>();
		Set<String> locAllSet = new Set<String>();
		for (s_record tc : SearchItemAll) {
			String c = '';
			if (tc.Type == Name_Event && LocationMap.containsKey(tc.Module.ItemId)) {
				Set<String> locSet = LocationMap.Get(tc.Module.ItemId);
				if (locSet.size() > 0)
				locAllSet.AddAll(locSet);
			}
		}
		options.AddAll(locAllSet);
		options.sort();
		return options;
	}
	public PageReference FilterLocation() {
		//process_items();
		SearchItem = SearchItemAll;
		List<s_record> SearchItemSorted = new List<s_record>();
		if (SelectedLocation != NULL && SelectedLocation != '') {
			for (s_record tc : SearchItem) {
				String c = '';
				//getEventLocations
				if (tc.Type == Name_Event && LocationMap.containsKey(tc.Module.ItemId)) {
					Set<String> LocSet = LocationMap.get(tc.Module.ItemId);
					if (LocSet.contains(SelectedLocation) || SelectedLocation == Label.MKT_All) {
						SearchItemSorted.add(tc);
					}
				}
				else if (SelectedLocation == Label.MKT_All) {
					SearchItemSorted.add(tc);
				}
			}
			SearchItem = SearchItemSorted;
			SortCol();
		}
		return NULL;
	}
	public PageReference FilterCourseTypes() {
		//process_items();
		SearchItem = SearchItemAll;
		List<s_record> SearchItemSorted = new List<s_record>();
		if (SelectedCourseType != NULL && SelectedCourseType != '') {
			for (s_record tc : SearchItem) {
				String c = '';
				if (tc.Type == Name_Module || tc.Type == Name_Quiz) {
					c = Label.MKT_On_Demand;
				}
				else if (tc.Type == Name_Event) {
					c = tc.Module.TypeEvent;
				}
				else {
					c = tc.Type;
				}

				if (c != NULL && (c == SelectedCourseType || SelectedCourseType == Label.MKT_All)) {
					SearchItemSorted.add(tc);
				}
				else if (c != NULL && c == Label.MKT_ClassroomVirtual && c.contains(SelectedCourseType)) {
					SearchItemSorted.add(tc);
				}
				else if (c != NULL && SelectedCourseType == Label.MKT_ClassroomVirtual && SelectedCourseType.contains(c)) {
					SearchItemSorted.add(tc);
				}
			}
			SearchItem = SearchItemSorted;
			SortCol();
		}
		return NULL;
	}

	public PageReference SortCol() {
		List<lmscons__Training_Content__c> ListModulesSorted = new List<lmscons__Training_Content__c>();
		List<String> Txt = new List<String>();
		Map<Decimal, List<Integer>> DecMap = new Map<Decimal, List<Integer>>();
		String unq = 'a8sow82khtbsh29xlksifbg';
		List<s_record> SearchItemSorted = new List<s_record>();
		Integer Quantier = 0;
		for (s_record tc : SearchItem) {
			String c;
			if (SortColumnNumber == '1') {
				if (tc.Module.Title == null) {
					tc.Module.Title = '';
				}
				c = tc.Module.Title.toLowerCase() + unq + String.valueOf(Quantier);
				Txt.add(c);
			}
			else if (SortColumnNumber == '2') {
				if (tc.Type == Name_Module || tc.Type == Name_Quiz) {
					c = Label.MKT_On_Demand;
				}
				else if (tc.Type == Name_Event) {
					c = tc.Module.TypeEvent;
				}
				else {
					c = tc.Type;
				}
				c = c.toLowerCase() + unq + String.valueOf(Quantier);
				Txt.add(c);
			}
			else if (SortColumnNumber == '3') {
				c = '';
				if (tc.Type == Name_Event) {
					c = tc.Module.Location;
				}
				c = c.toLowerCase() + unq + String.valueOf(Quantier);
				Txt.add(c);
			}
			else if (SortColumnNumber == '4') {
				Decimal costMod = 0;
				if (tc.Module.IsPaid) {
					costMod = tc.Module.Price.UnitPrice;
				}
				List<Integer> QuantierList = new List<Integer>();
				if (DecMap.containskey(costMod)) {
					QuantierList = DecMap.get(costMod);
				}
				QuantierList.Add(Quantier);
				DecMap.put(costMod, QuantierList);
			}
			Quantier++;
		}

		if (DecMap.size() > 0) {
			List<Decimal> CostList = new List<Decimal>();
			CostList.addAll(DecMap.keySet());
			CostList.sort();
			if (AscDesc == 'desc') {
				List<Decimal> CostList2 = new List<Decimal>();
				for (Integer m = CostList.size(); m != 0; m--) {
					CostList2.add(CostList.get(m-1));
				}
				CostList = CostList2;
			}

			for (Decimal costMod : CostList) {

				if (DecMap.containskey(costMod)) {
					List<Integer> QuantierList = DecMap.get(costMod);
					for (Integer i = 0; i < QuantierList.size() ; i++) {
						s_record c = SearchItem.get(QuantierList[i]);
						SearchItemSorted.add(c);
					}
				}
			}
		}
		else {
			Txt.sort();
			if (AscDesc == 'desc') {
				List<String> str2 = new List<String>();
				for (Integer m = Txt.size(); m != 0; m--) {
					str2.add(Txt.get(m-1));
				}
				Txt = str2;
			}

			for (String s : Txt) {
				List<String> obj = s.split(unq);
				s_record c = SearchItem.get(Integer.valueOf(obj.get(1)));
				SearchItemSorted.add(c);
			}
		}
		SearchItem = SearchItemSorted;
		LastValue = SortColumnNumber;
		return null;
	}

	public class Itm {
		public Itm(Id a, LMS_Common l) {
			if (a == null || l == null) {
				return;
			}
			ShowEnroll = l.ShowEnroll(a);
			Map<String,String> infoEvent = l.getEventInfo(a);
			Location = infoEvent.Get('location');
			TypeEvent = infoEvent.Get('type');
			isExpired = (infoEvent.Get('isExpired') == 'false') ? false : true;
			TranscriptLine = l.GetTranscriptLine(a);
			//ShowRegister = true;
			return;
		}
		public String getCost() {
			String CostString = '0';
			if (Price != NULL && Price.UnitPrice != NULL) {
				CostString = HelperWithoutSharing.currencySymbol(Price.CurrencyIsoCode) + String.ValueOf(Price.UnitPrice.setScale(0).format());
			}
			return CostString;
		}
		public String ItemId { get; set; }
		public String Title { get; set; }
		public Boolean ShowDownload { get; set; }
		public Boolean ShowEnroll { get; set; }
		public Boolean IsInCart { get; set; }
		public Boolean ShowAddToCart { get; set; }
		public String DateClass { get; set; }
		public lmscons__Transcript_Line__c TranscriptLine { get; set; }
		public PricebookEntry Price { get; set; }
		public Boolean IsPaid { get; set; }
		public String Location { get; set; }
		public Boolean isExpired { get; set; }
		public Set<String> EventLocationsSet { get; set; }
		public String TypeEvent { get; set; }
		public String Description { get; set; }
		public String Type { get; set; }
		public Integer Tp { get; set; }
	}

	public class S_Courses {
		public List<Itm> Modules { get; set; }
		public Itm Course { get; set; }
	}

	public class S_LearnPaths {
		public List<S_Courses> Courses { get; set; }
		public List<Itm> Modules { get; set; }
		public Itm LearnPath { get; set; }
	}

	public class s_record {
		public Itm Module { get; set; }
		public List<Itm> Modules { get; set; }
		public List<S_Courses> Courses { get; set; }
		public List<S_LearnPaths> Learnpths { get; set; }

		public String Type { get; set; }
		public Integer Tp { get; set; }
	}

	public List<s_record> SearchItem { get; set; }
	public List<s_record> SearchItemAll { get; set; }
	public List<s_record> SearchItemPaidEvents { get; set; }



	public class UsrClass {
		public User Usr { get; set; }
		public Boolean Chk { get; set; }
	}

	public List<UsrClass> UsersToAssign { get; set; }

	public class LMS_CmObj {
		public List<Itm> Mods;
		public List<S_Courses> Courses;
		public List<S_LearnPaths> LearnPaths;
	}

	public class LMS_Common {

		private String Name_Quiz;
		private String Name_Event;
		private String Name_Module;
		private String Name_Course;
		private String Name_LP;
		private String Name_Curriculum;
		private String Name_Task;

		public LMS_Common() {

			Id cr_usr = UserInfo.getUserId();
			AssignedContent  = new Set<Id>();
			Transcript_Lines = new Map<Id, lmscons__Transcript_Line__c>();

			Name_Quiz = lmscons__Quiz__c.sObjectType.getDescribe().getLabel();
			Name_Event = lmsilt__Event__c.sObjectType.getDescribe().getLabel();
			Name_Module = lmscons__Training_Content__c.sObjectType.getDescribe().getLabel();
			Name_Course = lmscons__Training_Path__c.sObjectType.getDescribe().getLabel();
			Name_LP = lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel();
			Name_Curriculum = lmscons__Curriculum__c.sObjectType.getDescribe().getLabel();

			//throw new DebugException(String.valueOf(Name_Module));

			for (lmscons__Transcript_Line__c tl : [Select Id, lmsilt__Event__c, lmscons__Quiz__c, lmscons__Training_Content__c, lmscons__Training_Path_Item__r.lmscons__Training_Path__c, lmscons__Training_Path_Item__c, t.lmscons__Learning_Path_Item__c, t.lmscons__Learning_Path_Item__r.lmscons__Learning_Path__c, t.lmscons__Curriculum_Item__r.lmscons__Curriculum__c, t.lmscons__Curriculum_Item__c, lmscons__Training_User_License__c, lmsilt__Class__c, lmscons__Training_Content__r.lmscons__Quiz__c, lmscons__Training_User_License__r.lmscons__User__c From lmscons__Transcript_Line__c t where lmscons__Training_User_License__r.lmscons__User__c =: cr_usr]){

				if (tl.lmscons__Curriculum_Item__c != null) {
					AssignedContent.add(tl.lmscons__Curriculum_Item__r.lmscons__Curriculum__c);
				}

				if (tl.lmscons__Curriculum_Item__c == null && tl.lmscons__Learning_Path_Item__c != null) {
					AssignedContent.add(tl.lmscons__Learning_Path_Item__r.lmscons__Learning_Path__c);
				}

				if (tl.lmscons__Curriculum_Item__c == null && tl.lmscons__Learning_Path_Item__c == null && tl.lmscons__Training_Path_Item__c != null) {
					AssignedContent.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
				}

				if (tl.lmscons__Curriculum_Item__c == null && tl.lmscons__Learning_Path_Item__c == null && tl.lmscons__Training_Path_Item__c == null && tl.lmscons__Training_Content__c != NULL) {
					AssignedContent.add(tl.lmscons__Training_Content__c);
					Transcript_Lines.put(tl.lmscons__Training_Content__c, tl);
				}

				if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c == NULL && tl.lmscons__Quiz__c != NULL) {
					AssignedContent.add(tl.lmscons__Quiz__c);
					//Training_User_License.put(tl.lmscons__Quiz__c, tl.lmscons__Training_User_License__c);
					Transcript_Lines.put(tl.lmscons__Quiz__c, tl);
				}

				if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c == NULL && tl.lmsilt__Event__c != NULL) {
					AssignedContent.add(tl.lmsilt__Event__c);
					Transcript_Lines.put(tl.lmsilt__Event__c, tl);
				}

			}
		}

		public Boolean ShowEnroll(Id a) {
			if (AssignedContent.contains(a)) {
				return false;
			}
			else {
				return true;
			}
		}
		public Boolean showDownload(String modName) {
			return HelperWithoutSharing.showDownload(modName);
		}
		public lmscons__Transcript_Line__c GetTranscriptLine(Id a) {
			return Transcript_Lines.Get(a);
		}

		public Map<Id, List<lmscons__Training_Path_Item__c>> CRSMap;
		public Map<Id, List<lmscons__Learning_Path_Item__c>> LPMap;
		public Map<Id, List<lmscons__Curriculum_Item__c>> CurrMap;
		public Map<Id, List<lmsilt__Class__c>> CLSMap ;

		private Set<Id> AssignedContent;
		private Map<Id, lmscons__Transcript_Line__c> Transcript_Lines;


		public List<Itm> getModulesFromCourse(Id crsid) {
			List<Itm> li = new List<Itm>();

			if (CRSMap.containskey(crsid)) {
				for (lmscons__Training_Path_Item__c t : CRSMap.get(crsid)) {

					Itm i = new Itm(t.lmscons__Training_Content__c, this);
					i.ItemId = t.lmscons__Training_Content__c;

					if (t.lmscons__Quiz__c != null) {
						i.Type = Name_Quiz;
						i.Title = t.lmscons__Quiz__r.Name;
						i.Description = t.lmscons__Quiz__r.lmscons__Description__c;
						li.add(i);
					}
					else if (t.lmsilt__Event__c != null) {
						Map<String,String> infoEvent = getEventInfo(t.lmsilt__Event__c);
						i.Type = Name_Event;
						i.Title = t.lmsilt__Event__r.Name;
						i.Description = t.lmsilt__Event__r.lmsilt__Description__c;
						i.Location = infoEvent.Get('location');
						i.TypeEvent = infoEvent.Get('type');
						if (!i.isExpired) li.add(i);
					}
					else if (t.lmsilt__Development_Plan_Task__c != NULL) {
						i.Type = Name_Task;
						i.Title = t.lmsilt__Development_Plan_Task__r.Name;
						i.Description = t.lmsilt__Development_Plan_Task__r.lmsilt__Description__c;
						li.add(i);
					}
					else {
						i.Type = Name_Module;
						i.Title = t.lmscons__Training_Content__r.lmscons__Title__c;
						i.Description = t.lmscons__Training_Content__r.lmscons__Description__c;
						i.ShowDownload = showDownload(i.Title);
						li.add(i);
					}


				}
			}
			return li;
		}
		public Set<String> getEventLocations(Id EvtId) {
			Set<String> location = new Set<String>();
			if (CLSMap.containskey(EvtId)) {
				for (lmsilt__Class__c cl : CLSMap.get(EvtId)) {
					if (cl.lmsilt__Sessions__r != NULL) {
						for (lmsilt__Session__c sess : cl.lmsilt__Sessions__r) {
							String SessType = (sess.lmsilt__ILT_vILT__c == 'ILT') ? Label.MKT_Classroom : Label.MKT_Virtual;
							if (SessType == Label.MKT_Virtual) {
								if (!location.contains(SessType) ) {
									location.Add(SessType);
								}
							}
							if (sess.lmsilt__Session_Location__r != NULL) {
								if (!location.contains(sess.lmsilt__Session_Location__r.Name) ) {
									location.Add(sess.lmsilt__Session_Location__r.Name);
								}
							}
						}
					}
				}
			}
			return location;
		}

		public Map<String,String> getEventInfo(Id EvtId) {
			Map<String,String> EvtInfo = new Map<String,String>();
			String expired = 'true';
			//lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name
			if (CLSMap.containskey(EvtId)) {
				Set<String> location = new Set<String>();
				Set<String> typeEvnt = new Set<String>();
				for (lmsilt__Class__c cl : CLSMap.get(EvtId)) {
					if (cl.lmsilt__Sessions__r != NULL) {
						for (lmsilt__Session__c sess : cl.lmsilt__Sessions__r) {
							String SessType = (sess.lmsilt__ILT_vILT__c == 'ILT') ? Label.MKT_Classroom : Label.MKT_Virtual;
							if (SessType == Label.MKT_Virtual) {
								if (!location.contains(SessType) ) {
									location.Add(SessType);
								}
							}
							if (!typeEvnt.contains(SessType) ) {
								typeEvnt.Add(SessType);
							}
							if (sess.lmsilt__Session_Location__r != NULL) {
								if (!location.contains(sess.lmsilt__Session_Location__r.Name) ) {
									location.Add(sess.lmsilt__Session_Location__r.Name);
								}
							}
						}
					}
					if (cl.lmsilt__Start_Date__c > datetime.now()) expired = 'false';
				}
				if (location.size() > 1) {
					EvtInfo.put('location', 'choose');
				}
				else if (location.size() == 1) {
					List<String> resultList = new List<String>();
					resultList.addAll(location);
					EvtInfo.put('location', resultList[0]);
				}
				else {
					EvtInfo.put('location', '');
				}

				String typeEvntTmp = '';
				for (String tmp : typeEvnt) {
					typeEvntTmp += tmp + '/';
				}
				EvtInfo.put('type',typeEvntTmp.substring(0,typeEvntTmp.length()-1));
				EvtInfo.put('isExpired', expired);
			}
			return EvtInfo;
		}

		public LMS_CmObj getCR (Id crid) {

			LMS_CmObj l = new LMS_CmObj();
			List<Itm> Mods = new List<Itm>();
			List<S_Courses> Courses = new List<S_Courses>();
			List<S_LearnPaths> Lps = new List<S_LearnPaths>();
			if (CurrMap.containskey(crid)) {
				for (lmscons__Curriculum_Item__c cri : CurrMap.get(crid)) {
					if (cri.lmscons__Module__c != NULL || cri.lmscons__Quiz__c != NULL || cri.lmsilt__Event__c != NULL || cri.lmsilt__Development_Plan_Task__c != NULL) {
						Itm i;

						if (cri.lmscons__Quiz__c != null) {
							i = new Itm(cri.lmscons__Quiz__c, this);
							i.ItemId = cri.lmscons__Quiz__c;
							i.Type = Name_Quiz;
							i.Title = cri.lmscons__Quiz__r.Name;
							i.Description = cri.lmscons__Quiz__r.lmscons__Description__c;
							Mods.add(i);
						}
						else if (cri.lmsilt__Event__c != null) {
								i = new Itm(cri.lmsilt__Event__c, this);
								i.Type = Name_Event;
								i.ItemId = cri.lmsilt__Event__c;
								i.Title = cri.lmsilt__Event__r.Name;
								i.Description = cri.lmsilt__Event__r.lmsilt__Description__c;

								if (!i.isExpired) Mods.add(i);

						}
						else if (cri.lmsilt__Development_Plan_Task__c != NULL) {
								i = new Itm(cri.lmsilt__Development_Plan_Task__c, this);
								i.ItemId = cri.lmsilt__Development_Plan_Task__c;
								i.Type = Name_Task;
								i.Title = cri.lmsilt__Development_Plan_Task__r.Name;
								i.Description = cri.lmsilt__Development_Plan_Task__r.lmsilt__Description__c;
								Mods.add(i);
						}
						else {
							i = new Itm(cri.lmscons__Module__c, this);
							i.ItemId = cri.lmscons__Module__c;
							i.Type = Name_Module;
							i.Title = cri.lmscons__Module__r.lmscons__Title__c;
							i.Description = cri.lmscons__Module__r.lmscons__Description__c;
							i.ShowDownload = showDownload(i.Title);
							Mods.add(i);
						}

					}
					else if (cri.lmscons__Course__c != null) {
						S_Courses sc = new S_Courses();
						sc.Course = new Itm(cri.lmscons__Course__c, this);

						sc.Course.Title = cri.lmscons__Course__r.Name;
						sc.Course.Type = Name_Course;
						sc.Course.ItemId = cri.lmscons__Course__c;
						sc.Course.Description = cri.lmscons__Course__r.lmscons__Description__c;
						sc.Modules = getModulesFromCourse(cri.lmscons__Course__c);

						Courses.add(sc);
					}
					else if (cri.lmscons__Learning_Path__c != null) {
						S_LearnPaths lrnp = new S_LearnPaths();

						lrnp.LearnPath = new Itm(cri.lmscons__Learning_Path__c, this);

						lrnp.LearnPath.Title = cri.lmscons__Learning_Path__r.Name;
						lrnp.LearnPath.Type = Name_LP;
						lrnp.LearnPath.ItemId = cri.lmscons__Learning_Path__c;
						lrnp.LearnPath.Description = cri.lmscons__Learning_Path__r.lmscons__Description__c;

						LMS_CmObj t = getLP(cri.lmscons__Learning_Path__c);

						lrnp.Courses = t.Courses;
						lrnp.Modules = t.Mods;

						Lps.add(lrnp);
					}
				}
			}

			l.Mods = Mods;
			l.Courses = Courses;
			l.LearnPaths = Lps;

			return l;
		}



		public LMS_CmObj getLP (Id lpid) {

				List<Itm> Mods = new List<Itm>();
				List<S_Courses> Courses = new List<S_Courses>();
				if (LPMap.containskey(lpid)) {
					for (lmscons__Learning_Path_Item__c l : LPMap.get(lpid)) {
						if (l.lmscons__Module__c != NULL || l.lmscons__Quiz__c != NULL || l.lmsilt__Event__c != NULL || l.lmsilt__Development_Plan_Task__c != NULL) {

							Itm i;

							if (l.lmscons__Quiz__c != null) {
								i = new Itm(l.lmscons__Quiz__c, this);
								i.Type = Name_Quiz;
								i.ItemId = l.lmscons__Quiz__c;
								i.Title = l.lmscons__Quiz__r.Name;
								i.Description = l.lmscons__Quiz__r.lmscons__Description__c;
								Mods.add(i);
							}
							else if (l.lmsilt__Event__c != null) {
								i = new Itm(l.lmsilt__Event__c, this);
								i.Type = Name_Event;
								i.ItemId = l.lmsilt__Event__c;
								i.Title = l.lmsilt__Event__r.Name;
								i.Description = l.lmsilt__Event__r.lmsilt__Description__c;
								if (!i.isExpired) Mods.add(i);
							}
							else if (l.lmsilt__Development_Plan_Task__c != NULL) {
								i = new Itm(l.lmsilt__Development_Plan_Task__c, this);
								i.Type = Name_Task;
								i.ItemId = l.lmsilt__Development_Plan_Task__c;
								i.Title = l.lmsilt__Development_Plan_Task__r.Name;
								i.Description = l.lmsilt__Development_Plan_Task__r.lmsilt__Description__c;
								Mods.add(i);
							}
							else {
								i = new Itm(l.lmscons__Module__c, this);
								i.Title = l.lmscons__Module__r.lmscons__Title__c;
								i.Type = Name_Module;
								i.ItemId = l.lmscons__Module__c;
								i.Description = l.lmscons__Module__r.lmscons__Description__c;
								i.ShowDownload = showDownload(i.Title);
								Mods.add(i);
							}


						}
						else if (l.lmscons__Course__c != null) {
							S_Courses sc = new S_Courses();
							sc.Course = new Itm(l.lmscons__Course__c, this);
							//Itm i = new Itm();
							sc.Course.Title = l.lmscons__Course__r.Name;
							sc.Course.Type = Name_Course;
							sc.Course.ItemId = l.lmscons__Course__c;
							sc.Course.Description = l.lmscons__Course__r.lmscons__Description__c;
							sc.Modules = getModulesFromCourse(l.lmscons__Course__c);

							Courses.add(sc);
						}
					}
				}

			LMS_CmObj l = new LMS_CmObj();

			l.Mods = Mods;
			l.Courses = Courses;
			return l;

		}

		public void do_select(List<lmscons__Training_Path__c> ListCourses, List<lmscons__Learning_Path__c> ListLP, List<lmscons__Curriculum__c> ListCurr, List<lmsilt__Event__c> ListEvents, List<lmsilt__Development_Plan_Task__c> ListTasks) {

			Set<Id> CrsId = new Set<Id>();
			Set<Id> EventIds = new Set<Id>();
			CRSMap = new Map<Id, List<lmscons__Training_Path_Item__c>>();
			CLSMap = new Map<Id, List<lmsilt__Class__c>>();

			Set<Id> LPIds = new Set<Id>();
			LPMap = new Map<Id, List<lmscons__Learning_Path_Item__c>>();

			CurrMap = new Map<Id, List<lmscons__Curriculum_Item__c>>();
			Set<Id> CRIds = new Set<Id>();



// ---- Retrive all necessary curriculums ----

			if (ListCurr != null) {
				for (lmscons__Curriculum__c a : ListCurr) {
					CRIds.add(a.Id);
				}
			}

			for (lmscons__Curriculum_Item__c ci : [Select lmscons__Quiz__c, lmscons__Quiz__r.Name, lmscons__Quiz__r.lmscons__Description__c, lmsilt__Development_Plan_Task__c, lmsilt__Development_Plan_Task__r.Name, lmsilt__Development_Plan_Task__r.lmsilt__Description__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c, lmscons__Title__c, Name, lmscons__Module__r.lmscons__Title__c, lmscons__Module__r.lmscons__Description__c, lmscons__Module__r.Name, lmscons__Module__r.Id, lmscons__Module__c, lmscons__Learning_Path__r.lmscons__Description__c, lmscons__Learning_Path__r.Name, lmscons__Learning_Path__r.Id, lmscons__Learning_Path__c, Id, lmscons__Curriculum__c, lmscons__Course__r.lmscons__Description__c, lmscons__Course__r.Name, lmscons__Course__r.Id, lmscons__Course__c From lmscons__Curriculum_Item__c where lmscons__Curriculum__c IN : CRIds]) {
				List<lmscons__Curriculum_Item__c> cpi_list = new List<lmscons__Curriculum_Item__c>();
				if (CurrMap.containskey(ci.lmscons__Curriculum__c)) {
					cpi_list = CurrMap.get(ci.lmscons__Curriculum__c);
				}
				cpi_list.add(ci);
				CurrMap.put(ci.lmscons__Curriculum__c, cpi_list);

				if (ci.lmscons__Learning_Path__c != NULL) {
					LPIds.add(ci.lmscons__Learning_Path__c);
				}

				if (ci.lmscons__Course__c != NULL) {
					CrsId.add(ci.lmscons__Course__c);
				}

				if (ci.lmsilt__Event__c != NULL) {
					EventIds.add(ci.lmsilt__Event__c);
				}
			}


// ---- Retrive all necessary learning paths ----

			if (ListLP != null) {
				for (lmscons__Learning_Path__c a : ListLP) {
					LPIds.add(a.Id);
				}
			}
			for (lmscons__Learning_Path_Item__c lpi : [Select lmscons__Quiz__c, lmscons__Quiz__r.Name, lmscons__Quiz__r.lmscons__Description__c, lmsilt__Development_Plan_Task__c, lmsilt__Development_Plan_Task__r.Name, lmsilt__Development_Plan_Task__r.lmsilt__Description__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c, lmscons__Learning_Path__c, lmscons__Module__c, lmscons__Course__c, lmscons__Module__r.lmscons__Title__c, lmscons__Module__r.lmscons__Description__c, lmscons__Course__r.lmscons__Description__c, lmscons__Course__r.Name From lmscons__Learning_Path_Item__c where lmscons__Learning_Path__c IN : LPIds]) {
				List<lmscons__Learning_Path_Item__c> lpi_list = new List<lmscons__Learning_Path_Item__c>();
				if (LPMap.containskey(lpi.lmscons__Learning_Path__c)) {
					lpi_list = LPMap.get(lpi.lmscons__Learning_Path__c);
				}
				lpi_list.add(lpi);
				system.debug('BYSH Add LPI '+lpi.lmscons__Learning_Path__c);
				LPMap.put(lpi.lmscons__Learning_Path__c, lpi_list);

				if (lpi.lmscons__Course__c != null) {
					CrsId.add(lpi.lmscons__Course__c);
				}
				if (lpi.lmsilt__Event__c != NULL) {
					EventIds.add(lpi.lmsilt__Event__c);
				}

			}


// ---- Retrive all necessary learning courses ----

			if (ListCourses != null) {
				for (lmscons__Training_Path__c a : ListCourses) {
					CrsId.add(a.Id);
				}
			}
			for (lmscons__Training_Path_Item__c t : [Select lmscons__Quiz__c, lmscons__Quiz__r.Name, lmscons__Quiz__r.lmscons__Description__c, lmsilt__Development_Plan_Task__c, lmsilt__Development_Plan_Task__r.Name, lmsilt__Development_Plan_Task__r.lmsilt__Description__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Event__r.lmsilt__Description__c, lmscons__Training_Content__r.lmscons__Title__c, lmscons__Training_Content__r.lmscons__Description__c, lmscons__Training_Path__c, lmscons__Training_Content__c, Id From lmscons__Training_Path_Item__c where lmscons__Training_Path__c IN : CrsId]) {

				List<lmscons__Training_Path_Item__c> tp_list = new List<lmscons__Training_Path_Item__c>();
				if (CRSMap.containskey(t.lmscons__Training_Path__c)) {
					tp_list = CRSMap.get(t.lmscons__Training_Path__c);
				}

				tp_list.add(t);
				CRSMap.put(t.lmscons__Training_Path__c, tp_list);
				if (t.lmsilt__Event__c != NULL) {
					EventIds.add(t.lmsilt__Event__c);
				}
			}

// ---- Retrive all necessary classes ----
			if (ListEvents != null) {
				for (lmsilt__Event__c e : ListEvents) {
					EventIds.add(e.Id);
				}
			}
			for (lmsilt__Class__c cl : [SELECT Id, Name, lmsilt__Event__c, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Maximum_Capacity__c, lmsilt__Waitlist_Enabled__c, lmsilt__Cancellation_Policy_lookup__c, (SELECT Id, Name, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c FROM lmsilt__Sessions__r) FROM lmsilt__Class__c WHERE lmsilt__Event__c IN : EventIds]) {

				List<lmsilt__Class__c> classes_list = new List<lmsilt__Class__c>();
				if (CLSMap.containskey(cl.lmsilt__Event__c)) {
					classes_list = CLSMap.get(cl.lmsilt__Event__c);
				}

				classes_list.add(cl);
				CLSMap.put(cl.lmsilt__Event__c, classes_list);
			}

		}
	}

	public PricebookEntry getProductPricebook(Id prId) {
		if (prId != NULL && ProductIdPricebookEntry.containsKey(prId)) {
			PricebookEntry PricebookEntryItem = ProductIdPricebookEntry.get(prId);
			if (PricebookEntryItem.UnitPrice != 0) {
				return PricebookEntryItem;
			}
			else {
				return NULL;
			}
		}
		else {
			return NULL;
		}
	}
	public Boolean IsInCartProduct(Id prId) {
		return CartItemsProductsSet.Contains(prId);
	}

	public void process_items() {

		SearchItem = new List<s_record>();

		SearchItemPaidEvents = new List<s_record>();
		LMS_Common c = new LMS_Common();
		ProductIdPricebookEntry = HelperWithoutSharing.getProductsPrice(ListCourses, ListLP, ListCurr, ListEvents, ListQuizes, ListModules);
		CartItemsProductsSet = HelperWithoutSharing.getCurrentCartItemsProductsSet();
		PaidItemsProductsSet = HelperWithoutSharing.getPaidProductsSet(ProductIdPricebookEntry.keySet());
		CartCount = HelperWithoutSharing.getCurrentCartItemsCount();
		c.do_select(ListCourses, ListLP, ListCurr, ListEvents, ListTasks);

		if (ListQuizes != NULL && Search_Quiz == true) {
			for (lmscons__Quiz__c a : ListQuizes) {
				s_record s = new s_record();
				s.Type = Name_Quiz;
				s.Tp = 1;
				s.Module = new Itm(a.Id, c);
				s.Module.ItemId = a.Id;
				s.Module.Title = a.Name;
				s.Module.Type = Name_Quiz;
				s.Module.Description = a.lmscons__Description__c;
				if (getProductPricebook(a.Product__c) != NULL) {
					s.Module.IsPaid = (s.Module.Price.UnitPrice > 0) ? true : false;
					s.Module.Price = getProductPricebook(a.Product__c);
					s.Module.IsInCart = IsInCartProduct(a.Product__c);
					s.Module.ShowAddToCart = (!s.Module.IsInCart && s.Module.IsPaid && !PaidItemsProductsSet.contains(a.Product__c)) ? true : false;
				}
				else
				{
					s.Module.IsPaid = false;
				}
				SearchItem.add(s);
			}
		}

		if (ListEvents != null && Search_Event == true) {
			//throw new DebugException('ev1');
			LocationMap = new Map<Id,Set<String>>();
			for (lmsilt__Event__c  a : ListEvents) {
				s_record s = new s_record();
				s.Type = 'Event';
				s.Tp = 1;

				s.Module = new Itm(a.Id, c);

				if (s.Module.isExpired) continue;

				s.Module.ItemId = a.Id;
				s.Module.Title = a.Name;
				s.Module.Type = Name_Event;
				s.Module.Description = a.lmsilt__Description__c;
				if (getProductPricebook(a.Product__c) != NULL) {
					s.Module.Price = getProductPricebook(a.Product__c);
					s.Module.IsPaid = (s.Module.Price.UnitPrice > 0) ? true : false;
					s.Module.IsInCart = IsInCartProduct(a.Product__c);
					s.Module.ShowAddToCart = (!s.Module.IsInCart && s.Module.IsPaid && !PaidItemsProductsSet.contains(a.Product__c)) ? true : false;
				}
				else
				{
					s.Module.IsPaid = false;
				}
				Set<String> EventLocationsSet = new Set<String>();
				EventLocationsSet = c.getEventLocations(a.Id);
				s.Module.EventLocationsSet = EventLocationsSet;
				LocationMap.put(a.Id, EventLocationsSet);
				SearchItem.add(s);
			}
		}


		if (ListModules != null && Search_Module == true) {
			for (lmscons__Training_Content__c a : ListModules) {
				s_record s = new s_record();
				s.Type = Name_Module;
				s.Tp = 1;

				s.Module = new Itm(a.Id, c);
				s.Module.ItemId = a.Id;
				s.Module.Title = a.lmscons__Title__c;
				s.Module.Type = Name_Module;
				s.Module.Description = a.lmscons__Description__c;
				s.Module.ShowDownload = c.showDownload(s.Module.Title);
				if (getProductPricebook(a.Product__c) != NULL) {
					s.Module.Price = getProductPricebook(a.Product__c);
					s.Module.IsPaid = (s.Module.Price.UnitPrice > 0) ? true : false;
					s.Module.IsInCart = IsInCartProduct(a.Product__c);
					s.Module.ShowAddToCart = (!s.Module.IsInCart && s.Module.IsPaid && !PaidItemsProductsSet.contains(a.Product__c)) ? true : false;
				}
				else
				{
					s.Module.IsPaid = false;
				}
				SearchItem.add(s);
			}
		}

		if (ListCourses != null && Search_Course == true) {
			if (ListCourses != null) {
				for (lmscons__Training_Path__c a : ListCourses) {
					s_record s = new s_record();
					s.Type = Name_Course;

					s.Module = new Itm(a.Id, c);

					s.Module.Title = a.Name;
					s.Module.Description = a.lmscons__Description__c;
					s.Module.ItemId = a.Id;
					s.Modules =  c.getModulesFromCourse(a.Id);
					if (getProductPricebook(a.Product__c) != NULL) {
						s.Module.Price = getProductPricebook(a.Product__c);
						s.Module.IsPaid = (s.Module.Price.UnitPrice > 0) ? true : false;
						s.Module.IsInCart = IsInCartProduct(a.Product__c);
						s.Module.ShowAddToCart = (!s.Module.IsInCart && s.Module.IsPaid && !PaidItemsProductsSet.contains(a.Product__c)) ? true : false;
					}
					else
					{
						s.Module.IsPaid = false;
					}

					SearchItem.add(s);
				}
			}
		}

		if (ListLP != null && Search_LP == true) {

			for (lmscons__Learning_Path__c a : ListLP) {
				s_record s = new s_record();
				s.Type = Name_LP;
				s.Module = new Itm(a.Id, c);
				s.Module.Title = a.Name;
				s.Module.Description = a.lmscons__Description__c;
				if (getProductPricebook(a.Product__c) != NULL) {
					s.Module.Price = getProductPricebook(a.Product__c);
					s.Module.IsPaid = (s.Module.Price.UnitPrice > 0) ? true : false;
					s.Module.IsInCart = IsInCartProduct(a.Product__c);
					s.Module.ShowAddToCart = (!s.Module.IsInCart && s.Module.IsPaid && !PaidItemsProductsSet.contains(a.Product__c)) ? true : false;
				}
				else
				{
					s.Module.IsPaid = false;
				}
				s.Module.ItemId = a.Id;
				LMS_CmObj m = c.getLp(a.Id);
				s.Modules = m.Mods;
				s.Courses = m.Courses;
				SearchItem.add(s);
			}
		}

		if (ListCurr != null && Search_Curr == true) {
			for (lmscons__Curriculum__c a : ListCurr) {
				s_record s = new s_record();
				s.Type = Name_Curriculum;
				s.Module = new Itm(a.Id, c);
				s.Module.Title = a.Name;
				s.Module.Description = a.lmscons__Description__c;
				if (getProductPricebook(a.Product__c) != NULL) {
					s.Module.Price = getProductPricebook(a.Product__c);
					s.Module.IsPaid = (s.Module.Price.UnitPrice > 0) ? true : false;
					s.Module.IsInCart = IsInCartProduct(a.Product__c);
					s.Module.ShowAddToCart = (!s.Module.IsInCart && s.Module.IsPaid && !PaidItemsProductsSet.contains(a.Product__c)) ? true : false;
				}
				else
				{
					s.Module.IsPaid = false;
				}
				s.Module.ItemId = a.Id;
				LMS_CmObj r = c.getCR(a.Id);
				s.Modules = r.Mods;
				s.Courses = r.Courses;
				s.Learnpths = r.LearnPaths;
				SearchItem.add(s);
			}
		}
		SearchItemAll = SearchItem;
		SortCol();
	}

	/*public Itm getAsignObject() {
		Itm i = new Itm(null,null);

		if (AssignObjectType == null) return i;

		if (AssignObjectType.equalsIgnoreCase(Name_Quiz)) {
			lmscons__Quiz__c q = [SELECT Name, lmscons__Description__c FROM lmscons__Quiz__c WHERE Id =: AssignedContentId];
			i.Title = q.Name;
			i.Description = q.lmscons__Description__c;
			i.Type = AssignObjectType;
		}
		else if (AssignObjectType.equalsIgnoreCase(Name_Event)) {
			lmsilt__Event__c tc = [Select Id, Name, lmsilt__Description__c From lmsilt__Event__c where Id =: AssignedContentId];
			i.Title = tc.Name;
			i.Description = tc.lmsilt__Description__c;
			i.Type = AssignObjectType;
		}
		else if (AssignObjectType.equalsIgnoreCase(Name_Module)) {
			lmscons__Training_Content__c tc = [Select lmscons__Title__c, Id, lmscons__Description__c From lmscons__Training_Content__c where Id =: AssignedContentId];
			i.Title = tc.lmscons__Title__c;
			i.Description = tc.lmscons__Description__c;
			i.Type = AssignObjectType;
		}
		else if (AssignObjectType.equalsIgnoreCase(Name_Course)) {
			lmscons__Training_Path__c tc = [Select Name, Id, lmscons__Description__c From lmscons__Training_Path__c where Id =: AssignedContentId];
			i.Title = tc.Name;
			i.Description = tc.lmscons__Description__c;
			i.Type = AssignObjectType;
		}
		else if (AssignObjectType.equalsIgnoreCase(Name_LP)) {
			lmscons__Learning_Path__c tc = [Select Name, Id, lmscons__Description__c From lmscons__Learning_Path__c where Id =: AssignedContentId];
			i.Title = tc.Name;
			i.Description = tc.lmscons__Description__c;
			i.Type = AssignObjectType;
		}
		else if (AssignObjectType.equalsIgnoreCase(Name_Curriculum)) {
			lmscons__Curriculum__c tc = [Select Name, Id, lmscons__Description__c From lmscons__Curriculum__c where Id =: AssignedContentId];
			i.Title = tc.Name;
			i.Description = tc.lmscons__Description__c;
			i.Type = AssignObjectType;
		}
		return i;
	}*/

	public Pagereference SearchCoursesModules2() {
		SearchCoursesModules();
		return null;
	}

	public void SearchCoursesModules() {

		if (searchKeyWord != null && searchKeyWord.length() == 1) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Search term must be longer than one character while decription search'));
			return;
		}

		Map<String, Set<Id>> ContentMap = new Map<String, Set<Id>>();
		ContentMap = HelperWithoutSharing.getIdModulesCoursesLPCuFromCatalogByProfileId();
		if (ContentMap.size() > 0) {
			if (searchKeyWord != '' && searchKeyWord != null) {

				searchKeyWord = String.escapeSingleQuotes(searchKeyWord);

				String SearchKeyWordSOSL = '*'+SearchKeyWord.toLowerCase()+'*';
				String searchKeyWordSOQL = '%'+SearchKeyWord.toLowerCase()+'%';

				if (ContentMap.containsKey('Events')) {
					ListEvents = [SELECT lmsilt__Description__c, Name, Id, Product__c, Product__r.isActive From lmsilt__Event__c WHERE Name LIKE:searchKeyWordSOQL AND Id IN : ContentMap.get('Events')];
				}
				if (ContentMap.containsKey('Quizes')) {

					if (!Search_Description) {
						ListQuizes = [SELECT Name, Id, lmscons__Description__c, Product__c, Product__r.isActive FROM lmscons__Quiz__c q WHERE Name LIKE:searchKeyWordSOQL AND Id IN : ContentMap.get('Quizes')];
					}
					else {
						String searchquery='FIND\'' + String.escapeSingleQuotes(SearchKeyWordSOSL) + '\'IN ALL FIELDS RETURNING lmscons__Quiz__c(Id, Name, lmscons__Description__c, Product__c, Product__r.isActive)';
						List<List<lmscons__Quiz__c>> searchList = search.query(searchquery);
						ListQuizes = new List<lmscons__Quiz__c>();
						for (lmscons__Quiz__c t : searchList.get(0)) {
							if (ContentMap.get('Quizes').contains(t.Id)) {
								ListQuizes.add(t);
							}
						}
					}
				}

				if (ContentMap.containsKey('Modules')) {

					if (!Search_Description) {
						ListModules = [select id, Name, lmscons__Title__c, lmscons__Title_col__c, lmscons__Description__c, Product__c, Product__r.isActive from lmscons__Training_Content__c where (lmscons__Title__c LIKE:searchKeyWordSOQL OR Name LIKE:searchKeyWordSOQL) and Id IN :ContentMap.get('Modules')];
					}
					else {
						List<List<lmscons__Training_Content__c>> searchList = [FIND : SearchKeyWordSOSL IN ALL FIELDS RETURNING lmscons__Training_Content__c(Id, Name, lmscons__Title__c, lmscons__Title_col__c, lmscons__Description__c, Product__c, Product__r.isActive)];
						ListModules = new List<lmscons__Training_Content__c>();
						for (lmscons__Training_Content__c t : searchList.get(0)) {
							if (ContentMap.get('Modules').contains(t.Id)) {
								ListModules.add(t);
							}
						}
					}
				}

				if (ContentMap.containsKey('Courses')) {
					if (!Search_Description) {
						ListCourses = [select id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive from lmscons__Training_Path__c  where (Name LIKE:searchKeyWordSOQL) and Id IN :ContentMap.get('Courses')];
					}
					else {
						List<List<lmscons__Training_Path__c>> searchList = [FIND : SearchKeyWordSOSL IN ALL FIELDS RETURNING lmscons__Training_Path__c(Id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive)];
						ListCourses = new List<lmscons__Training_Path__c>();
						for (lmscons__Training_Path__c t : searchList.get(0)) {
							if (ContentMap.get('Courses').contains(t.Id)) {
								ListCourses.add(t);
							}
						}
					}
				}
				if (ContentMap.containsKey('LP')) {
					if (!Search_Description) {
						ListLP = [select Id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive  from lmscons__Learning_Path__c where (Name LIKE:searchKeyWordSOQL) and Id IN :ContentMap.get('LP')];
					}
					else {
						List<List<lmscons__Learning_Path__c>> searchList = [FIND : SearchKeyWordSOSL IN ALL FIELDS RETURNING lmscons__Learning_Path__c(Id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive)];
						ListLP = new List<lmscons__Learning_Path__c>();
						for (lmscons__Learning_Path__c t : searchList.get(0)) {
							if (ContentMap.get('LP').contains(t.Id)) {
								ListLP.add(t);
							}
						}
					}
				}

				if (ContentMap.containsKey('Cu')) {
					if (!Search_Description) {
						ListCurr = [select Id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive from lmscons__Curriculum__c  where (Name LIKE:searchKeyWordSOQL) and Id IN :ContentMap.get('Cu')];
					}
					else {
						List<List<lmscons__Curriculum__c>> searchList = [FIND :SearchKeyWordSOSL IN ALL FIELDS RETURNING lmscons__Curriculum__c (Id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive)];
						ListCurr = new List<lmscons__Curriculum__c>();
						for (lmscons__Curriculum__c t : searchList[0]) {
							if (ContentMap.get('Cu').contains(t.Id)) {
								ListCurr.add(t);
							}
						}
					}
				}
			}
			else {
				if (ContentMap.containsKey('Quizes')) {
					ListQuizes = [SELECT Id, Name, lmscons__Description__c,Product__c, Product__r.isActive FROM lmscons__Quiz__c WHERE Id IN : ContentMap.get('Quizes')];
				}
				if (ContentMap.containsKey('Events')) {
					ListEvents = [select lmsilt__Description__c, Name, Id, Product__c, Product__r.isActive From lmsilt__Event__c where Id IN : ContentMap.get('Events')];
				}
				if (ContentMap.containsKey('Modules')) {
					ListModules = [select id, Name, lmscons__Title__c, lmscons__Title_col__c, lmscons__Description__c, Product__c, Product__r.isActive from lmscons__Training_Content__c where Id IN : ContentMap.get('Modules')];
				}
				if (ContentMap.containsKey('Courses')) {
					ListCourses = [select id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive from lmscons__Training_Path__c where  Id IN : ContentMap.get('Courses')];
				}
				if (ContentMap.containsKey('LP')) {
					ListLP = [select id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive from lmscons__Learning_Path__c where  Id IN : ContentMap.get('LP')];
				}
				if (ContentMap.containsKey('Cu')) {
					ListCurr = [select id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive from lmscons__Curriculum__c where  Id IN : ContentMap.get('Cu')];
				}
			}
		}

		if (ListQuizes != NULL) {
			if (ListQuizes.size()==0){
				ListQuizes = NULL;
			}
		}
		if (ListModules != null) {
			if (ListModules.size()==0){
				ListModules = null;
			}
		}
		if (ListCourses != null) {
			if (ListCourses.size()==0){
				ListCourses = null;
			}
		}
		if (ListLP != null) {
			if (ListLP.size()==0){
				ListLP = null;
			}
		}
		if (ListCurr != null) {
			if (ListCurr.size()==0) {
				ListCurr = null;
			}
		}
		process_items();
	}
	public void AddToCart() {
		MKT_PaymentController paymentObj = new MKT_PaymentController();
		paymentObj.ObjId = idObjectToAdd;
		paymentObj.TypeObj = TypeObj;
		paymentObj.InitPaymentObjects();
		if (!paymentObj.EnrollPaymentError) {
			Boolean cartResult = paymentObj.AddToCart();
		}
	}
	public PageReference addToMyTraining() {

		if (!HelperWithoutSharing.isAccessUser()) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'It looks like you’re logged in from a sandbox account. Please log in using your production account credentials to view the contents of this page.'));
			return NULL;
		}
		String objType = '';
		User u = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
		List<User> UserList = new List<User>();
		UserList.add(u);
		try {
			Id testId = [SELECT Id FROM lmscons__Quiz__c WHERE Id =: idTraining].id;
			lmscons__Quiz__c Quiz = [SELECT Id FROM lmscons__Quiz__c WHERE Id =: idTraining];
			objType = 'lmscons__Quiz__c';
			lmscons.LMSUtil.assignQuiz(UserList, Quiz);
			List<lmscons__Transcript_Line__c> UserLisense = [SELECT id, lmscons__Training_Content__r.lmscons__Quiz__c, lmscons__Training_User_License__r.lmscons__User__c FROM lmscons__Transcript_Line__c where lmscons__Training_User_License__r.lmscons__User__c =: UserInfo.getUserId() AND lmscons__Quiz__c =: Quiz.Id AND lmscons__Curriculum_Item__c = NULL AND lmscons__Learning_Path_Item__c = NULL AND lmscons__Training_Path_Item__c = NULL];
			if (UserLisense.size() == 1){
				//return new PageReference('/apex/lmscons__Quiz?id=' + UserLisense[0].lmscons__Training_Content__r.lmscons__Quiz__c + '&uid=' + UserLisense[0].lmscons__Training_User_License__r.lmscons__User__c + '&TLID=' + UserLisense[0].id + '&Type=Quiz&pid=' + UserLisense[0].lmscons__Training_Content__r.lmscons__Quiz__c + '&inline=1&retUrl=/apex/c__MKT_MyTrainingPage');
				PageReference LaunchPage = new PageReference('/apex/lmscons__Quiz?id=' + UserLisense[0].lmscons__Training_Content__r.lmscons__Quiz__c + '&uid=' + UserLisense[0].lmscons__Training_User_License__r.lmscons__User__c + '&TLID=' + UserLisense[0].id + '&Type=Quiz&pid=' + UserLisense[0].lmscons__Training_Content__r.lmscons__Quiz__c + '&inline=1&retUrl=/apex/c__MKT_MyTrainingPage');
				RedirectUrl = LaunchPage.getUrl();
			}
		}
		catch(Exception e){ }

		try {
			Id testId = [select id from lmscons__Training_Content__c where id=:idTraining].id;
			objType = 'lmscons__Training_Content__c';
			lmscons__Training_Content__c tc = [select id from lmscons__Training_Content__c where id=:idTraining];
			lmscons.LMSUtil.assignModule(UserList, tc);
			List<lmscons__Transcript_Line__c> UserLisense = [SELECT lmscons__Training_User_License__c FROM lmscons__Transcript_Line__c t where lmscons__Training_User_License__r.lmscons__User__c =: UserInfo.getUserId() AND lmscons__Training_Content__c =: tc.Id AND lmscons__Curriculum_Item__c = null AND lmscons__Learning_Path_Item__c = null AND lmscons__Training_Path_Item__c = null];
			if (UserLisense.size() == 1){
				//return new PageReference('/apex/lmscons__ConsumerDirector?action=LaunchContent&tuId='+UserLisense[0].lmscons__Training_User_License__c);
				PageReference LaunchPage = new PageReference('/apex/lmscons__ConsumerDirector?action=LaunchContent&tuId='+UserLisense[0].lmscons__Training_User_License__c);
				//RedirectUrl = '/apex/lmscons__ConsumerDirector?action=LaunchContent&tuId='+UserLisense[0].lmscons__Training_User_License__c;//
				RedirectUrl = LaunchPage.getUrl();
			}
		}
		catch(system.Exception e){ }

		/*try {
			Id testId = [select id from lmscons__Training_Path__c where id=:idTraining].id;
			objType = 'lmscons__Training_Path__c';
			lmscons__Training_Path__c tp2 = [select id from lmscons__Training_Path__c where id=:idTraining];
			lmsilt.ILTUtil.assignCourse(UserList, tp2);
		}
		catch(system.Exception e){ }

		try {
			Id testId = [select id from lmscons__Learning_Path__c where id=:idTraining].id;
			lmscons__Learning_Path__c lp = [select id from lmscons__Learning_Path__c where id=:idTraining];
			objType = 'lmscons__Learning_Path__c';
			lmsilt.ILTUtil.assignLearningPath(UserList, lp);
		}
		catch(system.Exception e){ }

		try {
			Id testId = [select id from lmscons__Curriculum__c where id=:idTraining].id;
			lmscons__Curriculum__c cu = [select id from lmscons__Curriculum__c where id=:idTraining];
			objType = 'lmscons__Curriculum__c';
			lmsilt.ILTUtil.assignCurriculum(UserList, cu);
		}
		catch(system.Exception e){ }

		try {
			Id testId = [select id from lmsilt__Event__c where id=:idTraining].id;
			lmsilt__Event__c cu = [select id from lmsilt__Event__c where id=:idTraining];
			lmsilt.ILTUtil.assignEvent(UserList, cu);
		}
		catch(system.Exception e){ }*/

		process_items();
		return NULL;

	}

	public void GetNewCoursesOnThePage () {
		List<MKT_CourseOnThePage__c> NewCoursesList = [SELECT Id, Name, Description__c, Course__c, Type__c, Image__c, Page__c, Position__c FROM MKT_CourseOnThePage__c WHERE Page__c = 'Courses' AND Image__c != NULL AND Position__c != NULL];
		for (MKT_CourseOnThePage__c NewCourse :NewCoursesList) {
			if (NewCourse.Position__c == 'Left' && LeftLandingCourse == NULL) {
				LeftLandingCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Center' && CenterLandingCourse == NULL) {
				CenterLandingCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Right' && RightLandingCourse == NULL) {
				RightLandingCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Left Top' && NewCourse.Type__c == 'Featured' && LeftTopCourse == NULL) {
				LeftTopCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Right Top' && NewCourse.Type__c == 'Featured' && RightTopCourse == NULL) {
				RightTopCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Left Bottom' && NewCourse.Type__c == 'Featured' && LeftBottomCourse == NULL) {
				LeftBottomCourse = new NewCourses(NewCourse);
			}
			else if (NewCourse.Position__c == 'Right Bottom' && NewCourse.Type__c == 'Featured' && RightBottomCourse == NULL) {
				RightBottomCourse = new NewCourses(NewCourse);
			}
		}
	}

	public class NewCourses {
		public String Position {get;set;}
		public String Title {get;set;}
		public String Image {get;set;}
		public String EventId {get;set;}
		public String Description {get;set;}

		public NewCourses(MKT_CourseOnThePage__c NewCourse) {
			Position = NewCourse.Position__c;
			Title = NewCourse.Name;
			Image = 'img/' + NewCourse.Image__c;
			EventId = NewCourse.Course__c;
			Description  = NewCourse.Description__c;
		}
	}

	public Boolean renderPage {get {
		if (renderPage == null) {
			return true;
		} else {
			return renderPage;
		}
	}
	set;	}

	public Boolean IsManager { get; private set; }
	public String trainingFilter { get; set; }

	//-----------------------------------------------------------------------
	//--                          TEST METHODS                            ---
	//-----------------------------------------------------------------------


	private class TestData {

		public User Master;
		public User Slave;
		public User notConsUs;

		public Id ModuleId;
		public Id CourseId;
		public Id LPId;
		public Id CurrId;
		public Id QuizId;
		public Id EventId;
	}

	private static testMethod TestData CreateTestData() {
		TestData td = new TestData();
		lmscons.LMSUtil.AdminOperation = true;

		User master_user = new User(alias = 'test', email='test@test.com', emailencodingkey='UTF-8', lastname='test', languagelocalekey='en_US',
		localesidkey='en_US', profileid = UserInfo.getProfileId(), timezonesidkey='America/Los_Angeles', username='test@testSF1111k2.com', lmscons__Cornerstone_ID__c='ILT masta');
		insert master_user; //test

		User slave_user = new User(alias = 'test2', email='test2@test.com', emailencodingkey='UTF-8', lastname='test2', languagelocalekey='en_US',
		localesidkey='en_US', profileid = UserInfo.getProfileId(), timezonesidkey='America/Los_Angeles', ManagerId = master_user.Id, username='test2@testSF1111k2.com', lmscons__Cornerstone_ID__c='ILT slave');
		insert slave_user; //test

		User notConsumerUser = new  User(alias = 'test3', email='test3@test.com', emailencodingkey='UTF-8', lastname='test3', languagelocalekey='en_US',
		localesidkey='en_US', profileid = UserInfo.getProfileId(), timezonesidkey='America/Los_Angeles', ManagerId = master_user.Id, username='test3@testSF1111k2.com', lmscons__Cornerstone_ID__c='');
		insert notConsumerUser;

		/*UserRole god_role = new UserRole();
		UserRole slave_role = new UserRole();
		UserRole nCU_role1 = new UserRole();
		// Create roles
		//System.runAs(slave_user) {
			god_role.Name = 'ILT God';
			insert god_role; //test

			nCU_role1.Name = 'ILT nCU master';
			insert nCU_role1;//test

			slave_role.Name = 'ILT Slave';
			slave_role.ParentRoleId = god_role.Id;
			insert slave_role; //test

			slave_user.UserRoleId = slave_role.Id;
			master_user.UserRoleId = god_role.Id;
			notConsumerUser.UserRoleId = nCU_role1.Id;

			update slave_user; //test
			update master_user; //test
			update notConsumerUser;//test

		//}*/

		lmscons__Training_Content__c module = new lmscons__Training_Content__c( lmscons__Title__c = 'ILT Training me', lmscons__Cornerstone_ID__c = 'ILT af' );
		insert module; //test

		lmscons__Training_Content__c module2 = new lmscons__Training_Content__c( lmscons__Title__c = 'ILT Training me2', lmscons__Cornerstone_ID__c = 'ILT af2' );
		insert module2; //test

		lmscons__Training_Content_License__c cl =  new lmscons__Training_Content_License__c( lmscons__Training_Content__c = module.Id );
		insert cl; //test

		lmscons__Transcript__c t = new lmscons__Transcript__c( lmscons__Trainee__c = master_user.Id );
		insert t; //test

		lmscons__Transcript__c t2 = new lmscons__Transcript__c( lmscons__Trainee__c = slave_user.Id );
		insert t2; //test

		lmscons__Training_User_License__c tul = new lmscons__Training_User_License__c( lmscons__Content_License__c = cl.Id, lmscons__User__c = master_user.Id, lmscons__Cornerstone_ID__c = 'ILT bysh' );
		insert tul; //test

		lmscons__Training_User_License__c tul2 = new lmscons__Training_User_License__c( lmscons__Content_License__c = cl.Id, lmscons__User__c = slave_user.Id, lmscons__Cornerstone_ID__c = 'ILT byshbyzak' );
		insert tul2; //test

		tul = new lmscons__Training_User_License__c( lmscons__Content_License__c = cl.Id, lmscons__User__c = slave_user.Id, lmscons__Cornerstone_ID__c = 'ILT byzak' );
		insert tul; //test

		// --------------- Create Event  ----------------------------------
		lmsilt__Event__c event = new lmsilt__Event__c();
		event.Name = 'Event Bysh';
		insert event; //test
		lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = event.Id, lmsilt__Waitlist_Enabled__c = true, lmsilt__Maximum_Capacity__c = 1);
		insert cls;
		lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(2), lmsilt__End_Date_Time__c=system.now().addDays(3));
		insert ss;
		lmscons__Training_Content__c trCont = new lmscons__Training_Content__c(lmsilt__Event__c = event.Id);
		insert trCont;
		lmscons__Training_Content_License__c cl1 =  new lmscons__Training_Content_License__c( lmscons__Training_Content__c = trCont.Id );
		insert cl1; //test
		// --------------- Create Quiz  ----------------------------------
		lmscons__Quiz__c Quizz = new lmscons__Quiz__c( Name = 'ILT Quiz for tests' );
		insert Quizz; //test

		// --------------- Create Full Course  ----------------------------------
		lmscons__Training_Path__c course = new  lmscons__Training_Path__c( Name = 'ILT Training cs' );
		insert course; //test
		lmscons__Training_Path_Item__c course_item = new lmscons__Training_Path_Item__c();
		course_item.lmscons__Training_Path__c = course.Id;
		course_item.lmscons__Quiz__c = Quizz.Id;
		course_item.lmscons__Training_Content__c = module2.Id;
		insert course_item; //test
		lmscons__Training_Path_Item__c course_item2 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = course.Id,lmsilt__Event__c = event.Id, lmscons__Training_Content__c = module2.Id);
		insert course_item2;
		lmscons__Training_Path_Item__c course_item3 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = course.Id,lmscons__Training_Content__c = module.Id);
		insert course_item3;
		// --------------- Create Full Learning Path  ----------------------------------
		lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c( Name = 'ILT lp test 11');
		insert lp; //test
		List<lmscons__Learning_Path_Item__c> lp_items = new List<lmscons__Learning_Path_Item__c>();
		lmscons__Learning_Path_Item__c lp_item = new lmscons__Learning_Path_Item__c();
		lp_item.lmscons__Module__c = module.Id;
		lp_item.lmscons__Learning_Path__c = lp.Id;
		lp_items.add(lp_item);
		lmscons__Learning_Path_Item__c lp_item2 = new lmscons__Learning_Path_Item__c();
		lp_item2.lmscons__Course__c = course.Id;
		lp_item2.lmscons__Learning_Path__c = lp.Id;
		lp_items.add(lp_item2);
		lmscons__Learning_Path_Item__c lp_item3 = new lmscons__Learning_Path_Item__c();
		lp_item3.lmscons__Quiz__c = Quizz.Id;
		lp_item3.lmscons__Learning_Path__c = lp.Id;
		lp_items.add(lp_item3);
		lmscons__Learning_Path_Item__c lp_item4 = new lmscons__Learning_Path_Item__c();
		lp_item4.lmsilt__Event__c = event.Id;
		lp_item4.lmscons__Learning_Path__c = lp.Id;
		lp_items.add(lp_item4);
		insert lp_items; //test*/

		// --------------- Create Full Curriculum ----------------------------------

		lmscons__Curriculum__c curr = new lmscons__Curriculum__c( Name = 'ILT Cura' );
		insert curr; //test

		List<lmscons__Curriculum_Item__c> curr_items = new List<lmscons__Curriculum_Item__c>();
		lmscons__Curriculum_Item__c curr_item = new lmscons__Curriculum_Item__c();
		curr_item.lmscons__Module__c = module.Id;
		curr_item.lmscons__Curriculum__c = curr.Id;
		curr_items.add(curr_item);

		lmscons__Curriculum_Item__c curr_item2 = new lmscons__Curriculum_Item__c();
		curr_item2.lmscons__Course__c  = course.Id;
		curr_item2.lmscons__Curriculum__c = curr.Id;
		curr_items.add(curr_item2);

		lmscons__Curriculum_Item__c curr_item3 = new lmscons__Curriculum_Item__c();
		curr_item3.lmscons__Learning_Path__c  = lp.Id;
		curr_item3.lmscons__Curriculum__c = curr.Id;
		curr_items.add(curr_item3);

		lmscons__Curriculum_Item__c curr_item4 = new lmscons__Curriculum_Item__c();
		curr_item4.lmscons__Quiz__c = Quizz.Id;
		curr_item4.lmscons__Curriculum__c = curr.Id;
		curr_items.add(curr_item4);

		insert curr_items; //test

		lmscons__Catalog__c cat = new lmscons__Catalog__c(Name='test');
		insert cat; //test

		lmscons__Catalog_Profile__c catProfile = new lmscons__Catalog_Profile__c(lmscons__Profile_Id__c = master_user.profileid, lmscons__Profile_Name__c='Test catalog profile', lmscons__Catalog__c=cat.Id);
		insert catProfile; //test

		lmscons__Catalog_Curriculum__c curr_cat = new lmscons__Catalog_Curriculum__c( lmscons__Catalog__c = cat.Id, lmscons__Curriculum__c = curr.Id);
		insert curr_cat; //test

		lmscons__Catalog_Learning_Path__c  lp_cat = new lmscons__Catalog_Learning_Path__c ( lmscons__Catalog__c = cat.Id, lmscons__Learning_Path__c = lp.Id );
		insert lp_cat; //test

		lmscons__Catalog_Training_Path__c  course_cat = new lmscons__Catalog_Training_Path__c ( lmscons__Catalog__c = cat.Id, lmscons__Training_Path__c  = course.Id );
		insert course_cat; //test

		lmscons__Catalog_Quiz__c  quiz_cat = new lmscons__Catalog_Quiz__c ( lmscons__Catalog__c = cat.Id, lmscons__Quiz__c  = Quizz.Id );
		insert quiz_cat; //test

		lmsilt__Event_Catalog__c  event_cat = new lmsilt__Event_Catalog__c ( lmsilt__Catalog__c = cat.Id, lmsilt__Event__c  = event.Id );
		insert event_cat; //test
		lmscons__Catalog_Course__c mod_cat = new lmscons__Catalog_Course__c(lmscons__Training_Course__c = module.id, lmscons__Catalog__c = cat.Id);
		insert mod_cat;
		td.ModuleId = module.Id;
		td.CourseId = course.Id;
		td.LPId = lp.Id;
		td.CurrId = curr.Id;
		td.QuizId = Quizz.Id;
		td.EventId = event.Id;
		td.Master = master_user;
		td.Slave = slave_user;
		td.notConsUs = notConsumerUser;
		return td;
	}


	static testMethod void Test_search() {

		TestData td = CreateTestData();
		System.runAs(td.Master) {
			test.startTest();
			MKT_Courses sc1 = new MKT_Courses();
			sc1.searchKeyWord = 'byzak';
			sc1.Search_Description = true;
			sc1.SearchCoursesModules();
			sc1.searchKeyWord = '';
			sc1.SearchCoursesModules();
			system.assert(sc1.ListCourses.size() > 0);
			test.stopTest();
		}
	}

	static testMethod void Test_search2() {

		TestData td = CreateTestData();
		System.runAs(td.Master) {
			test.startTest();
			MKT_Courses sc2 = new MKT_Courses();
			sc2.searchKeyWord = 'byzak';
			sc2.AdvancedSearch = true;
			sc2.ToggleSearch();
			sc2.ToggleSearch();
			sc2.SearchCoursesModules2();
			system.assert(sc2.ListCourses == NULL);
			test.stopTest();
		}
	}

	static testMethod void Test_calView() {

		TestData td = CreateTestData();
		System.runAs(td.Master) {
			test.startTest();
			MKT_Courses sc2 = new MKT_Courses();
			sc2.calView();
			sc2.ThisMonth();
			sc2.MonthBack();
			sc2.MonthForward();
			system.assert(sc2.calendar != NULL);
			sc2.listView();


			test.stopTest();

		}
	}

	static testMethod void Test_Ev() {
		TestData td = CreateTestData();
		System.runAs(td.Master) {

			test.startTest();
			MKT_Courses sc1 = new MKT_Courses();
			Itm Litm;
			sc1.idTraining = td.EventId;
			sc1.addToMyTraining();
			sc1.idTraining = td.QuizId;
			sc1.addToMyTraining();
			sc1.idTraining = td.ModuleId;
			sc1.addToMyTraining();
			Integer countMod = [SELECT COUNT() FROM lmscons__Transcript_Line__c WHERE lmscons__Training_Content__c = :td.ModuleId];
			system.assert(countMod > 0);
			test.stopTest();
		}
	}

	static testMethod void testMKT_UpdateTotalHoursClass(){
		lmsilt__Event__c e = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
		insert e;
		test.startTest();
			lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e.Id, lmsilt__Total_hours__c = '1,5h');
			insert cls;
			List<lmsilt__Class__c> clsResult = [SELECT Id, MKT_Total_hours__c FROM lmsilt__Class__c WHERE ID = :cls.ID];
			System.assertEquals(clsResult[0].MKT_Total_hours__c, '1.5h');

			lmsilt__Class__c cls2 = new lmsilt__Class__c(lmsilt__Event__c = e.Id, lmsilt__Total_hours__c = '1,5h');
			insert cls2;
			cls2.lmsilt__Total_hours__c = '0,5h';
			update cls2;
		test.stopTest();
	}
	static testMethod void testMKT_UpdateTotalHoursModule(){
		test.startTest();
			lmscons__Training_Content__c TC = new lmscons__Training_Content__c(lmscons__Title__c = 'Empty Module', lmscons__Duration__c = 10);
			insert TC;
			TC.lmscons__Duration__c = 126;
			update TC;
			List<lmscons__Training_Content__c> modResult = [SELECT Id, MKT_Total_hours__c FROM lmscons__Training_Content__c WHERE ID = :TC.ID];
			System.assertEquals(modResult[0].MKT_Total_hours__c, '2.1h');
		test.stopTest();
	}
	static testMethod void testMKT_UpdateTotalHoursCourse(){
		test.startTest();
			lmscons__Training_Path__c Course = new lmscons__Training_Path__c(lmscons__Duration__c = 10);
			insert Course;
			Course.lmscons__Duration__c = 126;
			update Course;
			List<lmscons__Training_Path__c> CourseResult = [SELECT Id, MKT_Total_hours__c FROM lmscons__Training_Path__c WHERE ID = :Course.ID];
			System.assertEquals(CourseResult[0].MKT_Total_hours__c, '2.1h');
		test.stopTest();
	}
	static testMethod void testMKT_UpdateTotalHoursLP(){
		test.startTest();
			lmscons__Learning_Path__c LP = new lmscons__Learning_Path__c(lmscons__Duration__c = 10);
			insert LP;
			LP.lmscons__Duration__c = 126;
			update LP;
			List<lmscons__Learning_Path__c> LPResult = [SELECT Id, MKT_Total_hours__c FROM lmscons__Learning_Path__c WHERE ID = :LP.ID];
			System.assertEquals(LPResult[0].MKT_Total_hours__c, '2.1h');
		test.stopTest();
	}
	static testMethod void testMKT_UpdateTotalHoursCurriculum(){
		test.startTest();
			lmscons__Curriculum__c Curriculum = new lmscons__Curriculum__c(lmscons__Duration__c = 10);
			insert Curriculum;
			Curriculum.lmscons__Duration__c = 126;
			update Curriculum;
			List<lmscons__Curriculum__c> CurriculumResult = [SELECT Id, MKT_Total_hours__c FROM lmscons__Curriculum__c WHERE ID = :Curriculum.ID];
			System.assertEquals(CurriculumResult[0].MKT_Total_hours__c, '2.1h');
		test.stopTest();
	}

	static testMethod void testFilteringAndSorting(){
		TestData td = CreateTestData();
		test.startTest();
			MKT_Courses sc1 = new MKT_Courses();
			sc1.SortColumnNumber = '2';
			sc1.SortCol();
			sc1.SortColumnNumber = '3';
			sc1.SortCol();
			sc1.SortColumnNumber = '4';
			sc1.SortCol();
			sc1.AscDesc = 'desc';
			sc1.SortColumnNumber = '3';
			sc1.SortCol();
			sc1.SortColumnNumber = '4';
			sc1.SortCol();

			sc1.getLocations();
			sc1.SelectedLocation = Label.MKT_All;
			sc1.FilterLocation();

			List<String> options = sc1.getCourseTypes();
			System.assert(options.size() > 0);
		test.stopTest();
	}
}