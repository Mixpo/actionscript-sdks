////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product. If you have received this file from a source
//  other than Adobe, then your use, modification, or distribution of this file
//  requires the prior written permission of Adobe.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.chartClasses
{

import mx.core.IUIComponent;
import flash.geom.Rectangle;

/**
 *  The IAxis class is an abstract interface for defining label,
 *  tick mark, and data positioning properties for a chart axis.
 *
 *  <p>Classes implement this interface to provide
 *  range definition functionality.</p>
 *
 *  @see mx.charts.CategoryAxis
 *  @see mx.charts.LinearAxis
 */
public interface IAxisRenderer extends IUIComponent
{
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  axis
    //----------------------------------

    /**
     *  The axis object associated with this renderer.
     *  This property is managed by the enclosing chart,
     *  and should not be explicitly set.
     */ 
    function get axis():IAxis;
    
    /**
     *  @private
     */
    function set axis(value:IAxis):void;
    
    //----------------------------------
    //  gutters
    //----------------------------------

    /**
     *  The distance between the axisRenderer
     *  and the sides of the surrounding chart. 
     *  This property is assigned automatically by the chart,
     *  and should not be assigned directly.
     */
    function get gutters():Rectangle;
    
    /**
     *  @private
     */
    function set gutters(value:Rectangle):void;
    
    //----------------------------------
    //  heightLimit
    //----------------------------------

    /**
     *  The maximum amount of space, in pixels,
     *  that an axis renderer will take from a chart.
     *  Axis Renderers by default will take up as much space in the chart
     *  as necessary to render all of their labels at full size.
     *  If heightLimit is set, an AxisRenderer will resort to reducing
     *  the labels in size in order to guarantee the total size of the axis
     *  is less than heightLimit.
     */
    function set heightLimit(value:Number):void;

    /**
     *  @private
     */
    function get heightLimit():Number;

    //----------------------------------
    //  horizontal
    //----------------------------------

    /**
     *  <code>true</code> if the axis renderer
     *  is being used as a horizontal axis.
     *  This property is managed by the enclosing CartesianChart,
     *  and should not be set directly.
     */
    function get horizontal():Boolean;
    
    /**
     *  @private
     */
    function set horizontal(value:Boolean):void

    //----------------------------------
    //  minorTicks
    //----------------------------------

    /**
     *  Contains an array that specifies where Flex
     *  draws the minor tick marks along the axis.
     *  Each array element contains a value between 0 and 1. 
     */
    function get minorTicks():Array /* of Number */;

    //----------------------------------
    //  otherAxes
    //----------------------------------

    /**
     *  An Array of axes.
     */
    function set otherAxes(value:Array /* of AxisRenderer */):void

    //----------------------------------
    //  placement
    //----------------------------------

    /**
     *  The side of the chart the axisRenderer will appear on.
     *  Legal values are <code>"left"</code> and <code>"right"</code>
     *  for vertical axis renderers and <code>"top"</code>
     *  and <code>"bottom"</code> for horizontal axis renderers.
     *  By default, primary axes are placed on the left and top,
     *  and secondary axes are placed on the right and bottom.
     *  CartesianCharts automatically guarantee that secondary axes
     *  are placed opposite primary axes; if you explicitly place
     *  a primary vertical axis on the right, for example,
     *  the secondary vertical axis is swapped to the left.
     */
    function get placement():String;
    
    /**
     *  @private
     */
    function set placement(value:String):void;

    //----------------------------------
    //  ticks
    //----------------------------------

    /**
     *  Contains an array that specifies where Flex
     *  draws the tick marks along the axis.
     *  Each array element contains a value between 0 and 1. 
     */
    function get ticks():Array /* of Number */;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Adjusts its layout to accomodate the gutters passed in.
     *  This method is called by the enclosing chart to determine
     *  the size of the gutters and the corresponding data area.
     *  This method provides the AxisRenderer with an opportunity
     *  to calculate layout based on the new gutters,
     *  and to adjust them if necessary.
     *  If a given gutter is adjustable, an axis renderer
     *  can optionally adjust the gutters inward (make the gutter larger)
     *  but not outward (make the gutter smaller).
     *
     *  @param workingGutters Defines the gutters to adjust.
     *
     *  @param adjustable Consists of four Boolean properties
     *  (left=true/false, top=true/false, right=true/false,
     *  and bottom=true/false) that indicate whether the axis renderer
     *  can optionally adjust each of the gutters further.
     *  
     *  @return A rectangle that defines the dimensions of the gutters, including the 
     *  adjustments.
     */
    function adjustGutters(workingGutters:Rectangle,
                           adjustable:Object):Rectangle;

    /**
     *  Called by the enclosing chart to indicate that the current state
     *  of the chart has changed.
     *  Implementing elements should respond to this method
     *  in order to synchronize changes to the data displayed by the element.
     * 
     *  @param oldState An integer representing the previous state.
     *
     *  @param v An integer representing the new state.
     */
    function chartStateChanged(oldState:uint,v:uint):void;
}

}
