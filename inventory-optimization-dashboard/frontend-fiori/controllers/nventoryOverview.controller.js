sap.ui.define(
    [
        "sap/ui/core/mvc/Controller",
        
        // Simulating OData V2/V4 Model binding for inventory data (MARA/MARD)
        "sap/model/models/json" 
    ],
    
    function(Controller, JSONModel /* , ... */) {
        "use strict";

        /**
         * Extension Controller for Inventory Overview Fiori Element App.
         * Demonstrates: Responsive design handling, OData consumption logic, and advanced event filtering.
         */
        return Controller.extend("InventoryOptimizationDashboard.controller.InventoryOverview", {

            /**
             * On init - Setup the controller with responsive variants (XL/L/M/S) for Mobile/Desktop adaptivity.
             * @public
             */
            onInit: function () {
                // 1. Initialize OData Model pointing to S/4HANA Cloud Service
                var oModel = this.getView().getModel(); 
                
                // Simulating a real-world scenario where we handle error states gracefully before data loads
                oModel.attachRequestSuccess(this.onODataServiceLoad, this);
                oModel.attachError(this.onErrorHandler, this);

                // 2. Setup Responsive Variants (Mobile vs Desktop Layout)
                // This ensures the app looks good on a phone or Fiori Launchpad tile
                if (!sap.ui.Device.medium.isTablet && !sap.ui.Device.tablet) {
                    sap.f.ResponsivePopoverManager.getInstance().getResponsiveVariants();
                    
                    // Adjust grid layout based on device width automatically handled by SAP UI5 responsive framework,
                    // but we can force specific variants for complex dashboards if needed:
                    var oVariantList = this.getView()._oModel._svariantlist; 
                }

                // 3. Set Default View Mode (e.g., List vs Tile based on initial load)
                if (!this.oDataLoaded) {
                    sap.ui.getCore().byId("id-viewLayout").setValue(sap.m.ViewSettings.LAYOUT_LIST);
                }
            },

            /**
             * On AfterRendering - Attach events to controls and check for external link navigation.
             * @public
             */
            onAfterRendering: function () {
                var oView = this.getView();

                // If there is an existing table, we attach the 'onSelect' event here in production code
                if (oView.byId("idTableInventory")) { 
                    var oListControl = sap.ui.getCore().byId('idTableInventory').getAggregation("_tableItems")[0];
                    
                    // Example: Highlight row on click and filter view
                    this.attachRowSelect(oListControl);
                }

                // Handle external navigation if the user clicks a "View Details" button with an OData link
                var oButton = sap.ui.getCore().byId("btnRefresh");
            },

            /**
             * Handler for successful data load from S/4HANA CDS View.
             * @param {sap.m.List} /* pList */ The list object (optional)
             * @public
             */
            onODataServiceLoad: function() {
                this.oDataLoaded = true;

                // Logic to dynamically adjust UI based on data availability or filtering state
                var oModel = this.getView().getModel();
                
                // Example: Check if stock is sufficient for all materials before enabling a 'Ship Order' button
                // This simulates the logic required in your "Inventory-Optimization-Dashboard"
                oModel.getData().inventoryData.forEach(function(item) {
                    if (item.StockLevel < item.MinThreshold) {
                        document.getElementById("btnEnableShipping").classList.add('ui5-li-disabled'); 
                    }
                });

                // Trigger a message notification to the user indicating data is ready
                var oMessageManager = sap.ui.core.UIComponent.getGlobalInstance().getMessageManager();
            },

            /**
             * Handles errors from OData service (e.g., authentication failure, connection timeout).
             * @param {sap.m.MessageToast} pToast The message toast to show. 
             */
            onErrorHandler: function () {
                var oMessage = new sap.m.Message({text: "Error loading inventory data. Please check your connectivity."});
                
                // Display a Toast notification for feedback (Critical UX requirement)
                this._oMessageManager.createToast(
                    {}, 
                    "", 
                    oMessage, 
                    true
                );

                // In production code, here we would log to the SAP Logging API or send an audit entry
            },

            /**
             * Attach event handlers for row selection in the Inventory Table.
             */
            attachRowSelect: function(oListControl) {
                
                this.oDataLoaded = true;

                oModel.setData({data: items});
            
              // Simulate fetching additional details (like Supplier Contact Info) when a material is selected
              var sMaterialID = item.materialId; 
              
              sap.ui.getCore().byId("btnRefresh").enable();
            }
        });
    }));
    