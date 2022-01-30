# Power BI Time-Series Custom Visual

In addition to being a fantastic data transformation and modeling tool, Power BI gives the analyst the ability to organize data graphically in a very appealing way.

Assuming you want to display a time-series including also the prediction interval for the forecasting part, Power BI by default allows you to do so thanks to the _Line chart_ visual, but it is the tool itself that determines the forecasting according to the type of series through two different algorithms: a [seasonal (ETS AAA)](https://powerbi.microsoft.com/es-es/blog/describing-the-forecasting-models-in-power-view/#ETSAAA) and a [non-seasonal (ETS AAN)](https://powerbi.microsoft.com/es-es/blog/describing-the-forecasting-models-in-power-view/#ETSAAN) algorithm.

Take the following time-series as an example:

![time-series plot](/img/01.png)

One can guess by eye that an annual seasonality is present. If we add a forecast in Power BI thanks to the _Analytics_ tab and let the tool automatically determine the seasonality, the results are not the best:

![time-series auto forecasting](/img/02.png)

If, on the other hand, we manually assign the number of time-series points associated with seasonality, the results improve dramatically:

![time-series manual forecasting](/img/03.png)

As you can see, the forecasting follows the trend of the peaks quite well, although it is slightly overestimated. It basically failed to capture the fact that the trend line is slightly lower than estimated.

For this reason, the analyst may prefer not to use the default forecasting algorithms in Power BI, but to use a more accurate model developed by a data scientist that returns both forecasting values and those associated with the prediction interval band.

Now suppose to perform a batch scoring through the aforesaid model and therefore to have a CSV file as output with all the necessary information to realize the plot. It __doesn't exist a visual__ in Power BI that allows to draw actual values, predicted values and also the upper and the lower bound of the predictive interval taken from an existing table.

This Power BI custom visual that I am sharing with you was created to fill the gap just described. Thanks to it, it is possible to plot the shared time-series forecasting data in this repository (_data/ts_forecast.csv_) as well:

![time-series forecasting using the custom visual](/img/04.png)

Unlike the previous forecasting provided by Power BI, it is evident that the values predicted through the external model are slightly underestimated, but more correctly follow the trend line of the actual values.

## Getting Interactivity Using a Custom R Visual

The main goal I set for myself was not only to give the analyst the ability to plot a time-series forecasting plot given all its component values, but also to create an __interactive__ custom visual.

Since I'm a big fan of the R language and I'm aware that Power BI allows you to create custom visuals using R, I got to think about what R packages might be able to generate a time-series forecasting plot. Anyone who knows a little about R and the [Tidyverse framework](https://www.tidyverse.org/) will surely know about the [Tidymodels framework](https://www.tidymodels.org/) and, specifically for time-series, Matt Dancho's fantastic [_timetk_](https://github.com/business-science/timetk) and [_modeltime_](https://github.com/business-science/modeltime) packages. In particular, the _modeltime_ package contains the _plot_modeltime_forecast()_ function that allows you to plot a time-series with the predicted values from one or more models. Moreover, the output of this function can be an interactive plot thanks to the use of [_plotly.R_](https://github.com/plotly/plotly.R). It is exactly what I was looking for!

The only problem I encountered was the fact that Power BI service has an outdated R engine (_Microsoft R Open 3.4.4_) and the available R packages do not provide neither _timetk_ nor _modeltime_. Because of this, to be able to publish a report that used this custom visual on the service, I had to extract the _plot_modeltime_forecast()_ dependencies from these packages and had to make very minor changes to integrate them with each other. The files extracted from the various packages are as follows:

* [modeltime/modeltime-forecast-plot.R](https://github.com/business-science/modeltime/blob/master/R/modeltime-forecast-plot.R)
* [timetk/plot-time_series.R](https://github.com/business-science/timetk/blob/master/R/plot-time_series.R)
* [timetk/tidyquant-theme-compat.R](https://github.com/business-science/timetk/blob/master/R/tidyquant-theme-compat.R)

After making the above changes, the result was as follows:

![animated gif of the interactive custom visual](/img/interactive_demo.gif)

But let's see now how to install the time-series custom visual.

## Installing the Time-Series Custom Visual

In order to install a Power BI custom visual, you must click on the ellipses in the Visualizations pane, click on the menu item _"Import a visual from file"_ and then select the custom visual to import:

![installing the custom visual in Power BI](/img/05.png)

The custom visual to import is the _.pbiviz_ file located in the "_dist_" folder of the R HTML visual folder structure once you clone the repository (see references for more details):

![custom visual file from source](/img/06.png)

Otherwise you can download the latest release of the visual directly from the [Releases page](https://github.com/lucazav/power-bi-time-series-custom-visual/releases) on GitHub:

![custom visual file from releases](/img/06_a.png)

After loading the _.pbiviz_ file, a new icon identifying the time-series custom visual will be displayed in the Visualizations pane, as shown in the figure above.

Right after clicking on the new icon, you will be asked to enable the custom visual. Once you click "_Enable_", you can interact with the data fields of the custom visual:

![time-series custom visual data fields](/img/07.png)

The requested data are the following:

* __Date__: (mandatory) variable containing date values
* __Value__: (mandatory) actual values of the time-series
* __Value Type__: (mandatory) variable containing labels about the type of value to which it refers ("actual" or "prediction") 
* __Confidence Low__: (optional) value of the low bound of the predictive interval
* __Confidence High__: (optional) value of the high bound of the predictive interval
* __Model ID__: (optional) Numerical ID of the model that scored the predicted values it refers in the dataset. If the predicted values present in the dataset are generated by a single model, this field may be omitted
* __Model Description__: (optional) Description of the model that scored the predicted values it refers in the dataset. If the predicted values present in the dataset are generated by a single model, this field may be omitted 

Once you have entered the first data in the above fields, you can explore the _Format_ tab of the custom visual. In particular, there is the "_Plot Settings_" section that allows you to interact with the elements of the displayed plot:

![time-series custom visual format options](/img/08.png)

Now let's see what is the expected format of the input dataset that feeds the data fields.

## Expected Format of the Input Dataset

Suppose you have a time-series running from time T<sub>0</sub> to time T<sub>n</sub>, for a total of _n_ observations. We will then have _n_ current values in the series. Suppose now you want to do the forecasting for the values associated with the time range from T<sub>i</sub> to T<sub>n</sub>. This means that you want to predict the last _n-i+1_ values of the series. Since the dataset in input has a single variable containing the values (_Value_), distinguished in their function by the variable _Value Type_, the variable _Value_ will contain both all the actual values (_n_ values for which _Value Type = "actual"_), and the prediction values (the _n-i+1_ values for which _Value Type = "prediction"_). This means that in the _Date_ column we will find the temporal range from T<sub>i</sub> to T<sub>n</sub> repeated twice, once for the actual values and once for the predicted values:

![expected dataset schema for 1 model forecasting](/img/09.png)

If you want to plot the forecasting obtained from 2 models, in addition of adding other _n-i+1_ rows to the dataset, you have to introduce two new variables: _Model ID_ and _Model Description_. Through these two variables it is possible to associate the predictions contained in the _Value_ field to a specific model from which they have been obtained. All becomes clearer looking at the following figure: 

![expected dataset schema for 2 models forecasting](/img/10.png)

Let's see now how to put into practice everything seen.

## Showing everything in a demo

You can find the ts_forecasting.pbix file in the "demo" folder of the repository. In it I have highlighted the differences in applying forecasting to a time-series provided in a CSV file using the standard Power BI features and using the time-series custom visual. The CSV file is located in the "data" folder of the repository and it contains data extracted from the [Kaggle's Retail Data Analytics competition](https://www.kaggle.com/manjeetsingh/retaildataset?select=stores+data-set.csv) made available under the _CC0: Public Domain_ license.

You can also test the time-series custom visual in a live demo published via Power BI's "Publish to web" option. Here is [the link](https://app.powerbi.com/view?r=eyJrIjoiNTZlZTNkZTctMzZiNi00NTUzLTlkMzgtMTZkZTRlNDc1YmU2IiwidCI6IjA4MjRlOGM5LWQzNWEtNDAwMC1hYTYxLTQ3YjM5MDdjMDEyZSIsImMiOjF9&pageName=ReportSection) to the live demo.

## References

Below is a list of links to key references:

* [Describing the forecasting models in Power View](https://powerbi.microsoft.com/es-es/blog/describing-the-forecasting-models-in-power-view/)
* [Timetk, time series analysis in the tidyverse](https://business-science.github.io/timetk/)
* [Modeltime, tidy time series forecasting with tidymodels](https://business-science.github.io/modeltime/)
* [Create visuals by using R packages in the Power BI service](https://docs.microsoft.com/en-us/power-bi/connect-data/service-r-packages-support)

If you want to learn how to create a Power BI R Custom Visual from scratch, as well as many other topics on how to better integrate Python and R into Power BI, you can find detailed guides in my book "[_Extending Power BI with Python and R_](https://www.amazon.com/Extending-Power-Python-transform-analytical/dp/1801078203/)":

<a href="https://www.amazon.com/Extending-Power-Python-transform-analytical/dp/1801078203/" rel="Extending Power BI with Python and R">![Extending Power BI with Python and R book](/img/11.png)</a>


