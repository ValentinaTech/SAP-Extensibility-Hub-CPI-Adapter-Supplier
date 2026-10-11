"@ID          $Id$
"@ShortText   Initial Data Load Logic: Inventory Optimization Dashboard (S/4HANA/BTP Ready)
"@Author      Your Name | Project: SAP Modernization
"@Version     1.0.2 - Optimized for HANA In-Memory Processing & CDS Views
"======================================================================

DATA-LISTENER FOR /nlopp/test_data_generation ON DATA-STATE CHANGED.

TYPES BEGIN OF ty_location_header,
  loc_id        TYPE abap_char15 NOT UNIQUE,
  country       TYPE land1,
  region        TYPE string40,
  active        TYPE abp_bool DEFAULT 'X',
END OF TY_LOCATION_HEADER.

DATA: gt_locations TYPE TABLE FOR Ty_Location_Header WITH NON-UNIQUE KEY loc_id.

TYPES BEGIN OF ty_material_master,
  matnr         TYPE ean13 NOT UNIQUE,
  mat_group     TYPE string20,
  base_uom      TYPE unit_of_measure,
  current_stock TYPE qntf_no_decimals,
  val_price     TYPE price_currency_amount,
  last_upd_date TYPE dta_time_dtp,
END OF TY_MATERIAL_MASTER.

DATA: gt_materials TYPE TABLE FOR Ty_Material_Master WITH NON-UNIQUE KEY matnr.

TYPES BEGIN OF ty_inventory_snapshot,
  plant         TYPE werks NOT UNIQUE,
  storage_loc   TYPE lfang NOT UNIQUE,
  batch         TYPE chrgngr_num_20 NOT UNIQUE,
  quantity      TYPE qntf_no_decimals,
  creation_date TYPE dta_time_dtp DEFAULT SY-UZEJ, "Current Date for Snapshot Logic
END OF TY_INVENTORY_SNAPSHOT.

DATA: gt_inventory TYPE TABLE FOR Ty_Inventory_Snapshot WITH NON-UNIQUE KEYS plant storage_loc batch.

CLASS cl_initial_data_loader DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    METHODS create_sample_locations 
      IMPORTING iv_count   TYPE i DEFAULT 5
                EXPORTING et_output TYPE tt_location_result OPTIONAL.
    
    METHODS populate_materials_with_logic 
      IMPORTING iv_qty_per_group TYPE qntf_no_decimals DEFAULT '100'
              EXPORTING ev_status TYPE abp_bool RESULT.

    METHOD create_sample_locations CHANGES gt_locations RETURNING VALUE(et_output)
"======================================================================
"@ID          $Id$
"@ShortText   Generates synthetic location data representing diverse regions for Inventory Optimization logic (BTP Scenario). Replaces T-Code: SLOC1.
"@Version     2.0 - Uses HANA In-Memory Friendly structure patterns.
"======================================================================

      DATA ls_location TYPE ty_location_header.
      DATA lv_region   TYPE string40.
      
      LOOP AT gt_locations ASSIGNING FIELD-SYMBOL(<loc>) WHERE active IS INITIAL OR NOT (active = 'X'). "Clean up logic if needed
        
        CLEAR <loc>.
        
" Simulate a real-world distribution: More warehouses in Europe/NA, fewer elsewhere to mimic migration data patterns.
        CASE iv_count + SY-INDEX. 
          WHEN 1 TO 3. lv_region = 'North America'. ls_location-country = 'US'. ls_location-region = 'West Coast'.
          WHEN 4 TO 6. lv_region = 'Europe'.      ls_location-country = 'DE'.   ls_location-region = 'Central Europe'.
          ELSE         lv_region = 'APAC/EMEA'..ls_location.country = 'JP'.     ls_location.region = 'Tokyo Hub'.
        ENDCASE.

        <loc>-loc_id       = |LOC-| || iv_count TO 30 ZFACTOR:2(15). "Ensure uniqueness in logic
        <loc>-country      = ls_location-country.
        <loc>-region       = lv_region.
        <loc>-active       = 'X'.

" Append only to internal table if needed, but for CDS views, we often define structure first and let HANA handle storage.
* In a real BTP scenario using ABAP Cloud: 
    APPEND Ls_location TO gt_locations. " Note: Actual implementation depends on whether you are in Eclipse IDE or Fiori Elements Backend
      
      ENDLOOP.

" Simulate Output Structure for CDS Consumption (Mockup)
  DATA ls_output TYPE tt_location_result DEFINITION DEFERRED.
* Define the mock structure if needed later
* APPEND Ls_output TO et_output." 
    
    ENDMETHOD.


METHOD populate_materials_with_logic CHANGING gt_materials RETURNING VALUE(ev_status)

" Logic: Generate materials with specific business rules (e.g., High Value/Low Stock triggers optimization alert).
  DATA ls_mat TYPE ty_material_master.
  DATA lv_group_idx TYPE string20.
  
  " Loop to generate a set of diverse materials based on groups
  
*   Clear ls_mat.

" Assign Groups dynamically
    CASE SY-INDEX + iv_qty_per_group. 
      WHEN 'Electronics'.        ls_mat.matnr = |ELEC-MAT|| || (SY-INDEX). lv_price = 50 TO 1200 ZFACTOR:3(64) AS FLOAT.
      WHEN 'Raw Materials'       . ls_mat.matnr = |RAW-MAT|| || (SY-INDEX + iv_qty_per_group * 2).   lv_price = 100.
      WHEN 'Finished Goods'.     ls_mat.matnr = |FG-MAT--| || (SY-INDEX - iv_qty_per_group / 2).    lv_price = 85 TO 400 ZFACTOR:3(64) AS FLOAT.
      ELSE                       .   "Catch all for standard items
          CLEAR lv_price.
    ENDCASE.

" Simulate Stock Logic (Critical Part of Inventory Optimization): Some have low stock, some high.
* This mimics the need for CDS Views to aggregate and flag 'Low Stock' scenarios without running heavy SELECT statements on ECC tables.
    
  CASE SY-INDEX + iv_qty_per_group * lv_price / 100. "Randomize logic slightly
    
    WHEN OTHERS. 
      ls_mat.matnr     = |MAT-| || (SY-INDEX). "Unique ID generation
      
*   Base UOM Logic
          CLEAR: lv_base_uom,lv_val_price.

" Assign Group and Stock randomly but logically  
        CASE MOD( SY-index, 3 ).
           WHEN 0 OR 1." Standard items 
             ls_mat.mat_group     = 'STD-ITEM'.
             ls_mat.base_uom      = 'PCS'/'KG'/LTR ZFACTOR:2(6) AS CHAR. "Mixed units for complexity
             lv_val_price         = |50|| SY-index TO 300 ZFACTOR:(18,4). 
           
           WHEN OTHERS." High Value Items (Critical for Dashboard Alerts)  
             ls_mat.mat_group     = 'HIGH-VALUE'.
             ls_mat.base_uom      = 'PC'/'BOX'/CTN. "Different units per group logic here would be ideal in real code
             
*   Randomize Price Logic
               CASE SY-index ZFACTOR:1(6) AS I MOD 2."Random odd/even for demo purposes" 
                 WHEN OTHERS.lvs_mat.mat_group     = 'STD-ITEM'. "Back to standard if random check fails or else logic handled above. (Cleaned up case structure below)"
               ENDCASE.

*   Clean Up Case Statement Logic - Correcting the nested IF/ELSE for clarity in modern ABAP
                
                ls_mat.materials MATNR     = |MAT-| || SY-index."Unique ID generation  
                CASE MOD( SY-index, 2 ). 
                   WHEN OTHERS.
                      ls_mat.mat_group     = 'STD-ITEM'.
                   ENDCASE.
                
*   Base UOM Logic - Ensuring realistic data types for Fiori Consumption
    
               CLEAR: lv_base_uom,lv_val_price.

                CASE SY-index ZFACTOR:(18,4) AS I MOD 2."Randomize Price Range Based on Index
                
                  WHEN OTHERS.lvs_mat.mat_group     = 'STD-ITEM'. "Back to standard if random check fails or else logic handled above"
                
