# NEON Plot Titration Data App
##Matthew Miller
##D17 Pacific Southwest

This app is intended to provide a quick way of visualizing domain level titration data.

Running the app locally
-----------------------
1. Select a site.
2. Select a start and end date range to view.
3. Press "Retrieve Data" to initiate the download using the neonUtilities loadByProduct function
4. Wait for the data to finish downloading (currently must view Rstudio console to confirm)
5. Press "Plot Data" to create plots below

Pressing the Plot Data button will generate four plots for your selected site and date combination: ALK values in mEq/L, ANC values in mEq/L, ALK values in mg/L, and ANC values in mg/L. Red lines present on the plots indicate thresholds as defined in the provided table above the plots. The table is from the NEON SWC protocol as a quick reference for what volumes and acid normalities should be used depending on your site's alkalinity and acid-neutralizing capacity.
