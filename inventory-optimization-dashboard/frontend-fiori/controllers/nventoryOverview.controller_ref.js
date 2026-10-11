sap.ui.define(
['sap/ui/core/mvc/Controller'],
/**
 * @namespace com.yourcompany.inventory.controller
 */
function(Controller) {
    "use strict";

    return Controller.extend("com.yourcompany.inventory.InventoryOverview", {
        onInit: function() {
            // Initialize the shell navigation (if needed for custom extensions)
            if (!this.oShellView) {
                this.createShell();
            }
            
            // Optionally refresh data manually to ensure it loads immediately without waiting for route change events if no routes are defined yet.
        },

        
        onBeforeRendering: function() {
            // If using Fiori Elements with a custom header or specific layout logic, 
            // we can call methods here before the view renders.
        }


    });
});
