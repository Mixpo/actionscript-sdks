////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.chartClasses
{

import flash.events.Event;
import flash.events.EventDispatcher;
import mx.charts.LinearAxis;
import mx.core.mx_internal;
import mx.events.FlexEvent;

use namespace mx_internal;

//--------------------------------------
//  Events
//--------------------------------------

/**
 *  Dispatched when the transformation from data space to screen space
 *  has changed, typically either because the axes that make up
 *  the transformation have changed in some way,
 *  or the data transform itself has size.
 *
 *  @eventType mx.events.FlexEvent.TRANSFORM_CHANGE
 */
[Event(name="transformChange", type="mx.events.FlexEvent")]

/**
 *  The DataTransform object represents a portion of a chart
 *  that contains glyphs and can transform values
 *  to screen coordinates and vice versa.
 *  Each DataTransform object has a horizontal axis, a vertical axis,
 *  and a set of glyphs (background, data, and overlay) to render.  
 *  
 *  <p>In theory, a chart can contain multiple overlaid DataTransform objects.
 *  This allows you to display a chart with multiple data sets
 *  rendered in the same area but with different ranges.
 *  For example, you might want to show monthly revenues
 *  compared to the number of units sold. 
 *  If revenue was typically in millions while units was typically
 *  in the thousands, it would be difficult to render these effectively
 *  along the same range.
 *  Overlaying them in different DataTransform objects allows
 *  the end user to compare trends in the values
 *  when they are rendered with different ranges.</p>
 *
 *  <p>Charts can only contain one set of DataTransform.</p>
 *  
 *  <p>Most of the time, you will use the ChartBase object,
 *  which hides the existance of the DataTransform object
 *  between the chart and its contained glyphs and axis objects.
 *  If you create your own ChartElement objects, you must understand
 *  the methods of the DataTransform class to correctly implement their element.</p>
 */
public class DataTransform extends EventDispatcher
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function DataTransform()
    {
        super();
    }

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  axes
    //----------------------------------

    /**
     *  @private
     *  Storage for the axes property.
     */
    private var _axes:Object = {};
    
    [Inspectable(environment="none")]

    /**
     *  The set of axes associated with this transform.
     */
    public function get axes():Object
    {
        return _axes;
    }

    //----------------------------------
    //  elements
    //----------------------------------

    /**
     *  @private
     */
    private var _elements:Array /* of ChartElement */ = [];

    [Inspectable(environment="none")]

    /**
     *  The elements that are associated with this transform.
     *  This Array includes background, series, and overlay elements
     *  associated with the transform.
     *  This value is assigned by the enclosing chart object.
     */
    public function get elements():Array /* of ChartElement */
    {
        return _elements;
    }

    /**
     *  @private
     */
    public function set elements(value:Array /* of ChartElement */):void
    {
        _elements = value;  
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Maps a set of numeric values representing data to screen coordinates. 
     *  This method assumes the values are all numbers,
     *  so any non-numeric values must have been previously converted
     *  with the <code>mapCache()</code> method.
     *
     *  @param cache An array of objects containing the data values
     *  in their fields. This is also where this function
     *  will store the converted numeric values.
     *
     *  @param xField The field where the data values for the x axis
     *  can be found.
     *
     *  @param xConvertedField The field where the mapped x screen coordinate
     *  will be stored.
     *
     *  @param yField The field where the data values for the y axis
     *  can be found.
     *
     *  @param yConvertedField The field where the mapped y screen coordinate
     *  will be stored.
     */     
    public function transformCache(cache:Array /* of Object */,
                                   xField:String, xConvertedField:String,
                                   yField:String, yConvertedField:String):void
    {
    }

    /**
     *  Transforms x and y coordinates relative to the DataTransform
     *  coordinate system into a two-dimensional value in data space.
     *  
     *  @param ...values The x and y positions (in that order).
     *  
     *  @return An Array containing the transformed values.
     */     
    public function invertTransform(...values):Array
    {
        return null;
    }

    /**
     *  Informs the DataTransform that some of the underlying data
     *  being represented on the chart has changed.
     *  The DataTransform generally has no knowledge of the source
     *  of the underlying data being represented by the chart,
     *  so glyphs should call this when their data changes
     *  so that the DataTransform can recalculate range scales
     *  based on their data.
     *  This does <b>not</b> invalidate the DataTransform,
     *  because there is no guarantee the data has changed.
     *  The axis objects (or range objects) must trigger an invalidate event.
     */
    public function dataChanged():void
    {
        for (var name:String in _axes)
        {
            if (_axes[name])
                _axes[name].dataChanged();
        }
    }
    
    /**
     *  Collects important displayed values for all elements
     *  associated with this data transform.
     *  Axis instances call this method to collect the values
     *  they need to consider when auto-generating appropriate ranges.
     *  This method returns an Array of BoundedValue objects.
     *  
     *  <p>To collect important values for the horizontal axis
     *  of a CartesianTransform, pass 0.
     *  To collect values for the vertical axis, pass 1.</p>
     * 
     *  @param dimension The dimension to collect values for.
     *
     *  @param requiredFields Defines the data that are required
     *  by this transform.
     *  
     *  @return A Array of BoundedValue objects.
     */
    public function describeData(dimension:String, requiredFields:uint):Array /* of BoundedValue */
    {
        var results:Array /* of BoundedValue */ = [];
        
        var n:int = elements.length;
        for (var i:int = 0; i < n; i++)
        {
            var dataGlyph:IChartElement = (elements[i] as IChartElement);
            if (!dataGlyph)
                continue;
            
            results = results.concat(
                dataGlyph.describeData(dimension, requiredFields));         
        }

        return results;
    }       
    
    /**
     *  Retrieves the axis instance responsible for transforming
     *  the data dimension specified by the <code>dimension</code> parameter.
     *  If no axis has been previously assigned, a default axis is created.
     *  The default axis for all dimensions is a LinearAxis
     *  with the <code>autoAdjust</code> property set to <code>false</code>. 
     *
     *  @param dimension The dimension whose axis is responsible
     *  for transforming the data.
     *  
     *  @return The axis instance.
     *  
     *  @see mx.charts.LinearAxis
     */
    public function getAxis(dimension:String):IAxis
    {
        if (!(_axes[dimension]))
        {
            var newAxis:LinearAxis = new LinearAxis();
            newAxis.autoAdjust = false;
            setAxisNoEvent(dimension,newAxis);
        }

        return _axes[dimension];
    }

    /**
     *  Assigns an axis instance to a particular dimension of the transform.
     *  Axis objects are assigned by the enclosing chart object.
     *  
     *  @param dimension The dimension of the transform.
     *  @param v The target axis instance.
     */
    public function setAxis(dimension:String, v:IAxis):void
    {
        setAxisNoEvent(dimension, v);

        mappingChangeHandler();
    }

    /**
     *  @private
     */
    private function setAxisNoEvent(dimension:String, v:IAxis):void
    {   
        var oldV:IAxis = _axes[dimension];

        if (oldV)
        {
            oldV.unregisterDataTransform(this);
            oldV.removeEventListener("mappingChange", mappingChangeHandler);
        }

        _axes[dimension] = v;

        {
            v.registerDataTransform(this, dimension);
            v.addEventListener("mappingChange", mappingChangeHandler, false, 0, true);
        }       
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handlers
    //
    //--------------------------------------------------------------------------

    /**
     *  @private 
     */
    private function mappingChangeHandler(e:Event = null):void
    {
        var n:int = elements.length;
        for (var i:int = 0; i < n; i++)
        {
            var g:IChartElement = elements[i] as IChartElement;
            if (g)
                g.mappingChanged();
        }
    }
}

}
