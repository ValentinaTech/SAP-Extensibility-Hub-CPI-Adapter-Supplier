@AbapCatalog.sqlViewName: 'ZINVST'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Current Stock Level and Inventory Status'
@OData.publish: true // Directly exposes this view as an OData V2 Service for Fiori Elements

define view Z_INVENTORY_STATUS 
  as select from mara
    inner join nsedm_v_mseg as mseg on mseg.matnr = mara.matnr // Replaced custom/legacy tables with S/4HANA standard equivalents
{
  key mara.matnr          as MaterialNumber,
  key mseg.werks          as PlantLocationId,
  key mseg.lgort          as StorageLocation,
      mara.matkl          as MaterialGroup,
      mara.bstme          as ProcurementTypeInd,
      
      // Core Business Logic: Aggregation replacing Function Modules
      @Semantics.quantity.unitOfMeasure: 'MaterialUnit'
      sum(mseg.menge)     as QuantityInStock,
      mara.meins          as MaterialUnit,
      
      // S/4HANA Cloud Reorder Logic: Standard CDS expression replacing procedural IF loops
      case 
        when sum(mseg.menge) < 50 then 50 - sum(mseg.menge)
        else 0
      end                 as ShortageQty,
      
      // Critical for Fiori Elements: Criticality annotation drives the UI alert colors dynamically
      case 
        when sum(mseg.menge) < 50 then 1 // 1 = Red Alert (Critical)
        else 3                          // 3 = Green (Positive)
      end                 as StockCriticality
}
// Core Business Logic: Filtering & Aggregation Rules
where mara.lvorm = '' // Exclude flagged for deletion instead of custom availability flags
group by 
  mara.matnr,
  mseg.werks,
  mseg.lgort,
  mara.matkl,
  mara.bstme,
  mara.meins
