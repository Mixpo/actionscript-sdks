////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates.charts 
{
import flash.display.DisplayObject;
import flash.geom.Point;

import mx.automation.Automation;
import mx.charts.ChartItem;
import mx.charts.series.ColumnSeries;
import mx.core.IFlexDisplayObject;
import mx.charts.series.items.ColumnSeriesItem;

[Mixin]
/**
 * 
 *  Defines the methods and properties required to perform instrumentation for the 
 *  ColumnSeries class. 
 * 
 *  @see mx.charts.series.ColumnSeries
 *  
 */
public class ColumnSeriesAutomationImpl extends SeriesAutomationImpl 
{
    include "../../../core/Version.as";
    
    //--------------------------------------------------------------------------
    //
    //  Class methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Registers the delegate class for a component class with automation manager.
     *  
     *  @param root The SystemManger of the application.
     */
    public static function init(root:DisplayObject):void
    {
        Automation.registerDelegateClass(ColumnSeries, ColumnSeriesAutomationImpl);
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  @param obj ColumnSeries object to be automated. 
     */
    public function ColumnSeriesAutomationImpl(obj:ColumnSeries)
    {
        super(obj);
        
        columnSeries = obj;
    }

    /**
     *  @private
     *  storage for the owner component
     */
    private var columnSeries:ColumnSeries;

    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function get automationName():String
    {
        if(columnSeries.xField && columnSeries.yField)
            return String(columnSeries.xField + ";" + columnSeries.yField);

        return super.automationName;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override protected function getChartItemLocation(item:ChartItem):Point
    {
        if (item is ColumnSeriesItem)
        {
            var aItem:ColumnSeriesItem = item as ColumnSeriesItem;
            var ypos:Number = (isNaN(aItem.min))? aItem.y : Math.min(aItem.y,aItem.min);
            var p:Point = new Point(aItem.x, ypos);
            p = columnSeries.localToGlobal(p);
            p = columnSeries.owner.globalToLocal(p);
            return p;
        }
        
        return super.getChartItemLocation(item);
    }
    
}

}