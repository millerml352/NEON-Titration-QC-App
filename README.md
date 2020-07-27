# NEON Plot Titration Data App

Matthew Miller

D17 Pacific Southwest

This app is intended to provide a quick way of visualizing domain level titration data.

Running the app locally
-----------------------
1. Select a site.
2. Select a start and end date range to view.
3. Press "Retrieve Data" to initiate the download using the neonUtilities loadByProduct function
4. Wait for the data to finish downloading (currently must view Rstudio console to confirm)
5. Press "Plot Data" to create plots below

Pressing the Plot Data button will generate four plots for your selected site and date combination: ALK values in mEq/L, ANC values in mEq/L, ALK values in mg/L, and ANC values in mg/L. Red lines present on the plots indicate thresholds as defined in the provided table above the plots. The table is from the NEON SWC protocol as a quick reference for what volumes and acid normalities should be used depending on your site's alkalinity and acid-neutralizing capacity.

To Address a/o 20200727
-----------
1. Can't currently be hosted

    1a. Data frame is superassigned to global env, would be shared between users if not restarted between each "session"
    
    1b. Might need some kind of R markdown index file OR split into ui.R server.R and global.R? Attempted to test host via shinyapps.io and couldn't run. Hard to tell, quite sure Cody or Jim could answer that quickly though
  
2. DRY out the plot code - working on looping plot function in dev repo rather than four semi-hard coded plot expressions. Should speed up processing time

3. Button or capability to export plots (right-click save does not work atm easy fix); probably would work with either plotly or ggplot2

4. Deal with skipping rows due to NAs in non-vital columns e.g. POSE fall 2019 skipping observations and disconnected plot due to NAs in initialSamplePh column

5. Progress indicator of some sort for "Retrieve Data" button
