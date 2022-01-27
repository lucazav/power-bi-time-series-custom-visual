source('./r_files/flatten_HTML.r')

############### Library Declarations ###############
libraryRequireInstall("ggplot2");
libraryRequireInstall("plotly");
libraryRequireInstall("dplyr");
####################################################

################### Actual code ####################

source('./r_files/plot-time_series.R')
source('./r_files/modeltime-forecast-plot.R')
source('./r_files/tidyquant-theme-compat.R')

#-- Default values (mandatory) ----
conf_interval_show <- TRUE
conf_interval_alpha <- 0.2
smooth <- FALSE
legend_show <- TRUE
legend_max_width <- 40
title <- "Forecast Plot"
x_lab <- ""
y_lab <- ""
plotly_slider <- FALSE


conf_interval_fill <- "lightblue"
#-----------------------------------

if(exists("settings_variable_params_conf_interval_show_bool")){
    conf_interval_show <- as.logical(settings_variable_params_conf_interval_show_bool)
}

if(exists("settings_variable_params_conf_interval_alpha")){
    conf_interval_alpha <- as.numeric(settings_variable_params_conf_interval_alpha)
}

if(exists("settings_variable_params_smooth_bool")){
    smooth <- as.logical(settings_variable_params_smooth_bool)
}

if(exists("settings_variable_params_legend_show_bool")){
    legend_show <- as.logical(settings_variable_params_legend_show_bool)
}

if(exists("settings_variable_params_legend_max_width")){
    legend_max_width <- as.numeric(settings_variable_params_legend_max_width)
}

if(exists("settings_variable_params_title_str")){
    title <- as.character(settings_variable_params_title_str)
}

if(exists("settings_variable_params_x_lab_str")){
    x_lab <- as.character(settings_variable_params_x_lab_str)
}

if(exists("settings_variable_params_y_lab_str")){
    y_lab <- as.character(settings_variable_params_y_lab_str)
}

if(exists("settings_variable_params_plotly_slider_bool")){
    plotly_slider <- as.logical(settings_variable_params_plotly_slider_bool)
}

if(exists("settings_variable_params_conf_interval_fill_picker")){
    conf_interval_fill <- as.character(settings_variable_params_conf_interval_fill_picker)
}


is_valid_plot <- FALSE

if (exists('index') & exists('value')) {
    
    index_var_name <- names(index)
    value_var_name <- names(value)
    
    dataset <- data.frame(
        .index = as.POSIXct(index[[index_var_name]]),
        .value = value[[value_var_name]]
    )
    
    
    if (exists('value_type')) {
        
        value_type_var_name   <- names(value_type)
        
        dataset <- cbind(dataset,
                         .key = value_type[[value_type_var_name]])
        
    } else {
        value_type_var_name   <- NULL
    }
    
    
    if (exists('conf_lo') & exists('conf_hi')) {
        
        conf_lo_var_name   <- names(conf_lo)
        conf_hi_var_name   <- names(conf_hi)
        
        dataset <- cbind(dataset,
                         .conf_lo = conf_lo[[conf_lo_var_name]],
                         .conf_hi = conf_hi[[conf_hi_var_name]])
        
    } else {
        conf_interval_show <- FALSE
        conf_lo_var_name   <- NULL
        conf_hi_var_name   <- NULL
    }
    
    if (exists('model_id') & exists('model_descr')) {
        
        model_id_var_name   <- names(model_id)
        model_descr_var_name   <- names(model_descr)
        
        dataset <- cbind(dataset,
                         .model_id = model_id[[model_id_var_name]],
                         .model_descr = model_descr[[model_descr_var_name]])
        
    } else {
        model_id_var_name   <- NULL
        model_descr_var_name   <- NULL
    }
    
    is_valid_plot <- TRUE
}


if (is_valid_plot) {
    p <- dataset %>%
        mutate(
            .key = if(is.null(value_type_var_name)) ifelse( is.null(conf_lo_var_name),
                                                            "actual",
                                                            ifelse(is.na(conf_lo), "actual", "prediction")
            ) else .key
        ) %>%
        mutate(
            .model_id   = if(is.null(model_id_var_name)) 
                            ifelse(.key == "actual", NA, 1)
                          else .model_id,
            .model_desc = if(is.null(model_descr_var_name))
                            ifelse(.key == "actual", "ACTUAL", "model-1")
                          else .model_descr,
        ) %>% 
        plot_modeltime_forecast(
            .conf_interval_show = conf_interval_show,
            .conf_interval_fill = conf_interval_fill,
            .conf_interval_alpha = conf_interval_alpha,
            .smooth = smooth,
            .legend_show = legend_show,
            .legend_max_width = legend_max_width,
            .interactive = TRUE,
            .title = title,
            .x_lab = x_lab,
            .y_lab = y_lab,
            .plotly_slider = plotly_slider
        )
} else {
    rc <- ggplot() + theme_minimal() # Empty plot
    p <- plotly::ggplotly(rc, tooltip = c('x', 'y'))
}


####################################################

############# Create and save widget ###############
internalSaveWidget(p, 'out.html');
####################################################

################ Reduce paddings ###################
ReadFullFileReplaceString('out.html', 'out.html', ',"padding":[0-9]*,', ',"padding":0,')
####################################################

