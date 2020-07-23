# NEONTitrationPlotShinyApp
R Shiny app to retrieve swc_domainLabData from selected site/date range and plot values.

Select a site.

Select a start date and end date. The date inputs allow you to select dates in the format of "YYYY-MM-DD" but the
neonUtilities function loadByProduct that this script uses to retrieve data only allows for an input of "YYYY-MM". The code takes care of that issue but the user should note that because of this they can not plot titration data to sub-month resolution e.g. selecting "2020-07-14" to "2020-07-22" will return all data for the month of "2020-07".

Pressing the Retrieve Data button will make the call to the NEON data portal, download the data you requested, stack files, and store them in the global environment of your current R session. This means that data will not be stored between R sessions on your personal computer, you will have to make the request again to access it later if you do not save the generated plots. This would also have to be changed in order to host this app anywhere as global environment variables would be shared between users unless the server was restarted between uses.

Pressing the Plot Data button will generate four plots for your selected site and date combination: ALK values in mEq/L, ANC values in mEq/L, ALK values in mg/L, and ANC values in mg/L. Red lines present on the plots indicate thresholds as defined in the provided table above the plots. The table is from the NEON SWC protocol as a quick reference for what volumes and acid normalities should be used depending on your site's alkalinity and acid-neutralizing capacity.
