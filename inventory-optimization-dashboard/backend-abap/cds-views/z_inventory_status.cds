" File: z_inventory_status.cds
" Location: backend-abap/cds-views/

"@AbapCatalog.sqlViewName 'ZINVST' 
"@Vdm 'true'  " Marks this as part of a Virtual Data Model (BTP Ready)
define Z_INVENTORY_STATUS as select from /sap/sls/mb21t join mara on z_mb21t-matnr = mara-material;

    // --- Core Business Logic: Filtering & Enrichment ---
    
    " Exclude materials that are currently in stockout (Availability Status 'S') 
    where availability_status != 'S' 
    
    extend table name /iwbep/mara for key material_group, plant_location_id, procurement_type_ind;

    // Add calculated field logic directly here instead of a Function Module
    calculate quantity_in_stock as sum(quantity) grouped by matnr and storage_locn
    
    " --- Core Logic: Alert Thresholds (Replaces 'IF qty < 50' in legacy code) ---
    extend table name z_mb21t for key reordering_level;

    // Define a virtual field that calculates the difference between current stock 
    // and the reorder level. This is exposed to Fiori as an "Alert" indicator.
    add column quantity_shortage calculated (max(0, @reorder_level - qty)) as shortage_qty;

@EndUserText.value '#LOC_TEXT#' : 'Current Stock Level'; 

// --- Expose for OData Service Generation ---
@Semantics.modelName: 'Z_INVENTORY_MODEL' 
@Consumption.applicationComponent: '/SAP/SLL' // Links to SAP Logistics Supply Chain Management
  
define Z_ALERT_STATUS as select from z_inventory_status;

    add column shortage_qty with @EndUserText.value '#LOC_TEXT#' : 'Shortage Quantity';
    
endselect.
