public without sharing class customSettingPanelController {

  /**
   * PRIVATE PROPERTIES
   */
  private String                    sObjectType;
  private settingFieldContainer[]   allFields;
  private settingFieldContainer[]   listFields;
  private settingFieldContainer[]   detailFields;
  private sObject[]                 allSettings;
  private List<Map<String, Object>> allSettingsMap;
  private Map<Object, String>       allSettingsIdMap;
  private String[]                  omittedFields;
  private String[]                  listFieldApiNames;
  private String[]                  detailFieldApiNames;
  private Map<String, Object>       activeClone;
  private Integer                   activeIndex;
  private Boolean                   isInEditMode;

  /**
   * PUBLIC PROPERTIES
   */
  public Map<String, Object> activeSetting { get; set; }

  /**
   * PRIVATE STATIC PROPERTIES
   */
  @TestVisible
  private static final String[] systemFields = new List<String> {'Id', 'CreatedDate', 'CreatedById', 'LastModifiedDate', 'LastModifiedById'};

  /**
   * CONSTRUCTOR
   */
	public customSettingPanelController() {
    this.sObjectType         = null;
    this.omittedFields       = null;
    this.listFieldApiNames   = null;
    this.detailFieldApiNames = null;
    this.isInEditMode        = false;
  }

  /**
   * PUBLIC SETTERS FOR COMPONENT PARAMETERS
   */
  public void setSObjectType(String value) {
    if (this.sObjectType == null) {
      this.sObjectType = value;
      this.initialize();
    }
  }

  public void setOmittedFieldList(String value) {
    if (this.omittedFields == null) {
      this.omittedFields = value.deleteWhiteSpace().split(',');
      this.omittedFields.add('IsDeleted');
      this.omittedFields.add('SystemModstamp');
      this.omittedFields.add('SetupOwnerId');
      this.initialize();
    }
  }

  public void setListFieldList(String value) {
    if (this.listFieldApiNames == null) {
      this.listFieldApiNames =
        value.equalsIgnoreCase('blank') ?
        new List<String>() :
        value.deleteWhiteSpace().split(',');
      this.initialize();
    }
  }

  public void setDetailFieldList(String value) {
    if (this.detailFieldApiNames == null) {
      this.detailFieldApiNames =
        value.equalsIgnoreCase('blank') ?
        new List<String>() :
        value.deleteWhiteSpace().split(',');
      this.initialize();
    }
  }

  /**
   * PUBLIC GETTERS FOR COMPONENT PARAMETERS
   */
  public String getSObjectType()      { return null; }
  public String getOmittedFieldList() { return null; }
  public String getListFieldList()    { return null; }
  public String getDetailFieldList()  { return null; }

  /**
   * PUBLIC GETTERS
   */
  public List<Map<String, Object>> getAllSettingsMap() {
    return this.allSettingsMap;
  }

  public Map<Object, String> getAllSettingsIdMap() {
    return this.allSettingsIdMap;
  }

  public settingFieldContainer[] getSettingFields() {
    return this.detailFields;
  }

  public settingFieldContainer[] getListFields() {
    return this.listFields;
  }

  public Boolean getIsActivelyEditing() {
    return this.activeSetting != null && this.isInEditMode;
  }

  public Boolean getIsActivelyViewing() {
    return this.activeSetting != null && !this.isInEditMode;
  }

  /**
   * INITIALIZATION FUNCTION
   */
  public void initialize() {
    if (!areNotNull(new List<object>{this.sObjectType, this.omittedFields, this.listFieldApiNames, this.detailFieldApiNames})) {
      return;
    }

    this.allFields = getSettingFields(this.sObjectType);
    this.allFields = filterSettingFields(this.allFields, this.omittedFields);

    this.detailFields = conformToOrder(this.allFields, this.detailFieldApiNames);
    this.listFields = conformToOrder(antiFilterSettingFields(this.allFields, this.listFieldApiNames), this.listFieldApiNames);

    this.allSettings = getAllSettings(this.sObjectType, this.allFields);
    this.allSettingsMap = convertSettingsToMap(this.allSettings, this.allFields);
    this.allSettingsIdMap = createReverseIdLookup(this.allSettings);
  }

  /**
   * PUBLIC SETTERS
   */

  public void setEditMode() {
    this.isInEditMode = true;
  }

  public void setViewMode() {
    this.isInEditMode = false;
    this.activeSetting = new Map<String, Object>(this.activeClone);
  }

  public void saveActiveSetting() {
    try {
      database.saveresult result;
      if(hasValidId(this.activeSetting)) {
        result = database.update(convertMapToSObject(this.sObjectType, this.activeSetting, this.allFields));

      } else {

        sObject item = convertMapToSObject(this.sObjectType, this.activeSetting, this.allFields);
        result = database.insert(item);

        this.activeSetting.put('id', item.id);
        this.allsettings.add(item);
        this.allSettingsMap.add(this.activeSetting);
        this.allSettingsIdMap.put(item.id, item.id);
      }
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(result.isSuccess())));

      this.setViewMode();
      this.setActiveSetting(null);
    }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception ' + e.getMessage()));
    }
  }

  public void deleteActiveSetting() {
    try {
      if (this.activeSetting.get('id') == null) {
        return;
      }

      database.deleteResult result = database.delete(convertMapToSObject(this.sObjectType, this.activeSetting, this.allFields));

      if (result.isSuccess()) {
        this.allSettings = removeSetting(this.allSettings, this.activeIndex);
        this.setViewMode();
        this.setActiveSetting(null);
        this.allSettingsMap = convertSettingsToMap(this.allSettings, this.allFields);
      }

      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, String.valueOf(result.isSuccess())));
    }
    catch (Exception e) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception ' + e.getMessage()));
    }
  }

  public void setNewActiveSetting() {
    this.activeSetting = convertSettingToMap(Schema.getGlobalDescribe().get(this.sObjectType).newSObject(), this.allFields);
    this.activeClone = convertSettingToMap(Schema.getGlobalDescribe().get(this.sObjectType).newSObject(), this.allFields);
    this.setEditMode();
  }

  public void setActiveSetting() {
    Id settingId = System.currentPageReference().getParameters().get('settingId');
    setActiveSetting(settingId);
  }

  private void setActiveSetting(Id settingId) {
    if (settingId == null) {
      this.activeSetting = null;
      this.activeClone = null;
    } else {
      this.activesetting = getSettingById(settingId, this.allSettingsMap);
      this.activeClone = new Map<String, Object>(this.activeSetting);
    }
  }

  private Map<String, Object> getSettingById(Id settingId, List<Map<String, Object>> allSettingMaps) {
    for (Integer i = 0; i < allSettingMaps.size(); i++) {
      if (allSettingMaps.get(i).get('id') == settingId) {
        this.activeIndex = i;
        return allSettingMaps.get(i);
      }
    }

    return null;
  }

  /**
   * PRIVATE STATIC FUNCTIONS
   */

  @TestVisible
  private static SObject convertMapToSObject(String sObjectType, Map<String, Object> itemMap, settingFieldContainer[] allFields) {

    sObject convertedItem =
      hasValidId(itemMap) ?
        Schema.getGlobalDescribe().get(sObjectType).newSObject((Id) itemMap.get('id')) :
        Schema.getGlobalDescribe().get(sObjectType).newSObject();

    for (settingFieldContainer field : allFields) {
      if (!field.isReadOnly) {
        if (field.type.equalsIgnoreCase('id')) {
          continue;
        } else if (field.type.equalsIgnoreCase('double')) {
          system.debug(field.apiName);
          convertedItem.put(field.apiName, Double.valueOf(itemMap.get(field.apiName)));
        } else {
          system.debug(field.apiName);
          convertedItem.put(field.apiName, itemMap.get(field.apiName));
        }
      }
    }

    return convertedItem;
  }

  @TestVisible
  private static SObject[] removeSetting(SObject[] objectList, Integer removeIndex) {
    SObject[] newList = new List<SObject>();

    if (objectList == null) {
      return newList;
    }

    for (Integer i = 0; i < objectList.size(); i++) {
      if (i != removeIndex) {
        newList.add(objectList[i]);
      }
    }

    return newList;
  }

  @TestVisible
  private static settingFieldContainer[] conformToOrder(settingFieldContainer[] toSort, String[] order) {
    settingFieldContainer[] sorted = new List<settingFieldContainer>();

    if (toSort == null) {
      return sorted;
    }

    for (String element : order) {
      for (settingFieldContainer field : toSort) {
        if (field.apiName.equalsIgnoreCase(element)) {
          sorted.add(field);
        }
      }
    }

    return sorted;
  }

  @TestVisible
  private static Boolean hasValidId(Map<String, Object> item) {
    return item != null && item.get('id') != null && item.get('id') != '';
  }

  @TestVisible
  private static Map<Object, String> createReverseIdLookup(List<SObject> items) {

    Map<Object, String> reverseIdLookup = new Map<Object, String>();

    if (items == null) {
      return reverseIdLookup;
    }

    for (SObject item : items) {
      reverseIdLookup.put(item.Id, item.Id);
    }
    return reverseIdLookup;
  }

  @TestVisible
  private static List<Map<String, Object>> convertSettingsToMap(sObject[] settings, SettingFieldContainer[] allFields) {
    List<Map<String, Object>> settingsMap = new List<Map<String, Object>>();

    if (settings == null) {
      return settingsMap;
    }

    for (sObject setting : settings) {
      settingsMap.add(convertSettingToMap(setting, allFields));
    }

    return settingsMap;
  }

  @TestVisible
  private static Map<String, Object> convertSettingToMap(sObject setting, SettingFieldContainer[] allFields) {
    Map<String, Object> settingMap = new Map<String, Object>();

    if (setting == null || allFields == null) {
      return settingMap;
    }

    for (SettingFieldContainer field : allFields) {
      settingMap.put(field.apiName, setting.get(field.apiName) != null ? setting.get(field.apiName) : '');
    }

    return settingMap;
  }

  @TestVisible
  private static List<sObject> getAllSettings(String sObjectType, settingFieldContainer[] settingFields) {
    string query = 'SELECT ';

    for (Integer i = 0; i < settingFields.size(); i++) {
      query += i + 1 < settingFields.size() ? settingFields.get(i).apiName + ', ' : settingFields.get(i).apiName + ' ';
    }

    query += 'FROM ' + sObjectType;

    return database.query(query);
  }

  @TestVisible
  private static settingFieldContainer[] filterSettingFields(settingFieldContainer[] settingFields, String[] omittedFields) {

    settingFieldContainer[] filteredFields = new List<SettingFieldContainer>();

    if (settingFields == null || omittedFields == null) {
      return filteredFields;
    }

    for (settingFieldContainer field : settingFields) {
      if (!isMemberOf(field.apiName, omittedFields)) {
        filteredFields.add(field);
      }
    }

    return filteredFields;
  }

  @TestVisible
  private static settingFieldContainer[] antiFilterSettingFields(settingFieldContainer[] settingFields, String[] desiredFields) {

    settingFieldContainer[] tableFields = new List<settingFieldContainer>();

    if (settingFields == null || desiredFields == null) {
      return tableFields;
    }

    for (Integer i = 0; i < settingFields.size(); i++) {
      if (isMemberOf(settingFields[i].apiName, desiredFields)) {
        tableFields.add(settingFields[i]);
      }
    }

    if (tableFields.size() < 1) {
      tableFields = cloneSettingFields(settingFields);
    }

    return tableFields;
  }

  @TestVisible
  private static settingFieldContainer[] cloneSettingFields(settingFieldContainer[] settingFields) {

    settingFieldContainer[] clonedFields = new List<settingFieldContainer>();

    if (settingFields == null) {
      return clonedFields;
    }

    for (Integer i = 0; i < settingFields.size(); i++) {
      if (settingFields[i] != null) {
        clonedFields.add(settingFields[i]);
      }
    }

    return clonedFields;
  }

  @TestVisible
  private static Boolean isMemberOf(String candidate, String[] memberGroup) {
    if (candidate == null || memberGroup == null) {
      return false;
    }

    for (String member : memberGroup) {
      if (candidate.equalsIgnoreCase(member)) {
        return true;
      }
    }

    return false;
  }

  @TestVisible
  private static settingFieldContainer[] getSettingFields(String sObjectType) {
    Map<String, sObjectField> setFields = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fields.getMap();
    return convertDescribeFieldsToSettingFields(setFields);
  }

  @TestVisible
  private static settingFieldContainer[] convertDescribeFieldsToSettingFields(Map<String, sObjectField> sObjectFieldMap) {
    SettingFieldContainer[] settingFields = new List<SettingFieldContainer>();

    if (sObjectFieldMap == null) {
      return settingFields;
    }

    for (String key : sObjectFieldMap.keySet()) {
      if (sObjectFieldMap.get(key) != null) {
        DescribeFieldResult result = sObjectFieldMap.get(key).getDescribe();
        settingFields.add(convertDescribeFieldToSettingField(result));
      }
    }

    return settingFields;
  }

  @TestVisible
  private static settingFieldContainer convertDescribeFieldToSettingField(DescribeFieldResult describedField) {
    SettingFieldContainer field = new SettingFieldContainer();

    if (describedField != null) {
      field.apiName     = describedField.getName().toLowerCase();
      field.displayName = describedField.getLabel();
      field.type        = String.valueOf(describedField.getType()).toLowerCase();
      field.isReadOnly  = isMemberOf(describedField.getName().toLowerCase(), systemFields);
    }

    return field;
  }

  @TestVisible
  private static Boolean areNotNull(List<Object> items) {
    if (items == null) {
      return false;
    }

    Boolean noNullValues = true;

    for (Object item : items) {
      noNullValues = noNullValues && item != null;
    }

    return noNullValues;
  }

  /**
   * INNER CLASSES
   */
  public class settingFieldContainer {
    public String apiName     { get; set; }
    public String displayName { get; set; }
    public String type        { get; set; }
    public Boolean isReadOnly { get; set; }
  }
}
