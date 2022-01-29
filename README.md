# Power BI Time-Series Custom Visual

In addition to being a fantastic data transformation and modeling tool, Power BI gives the analyst the ability to organize data graphically in a very appealing way.

Assuming you want to display a time-series including also the prediction interval for the forecasting part, Power BI by default allows you to do so, but it is the tool itself that determines the forecasting according to the type of series through two different algorithms: a [seasonal (ETS AAA)](https://powerbi.microsoft.com/es-es/blog/describing-the-forecasting-models-in-power-view/#ETSAAA) and a [non-seasonal (ETS AAN)](https://powerbi.microsoft.com/es-es/blog/describing-the-forecasting-models-in-power-view/#ETSAAN) algorithm.

Take the following time-series as an example:

![img01](/img/01.png)

One can guess by eye that an annual seasonality is present. If we add a forecast in Power BI and let the tool automatically determine the seasonality, the results are not the best:

![img01](/img/02.png)

If, on the other hand, we manually assign the number of time-series points associated with seasonality, the results improve dramatically:

![img01](/img/03.png)

As you can see, the forecasting follows the trend of the peaks quite well, although it is slightly overestimated. It basically failed to capture the fact that the trend line is slightly lower than estimated.

For this reason, the analyst may prefer not to use the default forecasting algorithms in Power BI, but to use a more accurate model developed by a data scientist that returns both forecasting values and those associated with the prediction interval band.

Now suppose to perform a batch scoring through the aforesaid model and therefore to have a CSV file as output with all the necessary information to realize the plot. It __doesn't exist a visual__ in Power BI that allows to draw actual values, predicted values and also the upper and the lower bound of the predictive interval taken from an existing table.

This Power BI custom visual that I am sharing with you was created to fill the gap just described. Thanks to it, it is possible to plot the shared time-series forecasting data in this repository (_ts_forecast.csv_) as well:

![img01](/img/04.png)

Unlike the previous forecasting provided by Power BI, it is evident that the values predicted through the external model are slightly underestimated, but more correctly follow the trend line of the actual values.

## Getting Interactivity Using a Custom R Visual

The main goal I set for myself was not only to give the analyst the ability to plot a time-series forecasting plot given all its component values, but also to create an __interactive__ custom visual.

Since I'm a big fan of the R language and aware that Power BI allows you to create custom visuals using R, I got to thinking about what R packages might be able to generate a time-series forecasting plot. Anyone who knows a little about R and the [Tidyverse framework](https://www.tidyverse.org/) will surely know about the [Tidymodels framework](https://www.tidymodels.org/) and, specifically for time-series, Matt Dancho's fantastic [_timetk_](https://github.com/business-science/timetk) and [_modeltime_](https://github.com/business-science/modeltime) packages. In particular, the _modeltime_ package contains the _plot_modeltime_forecast()_ function that allows you to plot a time-series with the predicted values from one or more models. Moreover, the output of this function can be an interactive plot thanks to the use of [_plotly.R_](https://github.com/plotly/plotly.R). It is exactly what I was looking for!

The only problem I encountered was the fact that Power BI service has an outdated R engine (_Microsoft R Open 3.4.4_) and the available R packages do not provide neither _timetk_ nor _modeltime_. Because of this, to be able to publish a report that used this custom visual on the service, I had to extract the _plot_modeltime_forecast()_ dependencies from these packages and had to make very minor changes to integrate them with each other. The files extracted from the various packages are as follows:

* [modeltime/modeltime-forecast-plot.R](https://github.com/business-science/modeltime/blob/master/R/modeltime-forecast-plot.R)
* [timetk/plot-time_series.R](https://github.com/business-science/timetk/blob/master/R/plot-time_series.R)
* [timetk/tidyquant-theme-compat.R](https://github.com/business-science/timetk/blob/master/R/tidyquant-theme-compat.R)

After making the above changes, the result was as follows:

![demo of interactive custom visual](/img/interactive_demo.gif)

But let's see now how to install the time-series custom visual.

## Installing the Time-Series Custom Visual

In order to install a Power BI custom visual, you must click on the ellipses in the Visualizations pane, click on the menu item _"Import a visual from file"_ and then select the custom visual to import:

![img01](/img/05.png)

The custom visual to import is the _.pbiviz_ file located in the "_dist_" folder of the R HTML visual folder structure (see references for more details):

![img01](/img/06.png)

After loading the _.pbiviz_ file, a new icon identifying the time-series custom visual will be displayed in the Visualizations pane, as shown in the figure above.

Right after clicking on the new icon, you will be asked to enable the custom visual. Once you click "_Enable_", you can interact with the data fields of the custom visual:

![img01](/img/07.png)


