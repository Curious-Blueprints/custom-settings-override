public without sharing virtual class SuperUserBase {

  public List<sObject>      settings      { get; set; }
  public List<SettingField> settingFields { get; set; }
  public Integer		        activeIndex   { get; set; }
  public Boolean			      editMode		  { get; set; }
  public List<Map<String, Object>> settingsMaps { get; set; }
  public Map<String, SObject> activeSettingMap { get; private set; }
  public Map<String, SObject> activeCloneMap { get; private set; }
  public sObject		        activeSetting { get; private set; }
  public sObject            activeClone   { get; private set; }

  private String objectType;
  private static String[] excludedFields = new String[] {'Id', 'IsDeleted', 'SystemModstamp', 'SetupOwnerId'};
  private static String[] firstFields = new String[] {'Name'};
  private static String[] lastFields = new String[] {'LastModifiedDate', 'LastModifiedById', 'CreatedDate', 'CreatedById'};

  public void setObjectType(String value) {
    if (this.objectType == null) {
      this.objectType = value;
      initialize();
    }
  }

  public String getObjectType() {
    return this.objectType;
  }

  public void deleteSetting() {
    database.deleteResult result = database.delete(this.activeSetting);
    this.resetDetailPane();
    this.activeClone = null;
    this.settings.remove(this.activeIndex);
    this.activeIndex = null;
  }

  public void resetDetailPane() {
    this.activeSetting = null;
  }

  public SuperUserBase() {}

  public void initialize() {
    this.settingFields = getSettingFields(this.getObjectType());
    this.settingFields.sort();
    this.settings = querySettings(this.getObjectType(), this.settingFields);
    this.settingsMaps = getSettingsMaps(this.settingFields, this.settings);
    this.editMode = false;
    this.resetDetailPane();
    system.debug('INITIALIZATION DONE');
  }

  public void asdfSetting() {
    system.debug(LoggingLevel.ERROR, 'GETTING HERE!');
    database.saveresult result;
    if(this.activeSetting.get('id') != null) {
      result = database.update(this.activeSetting);

    } else {

      result = database.insert(this.activeSetting);
      system.debug(result.isSuccess());
      system.debug(result);
      this.settings.add(this.activeSetting);
    }

    this.resetDetailPane();
    this.toggleEditMode();
    this.activeClone = null;
    this.activeIndex = null;
  }

  public void newSetting() {
    String objectype = this.getObjectType();
    sObjectType item = Schema.getGlobalDescribe().get(objectype);
    sObject newItem = item.newSObject();
    this.activeSetting = newItem;
    this.editMode = true;
  }

  private List<Map<String, Object>> getSettingsMaps(SettingField[] fieldList, SObject[] settingList) {
    List<Map<String, Object>> settingMapList = new List<Map<String, Object>>();

    for (SObject setting : settingList) {
      Map<String, Object> settingMap = new Map<String, Object>();

      for (SettingField field : fieldList) {
        settingMap.put(field.apiName, setting.get(field.apiName));
      }

      settingMap.put('Id', setting.get('Id'));
      settingMapList.add(settingMap);
    }

    return settingMapList;
  }

  public void setActiveSetting() {
    Id settingId = System.currentPageReference().getParameters().get('settingId');
    system.debug(System.currentPageReference().getParameters());
    if (settingId == null) {
      this.activeSetting = null;
      this.activeClone = null;
    } else {
      this.activesetting = getSettingById(settingId);
      this.activeClone = this.activeSetting.clone(true, true, true, true);
    }
  }

  public void toggleEditMode() {
    this.editMode = !this.editMode;
  }

  public void cancelEditMode() {
    if (this.activeClone != null) {
      this.activeSetting = this.activeClone.clone(true, true, true, true);
    } else {
      this.activeSetting = null;
    }
    this.editMode = false;
  }

  public Boolean getIsActiveEdit() {
    return this.activeSetting != null && this.editMode;
  }

  public Boolean getIsActiveView() {
    return this.activeSetting != null && !this.editMode;
  }

  public sObject getSettingById(Id settingId) {
    for (Integer i = 0; i < this.settings.size(); i++) {
      if (this.settings.get(i).Id == settingId) {
        this.activeIndex = i;
        return this.settings.get(i);
      }
    }

    return null;
  }

  public List<sObject> querySettings(String objectType, List<settingField> fields) {
    string query = 'SELECT Id, ';

    for (Integer i = 0; i < fields.size(); i++) {
      query += i + 1 < fields.size() ? fields.get(i).apiName + ', ' : fields.get(i).apiName + ' ';
    }

    query += 'FROM ' + objectType;

    return database.query(query);
  }

  public List<SettingField> getSettingFields(string SettingName) {
    Map<String, sObjectField> setFields = Schema.getGlobalDescribe().get(settingName).getDescribe().fields.getMap();
    List<SettingField> theFields = new List<SettingField>();

    for (String key : setFields.keySet()) {
      DescribeFieldResult result = setFields.get(key).getDescribe();
      if (!isMemberOf(result.getName(), excludedFields)) {
        theFields.add(convertDescribeFieldToSettingField(result));
      }
    }

    return theFields;
  }

  private static Boolean isMemberOf(String candidate, String[] memberGroup) {
    for (String member : memberGroup) {
      if (candidate.equals(member)) {
        return true;
      }
    }

    return false;
  }

  private static SettingField convertDescribeFieldToSettingField(DescribeFieldResult describedField) {
    SettingField field = new SettingField(firstFields, lastFields);

    field.apiName     = describedField.getName();
    field.displayName = describedField.getLabel();
    field.fieldType   = String.valueOf(describedField.getType());

    return field;
  }
}