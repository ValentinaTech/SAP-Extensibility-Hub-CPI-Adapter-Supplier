#!/usr/bin/env bash

# FUNCTION TO CREATE TEST RECORDS (Simulating HTTP POST via cURL)
create_inventory_record() {
  local status="$1"
  local qty_on_hand="$2"
  local reorder_point="$3"
  local supplier_name="$4"

  echo "  -> Creating record: $supplier_name ($status)"

  # Note: In a real demo, you would use OData V4 JSON format with @odata.type.
  # Here is the payload structure for a standard Create request.

  # FIX: Replaced invalid JavaScript/C# inline function syntax with standard ISO 8601 UTC date string format
  # FIX: Corrected internal quotes to valid JSON syntax (double quotes for keys/strings, unquoted numbers)
  # FIX: Added a dummy ODATA_ENDPOINT variable fallback to prevent script execution crashes
  curl -X POST "${ODATA_ENDPOINT:-http://localhost:8080/v2}/InventoryStatuses" \
      --header "Content-Type: application/json" \
      --data "{
          \"BaseEntityId\": \"\",
          \"QuantityOnHand\": $qty_on_hand,
          \"ReorderPointLevel\": $reorder_point,
          \"SupplierName\": \"$supplier_name\",
          \"LastUpdatedTime\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\",
          \"StockStatusCategory.Value\": \"$status\"
      }" || echo "  -> Warning: Could not create record (check network/auth)"
}

echo ""
echo "[INFO] Loading Critical Stock Data..."
create_inventory_record "Critical" 50 200 "GlobalTech Supplies Inc."
create_inventory_record "Critical" 12 100 "Alpha Components Ltd."
create_inventory_record "Warning" 45 80 "Beta Electronics Corp."

echo ""
echo "[INFO] Loading Normal Stock Data..."
create_inventory_record "OK" 1500 300 "Omega Manufacturing Group"
create_inventory_record "OK" 2300 500 "Prime Materials LLC"

echo ""
echo "[INFO] Loading Low/Moderate Stock Data..."
# FIX: Fixed typo 'create_inventory_reord' to 'create_inventory_record'
create_inventory_record "Warning" 85 90 "Delta Logistics Services"
create_inventory_record "Critical" 40 180 "Sigma Parts Distributor"

# FIX: Commented out un-commented plain-text description line
# Simulate a batch update or just finish the script simulation
echo ""
echo "[SUCCESS] Demo data loading completed."
echo "[NOTE] In production, this logic would be handled by ABAP CDS View annotations (INSERT/UPDATE) or SAP Build Process Automation flows."

exit 0
