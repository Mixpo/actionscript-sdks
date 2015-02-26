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
import mx.charts.series.AreaSeries;
import mx.core.IFlexDisplayObject;
import mx.charts.series.items.AreaSeriesItem;



[Mixin]
/**
 * 
 *  Defines the methods and properties required to perform instrumentation for the 
 *  AreaSeries class. 
 * 
 *  @see mx.charts.series.AreaSeries
 *  
 */
public class AreaSeriesAutomationImpl extends SeriesAutomationImpl 
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
        Automation.registerDelegateClass(AreaSeries, AreaSeriesAutomationImpl);
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     * @param obj AreaSeries object to be automated.
     */
    public function AreaSeriesAutomationImpl(obj:AreaSeries)
    {
        super(obj);
        
        areaSeries = obj;
    }

    /**
     * @private
     */
    private var areaSeries:AreaSeries;

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
        if(areaSeries.xField && areaSeries.yField)
            return String(areaSeries.xField + ";" + areaSeries.yField);

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
        if (item is AreaSeriesItem)
        {
            var aItem:AreaSeriesItem = item as AreaSeriesItem;
            var x:int = aItem.x;
            var y:int = aItem.y;
            
            var p:Point = new Point(x,y);
            
            p = areaSeries.localToGlobal(p);
            p = areaSeries.owner.globalToLocal(p);
            return p;
        }
        
        
        return super.getChartItemLocation(item);    
    }

}

}