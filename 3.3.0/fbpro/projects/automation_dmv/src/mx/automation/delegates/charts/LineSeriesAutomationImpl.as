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
import mx.charts.series.LineSeries;
import mx.core.IFlexDisplayObject;
import mx.charts.series.items.LineSeriesItem;

[Mixin]
/**
 * 
 *  Defines the methods and properties required to perform instrumentation for the 
 *  LineSeries class. 
 * 
 *  @see mx.charts.series.LineSeries
 *  
 */
public class LineSeriesAutomationImpl extends SeriesAutomationImpl 
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
        Automation.registerDelegateClass(LineSeries, LineSeriesAutomationImpl);
    }   

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  @param obj LineSeries object to be automated.     
     */
    public function LineSeriesAutomationImpl(obj:LineSeries)
    {
        super(obj);
        
        lineSeries = obj;
    }

    
    /**
     *  @private
     */
    private var lineSeries:LineSeries;

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
        var name:Array = [] ;
        if (lineSeries.xField)
            name.push(lineSeries.xField);
        if (lineSeries.yField)
            name.push(lineSeries.yField);

        if (name.length)
            return name.join("|");

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
        if (item is LineSeriesItem)
        {
            var aItem:LineSeriesItem = item as LineSeriesItem;
            
            // chart edge points are not getting picked without -1.
            // (dataRegion containment check fails)
            var x:int = aItem.x-1;
            var y:int = aItem.y;
            
            var p:Point = new Point(x,y);
            p = lineSeries.localToGlobal(p);
            p = lineSeries.owner.globalToLocal(p);
            return p;
        }
        
        return super.getChartItemLocation(item);    
    }
    
}

}