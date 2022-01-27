import { dataViewObjectsParser } from "powerbi-visuals-utils-dataviewutils";
import DataViewObjectsParser = dataViewObjectsParser.DataViewObjectsParser;
export declare class VisualSettings extends DataViewObjectsParser {
    settings_variable_params: settings_variable_params;
}
export declare class settings_variable_params {
    conf_interval_show_bool: boolean;
    conf_interval_alpha: number;
    smooth_bool: boolean;
    legend_show_bool: boolean;
    legend_max_width: number;
    title_str: string;
    x_lab_str: string;
    y_lab_str: string;
    plotly_slider_bool: boolean;
    conf_interval_fill_picker: string;
}
