# Data Models and Schema Changes

## New Data Models

### WidgetConfiguration
**Purpose:** Store widget-specific configuration and display preferences
**Integration:** Extends existing UserDefaults system for widget settings

**Key Attributes:**
- widgetType: String - Type of widget (balance, transactions, goals)
- displayFormat: String - How data should be displayed
- refreshInterval: Int - How often widget should update
- selectedCategories: [String] - Categories to display in widget

**Relationships:**
- **With Existing:** Links to existing UserDefaults preferences
- **With New:** Used by WidgetKit for configuration


### AnalyticsData
**Purpose:** Store calculated analytics and insights data
**Integration:** Extends existing Core Data models for analytics calculations

**Key Attributes:**
- dataType: String - Type of analytics data (spending trends, goal progress)
- timePeriod: String - Time period for the data (weekly, monthly, yearly)
- calculatedData: Data - JSON data containing calculated insights
- lastUpdated: Date - When data was last calculated

**Relationships:**
- **With Existing:** Links to existing Transaction and Goal models
- **With New:** Used by advanced analytics dashboard

## Schema Integration Strategy
**Database Changes Required:**
- **New Tables:** WidgetConfiguration, AnalyticsData
- **Modified Tables:** None - all new tables are additive
- **New Indexes:** Index on AnalyticsData.timePeriod for performance
- **Migration Strategy:** Use Core Data lightweight migration for new entities

**Backward Compatibility:**
- All existing data remains unchanged
- New tables are optional and don't affect existing functionality
- Existing queries and relationships remain intact
