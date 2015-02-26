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
import mx.charts.series.PieSeries;
import mx.charts.series.items.PieSeriesItem;
import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines the methods and properties required to perform instrumentation for the 
 *  LineSeries class. 
 * 
 *  @see mx.charts.series.LineSeries
 *  
 */
public class PieSeriesAutomationImpl extends SeriesAutomationImpl 
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
        Automation.registerDelegateClass(PieSeries, PieSeriesAutomationImpl);
    }   
    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *  @param obj PieSeries object to be automated.     
     */
    public function PieSeriesAutomationImpl(obj:PieSeries)
    {
        super(obj);
        
        pieSeries = obj;
    }
    
    /**
     *  @private
     */
    private var pieSeries:PieSeries;

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
        if (item is PieSeriesItem)
        {
            var aItem:PieSeriesItem = item as PieSeriesItem;

            var startAngle:Number = aItem.startAngle - pieSeries.startAngle ;
            
            var a:Number  =  startAngle + pieSeries.startAngle * Math.PI/180 + aItem.angle/2;
            var inr:Number = pieSeries.getInnerRadiusInPixels();
            var xpos:Number = aItem.origin.x + Math.cos(a)*(inr + (pieSeries.getRadiusInPixels()-inr)*.5);
            var ypos:Number = aItem.origin.y - Math.sin(a)*(inr + (pieSeries.getRadiusInPixels()-inr)*.5);

            var p:Point = new Point(xpos,ypos);
            p = pieSeries.localToGlobal(p);
            p = pieSeries.owner.globalToLocal(p);
            return p;
        }
        
        return super.getChartItemLocation(item);    
    }
    
}

}