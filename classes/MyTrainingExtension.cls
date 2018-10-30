public without sharing class MyTrainingExtension {

	public Id EventIdDetails {
		get;
		set;
	}
	public Id ClassIdDetails {
		get;
		set;
	}
	public lmsilt__Event__c EventDetails {
		get;
		set;
	}
	public List<lmsilt__Class__c> ClassesList {
		get;
		set;
	}
	public List<lmsilt__Session__c> SessionsList {
		get;
		set;
	}
	public lmsilt__Roster__c Roster {
		get;
		set;
	}
	public List<lmsilt__Material__c> MaterialsList {
		get;
		set;
	}
	public Integer MaterialsSize {
		get;
		set;
	}
	public Integer SessionsDetailSize {
		get;
		set;
	}
	public Integer ClassSize {
		get;
		set;
	}
	public Map <Id, String> idLO_DescLO {
		get;
		set;
	}
	public Id AssignId {
		get;
		set;
	}
	private String ClassId;
	public String getClassId() {
		return this.ClassId;
	}
	public void setClassId(String ClassId) {
		this.ClassId = ClassId;
	}
	public class CurriculumEntry {
		public String TitleCurriculum {
			get;
			set;
		}
		public String Type {
			get {
				return 'Curriculum';
			}
			set;
		}
		public lmscons__Transcript_Line__c CItem {
			get;
			set;
		}
		public List<LpEntry> LpEntryList {
			get;
			set;
		}
		public List<CoEntry> CoEntryList {
			get;
			set;
		}
		public List<MEntry> MEntryList {
			get;
			set;
		}
		public List<CuSeq> CuSeqList {
			get;
			set;
		}
		public List<LpSeq> LpSeqList {
			get;
			set;
		}
	}
	public class LpEntry {
		public String TitleLp {
			get;
			set;
		}
		public String Type {
			get {
				return 'Learning Path';
			}
			set;
		}
		public lmscons__Transcript_Line__c LpItem {
			get;
			set;
		}
		public List<CoEntry> CoEntryList {
			get;
			set;
		}
		public List<MEntry> MEntryList {
			get;
			set;
		}
		public List<LpSeq> LpSeqList {
			get;
			set;
		}
	}
	public class CuSeq {
		public Decimal Seq {
			get;
			set;
		}
		public String Title {
			get;
			set;
		}
		public String Description {
			get;
			set;
		}
		public String Type {
			get {
				return 'Curriculum';
			}
			set;
		}
		public Boolean Stop {
			get;
			set;
		}
		public List<CurriculumEntry> CurriculumEntryList = new List<CurriculumEntry> ();
		public CurriculumEntry CurriculumEntryObj {
			get;
			set;
		}
	}
	public class LpSeq {
		public Decimal Seq {
			get;
			set;
		}
		public String Title {
			get;
			set;
		}
		public String Description {
			get;
			set;
		}
		public String Type {
			get {
				return 'Learning Path';
			}
			set;
		}
		public Boolean Stop {
			get;
			set;
		}
		public List<LpEntry> LpEntryList = new List<LpEntry> ();
		public LpEntry LpEntryObj {
			get;
			set;
		}
	}
	public class CoEntry {
		public String TitleCo {
			get;
			set;
		}
		public String Type {
			get {
				return 'Course';
			}
			set;
		}
		public lmscons__Transcript_Line__c CoItem {
			get;
			set;
		}
		public lmscons__Training_Path_Assignment_Progress__c TPAPItem {
			get;
			set;
		}
		public List<MEntry> MEntryList {
			get;
			set;
		}
	}
	public class MEntry {
		public String TitleM {
			get;
			set;
		}
		public String Type {
			get {
				return 'Module';
			}
			set;
		}
		public lmscons__Transcript_Line__c MItem {
			get;
			set;
		}
		public lmsilt__Session__c Session {
			get;
			set;
		}
		public Boolean showDownload {
			get {
				String modName = (MItem.lmscons__Training_Content__r.lmscons__Title__c != NULL) ? MItem.lmscons__Training_Content__r.lmscons__Title__c : '';
				return HelperWithoutSharing.showDownload(modName);
			}
		}
	}

	public Double preProgress;
	public Boolean preProgressZero = false;
	public Boolean NotAllComplete = false;
	public String preTitle = 'Start';
	public String preType;
	public String preDesc;
	public String preDescSeq;
	public Decimal preSequence;
	public Decimal preSequenceR;
	public Boolean EnforceSequence;
	public Boolean EnforceSequenceLP;
	public Boolean EnforceSequenceCu;
	public String tmpTitle;
	public Integer i = 0;
	public Map <Id, Boolean> PreReqMap {
		get;
		set;
	}
	public List<CurriculumEntry> TrainingList {
		get {
			idLO_DescLO = new Map <Id, String> ();
			if (TrainingList == null) {
				TrainingList = new List<CurriculumEntry> ();
				Map <String, Set<Id>> Type_Id = new Map <String, Set<Id>> ();
				Set<Id> preReqIds = new Set<Id> ();
				List<lmscons__Transcript_Line__c> transcript_lines = HelperWithoutSharing.getAssignmentList();

				Map <Id, lmsilt__Session__c> ClassId_SessionObj = new Map <Id, lmsilt__Session__c> ();
				Set<Id> ClassIds = new Set<Id> ();
				Set<Id> TPSet = new Set<Id> ();
				for (lmscons__Transcript_Line__c tl: transcript_lines) {
					Set<Id> tmpIds = new Set<Id> ();
					if (tl.lmscons__Curriculum_Assignment__c != null) {
						preReqIds.add(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c);
						if (Type_Id.containsKey('Curr')) {
							Type_Id.get('Curr').add(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c);
						}
						else {
							Type_Id.put('Curr', tmpIds);
							Type_Id.get('Curr').add(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c);
						}
					}
					else if (tl.lmscons__Learning_Path_Assignment__c != null) {
						preReqIds.add(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c);
						if (Type_Id.containsKey('LP')) {
							Type_Id.get('LP').add(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c);
						}
						else {
							Type_Id.put('LP', tmpIds);
							Type_Id.get('LP').add(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c);
						}
					}
					else if (tl.lmscons__Training_Path_Item__c != null) {
						preReqIds.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
						if (Type_Id.containsKey('Co')) {
							Type_Id.get('Co').add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
						}
						else {
							Type_Id.put('Co', tmpIds);
							Type_Id.get('Co').add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
						}
					}
					else if (tl.lmscons__Quiz__c != null) {
						preReqIds.add(tl.lmscons__Quiz__c);
						if (Type_Id.containsKey('Q')) {
							Type_Id.get('Q').add(tl.lmscons__Quiz__c);
						}
						else {
							Type_Id.put('Q', tmpIds);
							Type_Id.get('Q').add(tl.lmscons__Quiz__c);
						}
					}
					else if (tl.lmsilt__Event__c != null) {
						preReqIds.add(tl.lmsilt__Event__c);
						if (Type_Id.containsKey('E')) {
							Type_Id.get('E').add(tl.lmsilt__Event__c);
						}
						else {
							Type_Id.put('E', tmpIds);
							Type_Id.get('E').add(tl.lmsilt__Event__c);
						}
					}
					else {
						preReqIds.add(tl.lmscons__Training_Content__c);
						if (Type_Id.containsKey('M')) {
							Type_Id.get('M').add(tl.lmscons__Training_Content__c);
						}
						else {
							Type_Id.put('M', tmpIds);
							Type_Id.get('M').add(tl.lmscons__Training_Content__c);
						}
					}

					if (tl.lmscons__Training_Path_Item__c != null) {
						TPSet.add(
						tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
					}
					if (tl.lmsilt__Class__c != null) {
						ClassIds.add(tl.lmsilt__Class__c);
					}
					if (tl.lmscons__Curriculum_Assignment__c != null) {
						if (tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c == null) {
							idLO_DescLO.put(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c, '');
						}
						else {
							idLO_DescLO.put(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c, tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c);
						}
					}
					if (tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c != null) {
						if (tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c == null) {
							idLO_DescLO.put(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c, '');
						}
						else {
							idLO_DescLO.put(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c, tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c);
						}
					}
					if (tl.lmscons__Training_Path_Item__c != null) {
						if (tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__r.lmscons__Description__c == null) {
							idLO_DescLO.put(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c, '');
						}
						else {
							idLO_DescLO.put(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c, tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__r.lmscons__Description__c);
						}
					}
					if (tl.lmsilt__Event__c != null) {
						if (tl.lmsilt__Event__r.lmsilt__Description__c == null) {
							idLO_DescLO.put(tl.lmsilt__Event__c, '');
						}
						else {
							idLO_DescLO.put(tl.lmsilt__Event__c, tl.lmsilt__Event__r.lmsilt__Description__c);
						}
					}
					if (tl.lmscons__Training_Content__r.lmscons__Description__c == null) {
						idLO_DescLO.put(tl.lmscons__Training_Content__c, '');
					}
					else {
						idLO_DescLO.put(tl.lmscons__Training_Content__c, tl.lmscons__Training_Content__r.lmscons__Description__c);
					}
					if(tl.lmscons__Quiz__c != NULL) {
						if (tl.lmscons__Quiz__r.lmscons__Description__c == null) {
							idLO_DescLO.put(tl.lmscons__Training_Content__c, '');
						}
						else {
							idLO_DescLO.put(tl.lmscons__Training_Content__c, tl.lmscons__Quiz__r.lmscons__Description__c);
						}
					}

				}
				if (Type_id.size()> 0) {
					PreReqMap = HelperWithoutSharing.checkPrerequisitesMap(preReqIds);
				}
				List<lmsilt__Session__c> sessions = new List<lmsilt__Session__c> ();
				sessions = [SELECT Id, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, lmsilt__Class__r.Name, lmsilt__Meeting__r.lmsilt__Meetingkey__c FROM lmsilt__Session__c WHERE lmsilt__ILT_vILT__c = 'vILT'
				and lmsilt__Class__c IN: ClassIds and lmsilt__Meeting_Type__c != null and lmsilt__Meeting__c != null];
				if (sessions.size()> 0) {
					for (lmsilt__Session__c s: sessions) {
						Long UnixStartDate = s.lmsilt__Start_Date_Time__c.getTime() - (1000 * 60 * 15);
						Long UnixEndDate = s.lmsilt__End_Date_Time__c.getTime();
						Long UnixNow = DateTime.now().getTime();
						If(UnixNow>= UnixStartDate && UnixNow <= UnixEndDate) {

							ClassId_SessionObj.put(s.lmsilt__Class__c, s);
						}
					}
				}

				for (lmscons__Transcript_Line__c tl: transcript_lines) {
					if (tl.lmscons__Training_Path_Item__c != null) {
						TPSet.add(
						tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
					}
				}
				List<lmscons__Training_Path_Assignment_Progress__c> TPAPList = HelperWithoutSharing.getCourseAssignmentList(TPSet);
				Map <String, lmscons__Training_Path_Assignment_Progress__c> TPAPMap = new Map <String, lmscons__Training_Path_Assignment_Progress__c> ();
				for (lmscons__Training_Path_Assignment_Progress__c tpap: TPAPList) {
					TPAPMap.put('' + tpap.lmscons__Training_Path__c + UserInfo.getUserID(), tpap);
				}
				Set<Id> currIds = new Set<Id> ();
				Set<Id> LpIds = new Set<Id> ();
				Set<Id> courseIds = new Set<Id> ();
				Set<Id> courseIdsNLP = new Set<Id> ();
				Set<Id> LpItemIds = new Set<Id> ();
				Set<Id> CuItemIds = new Set<Id> ();
				CurriculumEntry CurrEntry = new CurriculumEntry();
				LpEntry LpEntry = new LpEntry();
				LpSeq LpSeq = new LpSeq();
				CuSeq CuSeq = new CuSeq();
				CoEntry CoEntry = new CoEntry();
				MEntry MEntry = new MEntry();
				for (lmscons__Transcript_Line__c tl: transcript_lines) {
				System.Debug('tl======================='+tl);

					if (tl.lmscons__Curriculum_Assignment__c == null && tl.lmscons__Learning_Path_Assignment__c == null) {

						if (tl.lmscons__Training_Path_Item__c != null) {

							EnforceSequence = tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__r.lmscons__Enforce_Curriculum_Sequence__c;
							if (courseIds.contains(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c) == false) {
								preProgressZero = false;
								NotAllComplete = false;
								CurrEntry = new CurriculumEntry();
								CurrEntry.TitleCurriculum = null;
								CoEntry = new CoEntry();
								CoEntry.CoItem = tl;
								CoEntry.TPAPItem = TPAPMap.get('' + tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c + UserInfo.getUserID());
								CoEntry.MEntryList = new List<MEntry> ();
								CurrEntry.CoEntryList = new List<CoEntry> ();
								courseIds.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
								MEntry = new MEntry();
								MEntry.MItem = tl;

								if (tl.lmsilt__Class__c != null) {
									if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
										MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
									}
								}

								CoEntry.MEntryList.add(MEntry);
								CurrEntry.CoEntryList.add(CoEntry);
								TrainingList.add(CurrEntry);
								if (tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c != null) {
									preSequence = tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c;
									preSequenceR = preSequence;
									preDescSeq = '';
									if (tl.lmscons__Percent_Complete__c != 100.00) {
										preDesc = tl.lmscons__Training_Content__r.lmscons__Title__c + ' \\n';
									}
									else {
										preDesc = '';
									}
									preProgress = tl.lmscons__Percent_Complete__c;
									if (tl.lmscons__Percent_Complete__c == 0.00) {
										preProgressZero = true;
										NotAllComplete = true;
									}
								}
								else {
									preDescSeq = '';
									preDesc = '';
								}
							}
							else {
								if (tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c != null) {
									if (tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c != preSequence) {
										if (preProgressZero == true) {
											if (EnforceSequence == true) {
												NotAllComplete = true;
												if (tl.lmscons__Percent_Complete__c != 100.00) {
													if (preSequenceR == tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c) {
														preDescSeq = preDescSeq + tl.lmscons__Training_Content__r.lmscons__Title__c + ' \\n';
													}
													else {
														preDesc = preDesc + preDescSeq;
														preDescSeq = tl.lmscons__Training_Content__r.lmscons__Title__c + ' \\n';
													}
													preSequenceR = tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c;
													tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c = -1;
													tl.lmscons__Training_Content__r.lmscons__Description__c = '"You need to complete courses:\\n' + preDesc + 'Before you can launch this course."';
												}
												else {
													if (preSequenceR == tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c) {
														preSequenceR = tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c;
														tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c = -2;
														if (tl.lmscons__Percent_Complete__c != 100.00) {
															preDescSeq = preDescSeq + tl.lmscons__Training_Content__r.lmscons__Title__c + ' \\n';
														}
													}
													else {
														preSequenceR = tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c;
														tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c = -2;
													}
												}
											}
										}
										else {
											if (EnforceSequence == true) {
												if (NotAllComplete == true) {
													if (tl.lmscons__Percent_Complete__c != 100.00) {
														preDesc = preDesc + preDescSeq;
														tl.lmscons__Training_Content__r.lmscons__Description__c = '"You need to complete courses:\\n' + preDesc + 'Before you can launch this course."';
														if (preSequenceR != tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c) {
															preDesc = preDesc + tl.lmscons__Training_Content__r.lmscons__Title__c + '\\n';
															preDescSeq = '';
														}
														else {
															preDescSeq = tl.lmscons__Training_Content__r.lmscons__Title__c + '\\n';
														}
														tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c = -1;
													}
												}
												else {
													if (tl.lmscons__Percent_Complete__c != 100.00) {
														preDesc = preDesc + tl.lmscons__Training_Content__r.lmscons__Title__c + '\\n';
														NotAllComplete = true;
													}
												}
											}
										}
										if (tl.lmscons__Percent_Complete__c == 0.00) {
											preProgressZero = true;
											NotAllComplete = true;
										}
										else {
											preProgressZero = false;
										}
									}
									else {
										if (tl.lmscons__Percent_Complete__c == 0.00) {
											preDescSeq = preDescSeq + tl.lmscons__Training_Content__r.lmscons__Title__c + '\\n';
											preProgressZero = true;
											NotAllComplete = true;
										}
										else {
											preProgressZero = false;
										}
									}
									preProgress = tl.lmscons__Percent_Complete__c;
									preSequence = tl.lmscons__Training_Path_Item__r.lmscons__Sequence__c;
								}
								MEntry = new MEntry();
								MEntry.MItem = tl;

								if (tl.lmsilt__Class__c != null) {
									if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
										MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
									}
								}

								CoEntry.MEntryList.add(MEntry);
							}
						}
						if (tl.lmscons__Training_Path_Item__c == null) {
							CurrEntry = new CurriculumEntry();
							CurrEntry.TitleCurriculum = null;
							MEntry = new MEntry();
							MEntry.MItem = tl;

							if (tl.lmsilt__Class__c != null) {
								if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
									MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
								}
							}

							CurrEntry.MEntryList = new List<MEntry> ();
							MEntry = new MEntry();
							MEntry.MItem = tl;

							if (tl.lmsilt__Class__c != null) {
								if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
									MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
								}
							}

							CurrEntry.MEntryList.add(MEntry);
							TrainingList.add(CurrEntry);
						}
					}
					if (tl.lmscons__Curriculum_Assignment__c == null) {
						if (tl.lmscons__Learning_Path_Assignment__c != null) {
							System.Debug('tl.lmscons__Learning_Path_Assignment__c========='+tl.lmscons__Learning_Path_Assignment__c);
							EnforceSequenceLP = tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Enforce_Sequence__c;
							System.Debug('EnforceSequenceLP========='+EnforceSequenceLP);
							System.Debug('LpIds========='+LpIds);
							if (LpIds.contains(tl.lmscons__Learning_Path_Assignment__c) == false) {

								CurrEntry = new CurriculumEntry();
								CurrEntry.LpEntryList = new List<LpEntry> ();
								LpEntry = new LpEntry();
								LpEntry.LpItem = tl;
								LpEntry.CoEntryList = new List<CoEntry> ();
								LpEntry.MEntryList = new List<MEntry> ();
								LpEntry.LpSeqList = new List<LpSeq> ();
								LpIds.add(tl.lmscons__Learning_Path_Assignment__c);
								CurrEntry.LpEntryList.add(LpEntry);
								TrainingList.add(CurrEntry);
								courseIds.clear();
								if (tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c != null) {
									preProgressZero = false;
									NotAllComplete = false;
									preSequence = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
									preSequenceR = preSequence;
									preDescSeq = '';
									if(tl.lmscons__Learning_Path_Item__r.lmscons__Quiz__c != NULL){
										preProgress = tl.lmscons__Percent_Complete__c;
										tmpTitle = tl.lmscons__Learning_Path_Item__r.lmscons__Quiz__r.Name;
										preType = 'Quiz';
									}
									else if(tl.lmscons__Learning_Path_Item__r.lmsilt__Event__c != NULL){
										preProgress = tl.lmscons__Percent_Complete__c;
										tmpTitle = tl.lmscons__Learning_Path_Item__r.lmsilt__Event__r.Name;
										preType = 'Event';
									}
									else if (tl.lmscons__Learning_Path_Item__r.lmscons__Module__c != null) {
										preProgress = tl.lmscons__Percent_Complete__c;
										tmpTitle = tl.lmscons__Training_Content__r.lmscons__Title__c;
										preType = 'Module';
									}
									else {
										try {
											preProgress = TPAPMap.get('' + tl.lmscons__Learning_Path_Item__r.lmscons__Course__c + UserInfo.getUserID()).lmscons__Progress_Training_Path__c;
											tmpTitle = tl.lmscons__Learning_Path_Item__r.lmscons__Course__r.Name;
											preType = 'Course';
										}
										catch (system.exception e) {}
									}
									if (preProgress != 100.00) {
										preDesc = tmpTitle + ' \\n';
									}
									else {
										preDesc = '';
									}
									if (preProgress == 0.00) {
										preProgressZero = true;
										NotAllComplete = true;
									}
								}
								else {
									preDesc = '';
									preDescSeq = '';
									preProgressZero = false;
									NotAllComplete = false;
								}
								System.Debug('preDesc LP========='+preDesc);
							}
							System.Debug('LpItemIds========='+LpItemIds);
							if (LpItemIds.contains(tl.lmscons__Learning_Path_Item__c) == false) {
								LpSeq = new LpSeq();
								LpSeq.Seq = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
								Double CurrentProgress = 0.00;
								if (tl.lmscons__Learning_Path_Item__r.lmscons__Module__c != null) {
									LpSeq.Title = tl.lmscons__Learning_Path_Item__r.lmscons__Module__r.lmscons__Title__c;
									LpSeq.Type = 'Module';
									CurrentProgress = tl.lmscons__Percent_Complete__c;
									tmpTitle = tl.lmscons__Learning_Path_Item__r.lmscons__Module__r.lmscons__Title__c;
								}
								else if(tl.lmscons__Learning_Path_Item__r.lmscons__Quiz__c != NULL) {
									LpSeq.Title = tl.lmscons__Learning_Path_Item__r.lmscons__Quiz__r.Name;
									LpSeq.Type = 'Quiz';
									CurrentProgress = tl.lmscons__Percent_Complete__c;
									tmpTitle = tl.lmscons__Learning_Path_Item__r.lmscons__Quiz__r.Name;
								}
								else if(tl.lmscons__Learning_Path_Item__r.lmsilt__Event__c != NULL) {
									LpSeq.Title = tl.lmscons__Learning_Path_Item__r.lmsilt__Event__r.Name;
									CurrentProgress = tl.lmscons__Percent_Complete__c;
									tmpTitle = tl.lmscons__Learning_Path_Item__r.lmsilt__Event__r.Name;
									LpSeq.Type = 'Event';
								}
								else {
									try {
										LpSeq.Title = tl.lmscons__Learning_Path_Item__r.lmscons__Course__r.Name;
										LpSeq.Type = 'Course';
										CurrentProgress = TPAPMap.get('' + tl.lmscons__Learning_Path_Item__r.lmscons__Course__c + UserInfo.getUserID()).lmscons__Progress_Training_Path__c;
										tmpTitle = tl.lmscons__Learning_Path_Item__r.lmscons__Course__r.Name;
									}
									catch (system.exception e) {}
								}

								if (tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c != null) {
									if (tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c != preSequence) {
										if (preProgressZero == true) {
											if (EnforceSequenceLP == true) {
												NotAllComplete = true;
												if (CurrentProgress != 100.00) {
													if (preSequenceR == tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c) {
														preDescSeq = preDescSeq + LpSeq.Title + ' \\n';
													}
													else {
														preDesc = preDesc + preDescSeq;
														preDescSeq = LpSeq.Title + ' \\n';
													}
													preSequenceR = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
													tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c = -1;
													LpSeq.Seq = -1;
													LpSeq.Description = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
													tl.lmscons__Training_Content__r.lmscons__Description__c = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
												}
												else {
													if (preSequenceR == tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c) {
														preSequenceR = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
														tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c = -2;
														LpSeq.Seq = -2;
														if (CurrentProgress != 100.00) {
															preDescSeq = preDescSeq + tmpTitle + ' \\n';
														}
													}
													else {
														preSequenceR = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
														tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c = -2;
														LpSeq.Seq = -2;
													}
												}
											}
										}
										else {
											if (EnforceSequenceLP == true) {
												if (NotAllComplete == true) {
													if (CurrentProgress != 100.00) {
														preDesc = preDesc + preDescSeq;
														tl.lmscons__Training_Content__r.lmscons__Description__c = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
														LpSeq.Description = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
														if (preSequenceR != tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c) {
															preDesc = preDesc + tmpTitle + '\\n';
															preDescSeq = '';
														}
														else {
															preDescSeq = tmpTitle + '\\n';
														}
														tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c = -1;
														LpSeq.Seq = -1;
													}
												}
												else {
													if (CurrentProgress != 100.00) {
														preDesc = preDesc + tmpTitle + '\\n';
														NotAllComplete = true;
													}
												}
											}
										}
										if (CurrentProgress == 0.00) {
											preProgressZero = true;
											NotAllComplete = true;
										}
										else {
											preProgressZero = false;
										}
									}
									else {
										if (CurrentProgress == 0.00) {
											preProgressZero = true;
											NotAllComplete = true;
										}
										else {
											preProgressZero = false;
										}
									}
									preType = LpSeq.Type;
									preProgress = CurrentProgress;
									preSequence = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
								}

								LpSeq.LpEntryObj = new LpEntry();
								LpSeq.LpEntryObj.CoEntryList = new List<CoEntry> ();
								LpSeq.LpEntryObj.MEntryList = new List<MEntry> ();
								LpEntry.LpSeqList.add(LpSeq);
							}
							else {
								if (EnforceSequenceLP == true) {}
							}
							if (tl.lmscons__Training_Path_Item__c != null) {

								if (courseIds.contains(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c) == false) {

									CoEntry = new CoEntry();
									CoEntry.CoItem = tl;
									CoEntry.MEntryList = new List<MEntry> ();
									CoEntry.TPAPItem = TPAPMap.get('' + tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c + UserInfo.getUserID());
									LpEntry.CoEntryList.add(CoEntry);
									LpSeq.LpEntryObj.CoEntryList.add(CoEntry);
									courseIds.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									CoEntry.MEntryList.add(MEntry);
								}
								else {

									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									CoEntry.MEntryList.add(MEntry);
								}
							}
							if (tl.lmscons__Training_Path_Item__c == null) {

								MEntry = new MEntry();
								MEntry.MItem = tl;

								if (tl.lmsilt__Class__c != null) {
									if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
										MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
									}
								}

								LpEntry.MEntryList.add(MEntry);
								LpSeq.LpEntryObj.MEntryList.add(MEntry);
							}
						}
					}

					if (tl.lmscons__Curriculum_Assignment__c != null) {
						EnforceSequenceCu = tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Enforce_Sequence__c;
						if (currIds.contains(tl.lmscons__Curriculum_Assignment__c) == false) {
							CurrEntry = new CurriculumEntry();
							CurrEntry.LpEntryList = new List<LpEntry> ();
							CurrEntry.CoEntryList = new List<CoEntry> ();
							CurrEntry.MEntryList = new List<MEntry> ();
							LpIds.clear();
							courseIds.clear();
							TrainingList.add(CurrEntry);
							currIds.add(tl.lmscons__Curriculum_Assignment__c);
							CurrEntry.TitleCurriculum = tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.Name;
							CurrEntry.CItem = tl;
							CurrEntry.CuSeqList = new List<CuSeq> ();
							if (tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c != null) {

								preProgressZero = false;
								NotAllComplete = false;
								preSequence = tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c;
								preSequenceR = preSequence;
								preDescSeq = '';
								if (tl.lmscons__Curriculum_Item__r.lmscons__Module__c != null) {
									preProgress = tl.lmscons__Percent_Complete__c;
									tmpTitle = tl.lmscons__Training_Content__r.lmscons__Title__c;
									preType = 'Module';
								}
								else if (tl.lmscons__Curriculum_Item__r.lmscons__Learning_Path__c != null) {
									preProgress = tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c;
									tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Learning_Path__r.Name;
									preType = 'Learning Path';
								}
								else if (tl.lmscons__Curriculum_Item__r.lmsilt__Event__c != null) {
									preProgress = tl.lmscons__Percent_Complete__c;
									tmpTitle = tl.lmscons__Curriculum_Item__r.lmsilt__Event__r.Name;
									preType = 'Event';
								}
								else if (tl.lmscons__Curriculum_Item__r.lmscons__Quiz__c != null) {
									preProgress = tl.lmscons__Percent_Complete__c;
									tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Quiz__r.Name;
									preType = 'Quiz';
								}
								else {

									if (TPAPMap.containsKey('' + tl.lmscons__Curriculum_Item__r.lmscons__Course__c + UserInfo.getUserID())) {
										preProgress = TPAPMap.get('' + tl.lmscons__Curriculum_Item__r.lmscons__Course__c + UserInfo.getUserID()).lmscons__Progress_Training_Path__c;

										tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Course__r.Name;

										preType = 'Course';
									}
								}
								try {
									if (preProgress != 100.00) {
										preDesc = tmpTitle + ' \\n';
									}
									else {
										preDesc = '';
									}
								}
								catch (system.exception e) {
									preDesc = '';
								}
								if (preProgress == 0.00) {
									preProgressZero = true;
									NotAllComplete = true;
								}

							}
							else {
								preDesc = '';
								preDescSeq = '';
								preProgressZero = false;
								NotAllComplete = false;
							}
						}
						if (CuItemIds.contains(tl.lmscons__Curriculum_Item__c) == false) {
							CuSeq = new CuSeq();
							CuSeq.Seq = tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c;
							Double CurrentProgress = 0.00;
							if (tl.lmscons__Curriculum_Item__r.lmscons__Module__c != null) {
								CuSeq.Title = tl.lmscons__Curriculum_Item__r.lmscons__Module__r.lmscons__Title__c;
								CuSeq.Type = 'Module';
								CurrentProgress = tl.lmscons__Percent_Complete__c;
								tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Module__r.lmscons__Title__c;
							}
							else if (tl.lmscons__Curriculum_Item__r.lmscons__Learning_Path__c != null) {
								CurrentProgress = tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c;
								tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Learning_Path__r.Name;
								CuSeq.Title = tl.lmscons__Curriculum_Item__r.lmscons__Learning_Path__r.Name;
								CuSeq.Type = 'Learning Path';
							}
							else if (tl.lmscons__Curriculum_Item__r.lmsilt__Event__c != null) {
								CuSeq.Title = tl.lmscons__Curriculum_Item__r.lmsilt__Event__r.Name;
								CuSeq.Type = 'Event';
								CurrentProgress = tl.lmscons__Percent_Complete__c;
								tmpTitle = tl.lmscons__Curriculum_Item__r.lmsilt__Event__r.Name;
							}
							else if (tl.lmscons__Curriculum_Item__r.lmscons__Quiz__c != null) {
								CuSeq.Title = tl.lmscons__Curriculum_Item__r.lmscons__Quiz__r.Name;
								CuSeq.Type = 'Quiz';
								CurrentProgress = tl.lmscons__Percent_Complete__c;
								tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Quiz__r.Name;
							}
							else {

								CuSeq.Title = tl.lmscons__Curriculum_Item__r.lmscons__Course__r.Name;

								CuSeq.Type = 'Course';
								if (TPAPMap.containsKey('' + tl.lmscons__Curriculum_Item__r.lmscons__Course__c + UserInfo.getUserID())) {
									CurrentProgress = TPAPMap.get('' + tl.lmscons__Curriculum_Item__r.lmscons__Course__c + UserInfo.getUserID()).lmscons__Progress_Training_Path__c;
								}
								tmpTitle = tl.lmscons__Curriculum_Item__r.lmscons__Course__r.Name;
							}

							if (tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c != null) {
								if (tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c != preSequence) {
									if (preProgressZero == true) {
										if (EnforceSequenceCu == true) {
											NotAllComplete = true;
											if (CurrentProgress != 100.00) {
												if (preSequenceR == tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c) {
													preDescSeq = preDescSeq + CuSeq.Title + ' \\n';
												}
												else {
													preDesc = preDesc + preDescSeq;
													preDescSeq = CuSeq.Title + ' \\n';
												}
												preSequenceR = tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c;
												tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c = -1;
												CuSeq.Seq = -1;

												CuSeq.Description = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
												tl.lmscons__Training_Content__r.lmscons__Description__c = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
											}
											else {
												if (preSequenceR == tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c) {
													preSequenceR = tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c;
													tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c = -2;
													CuSeq.Seq = -2;
													if (CurrentProgress != 100.00) {
														preDescSeq = preDescSeq + tmpTitle + ' \\n';
													}
												}
												else {
													preSequenceR = tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c;
													tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c = -2;
													CuSeq.Seq = -2;
												}
											}
										}
									}
									else {
										if (EnforceSequenceCu == true) {
											if (NotAllComplete == true) {
												if (CurrentProgress != 100.00) {
													preDesc = preDesc + preDescSeq;
													tl.lmscons__Training_Content__r.lmscons__Description__c = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
													CuSeq.Description = '"You need to complete: \\n' + preDesc + 'Before you can launch this Module."';
													if (preSequenceR != tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c) {
														preDesc = preDesc + tmpTitle + '\\n';
														preDescSeq = '';
													}
													else {
														preDescSeq = tmpTitle + '\\n';
													}
													tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c = -1;
													CuSeq.Seq = -1;
												}
											}
											else {
												if (CurrentProgress != 100.00) {
													preDesc = preDesc + tmpTitle + '\\n';
													NotAllComplete = true;
												}
											}
										}
									}
									if (CurrentProgress == 0.00) {
										preProgressZero = true;
										NotAllComplete = true;
									}
									else {
										preProgressZero = false;
									}
								}
								else {
									if (CurrentProgress == 0.00) {
										preProgressZero = true;
										NotAllComplete = true;
									}
									else {
										preProgressZero = false;
									}
								}
							}
							preType = CuSeq.Type;
							preProgress = CurrentProgress;
							preSequence = tl.lmscons__Curriculum_Item__r.lmscons__Sequence__c;

							CuSeq.CurriculumEntryObj = new CurriculumEntry();
							CuSeq.CurriculumEntryObj.CoEntryList = new List<CoEntry> ();
							CuSeq.CurriculumEntryObj.MEntryList = new List<MEntry> ();
							CuSeq.CurriculumEntryObj.LpEntryList = new List<LpEntry> ();
							CuSeq.CurriculumEntryObj.LpSeqList = new List<LpSeq> ();
							CurrEntry.CuSeqList.add(CuSeq);
						}
						if (tl.lmscons__Learning_Path_Assignment__c != null) {
							if (LpIds.contains(tl.lmscons__Learning_Path_Assignment__c) == false) {
								LpEntry = new LpEntry();
								LpEntry.LpItem = tl;
								LpEntry.CoEntryList = new List<CoEntry> ();
								LpEntry.MEntryList = new List<MEntry> ();
								courseIds.clear();
								LpIds.add(tl.lmscons__Learning_Path_Assignment__c);
								CurrEntry.LpEntryList.add(LpEntry);
								LpEntry.LpSeqList = new List<LpSeq> ();
								CuSeq.CurriculumEntryObj.LpEntryList.add(LpEntry);
							}
							if (LpItemIds.contains(tl.lmscons__Learning_Path_Item__c) == false) {
								LpSeq = new LpSeq();
								LpSeq.Seq = tl.lmscons__Learning_Path_Item__r.lmscons__Sequence__c;
								LpSeq.LpEntryObj = new LpEntry();
								LpSeq.LpEntryObj.CoEntryList = new List<CoEntry> ();
								LpSeq.LpEntryObj.MEntryList = new List<MEntry> ();
								LpEntry.LpSeqList.add(LpSeq);
							}


							if (tl.lmscons__Training_Path_Item__c != null) {
								if (courseIds.contains(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c) == false) {
									CoEntry = new CoEntry();
									CoEntry.CoItem = tl;
									CoEntry.MEntryList = new List<MEntry> ();
									CoEntry.TPAPItem = TPAPMap.get('' + tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c + UserInfo.getUserID());
									LpEntry.CoEntryList.add(CoEntry);
									LpSeq.LpEntryObj.CoEntryList.add(CoEntry);
									courseIds.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									CoEntry.MEntryList.add(MEntry);
								}
								else {
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									CoEntry.MEntryList.add(MEntry);
								}
							}
							if (tl.lmscons__Training_Path_Item__c == null) {
								if (LpIds.contains(tl.lmscons__Learning_Path_Assignment__c) == false) {
									LpEntry.MEntryList = new List<MEntry> ();
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									LpEntry.MEntryList.add(MEntry);
									LpSeq.LpEntryObj.MEntryList.add(MEntry);
								}
								else {
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									LpEntry.MEntryList.add(MEntry);
									LpSeq.LpEntryObj.MEntryList.add(MEntry);
								}
							}
						}
						else {
							if (tl.lmscons__Training_Path_Item__c != null) {
								if (courseIdsNLP.contains(tl.lmscons__Curriculum_Item__c) == false) {
									CoEntry = new CoEntry();
									CoEntry.CoItem = tl;
									CoEntry.MEntryList = new List<MEntry> ();
									CoEntry.TPAPItem = TPAPMap.get('' + tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c + UserInfo.getUserID());
									CurrEntry.CoEntryList.add(CoEntry);
									CuSeq.CurriculumEntryObj.CoEntryList.add(CoEntry);
									courseIdsNLP.add(tl.lmscons__Curriculum_Item__c);
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									CoEntry.MEntryList.add(MEntry);
								}
								else {
									MEntry = new MEntry();
									MEntry.MItem = tl;

									if (tl.lmsilt__Class__c != null) {
										if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
											MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
										}
									}

									CoEntry.MEntryList.add(MEntry);
								}
							}
							if (tl.lmscons__Training_Path_Item__c == null && tl.lmscons__Learning_Path_Assignment__c == null) {
								MEntry = new MEntry();
								MEntry.MItem = tl;

								if (tl.lmsilt__Class__c != null) {
									if (ClassId_SessionObj.containsKey(tl.lmsilt__Class__c)) {
										MEntry.Session = ClassId_SessionObj.get(tl.lmsilt__Class__c);
									}
								}

								CurrEntry.MEntryList.add(MEntry);
								CuSeq.CurriculumEntryObj.MEntryList.add(MEntry);
							}
						}
					}
				}
			}

			return TrainingList;
		}
		set;
	}
}