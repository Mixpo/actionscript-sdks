////////////////////////////////////////////////////////////////////////////////
//  
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2007 Adobe Systems Incorporated
//  All Rights Reserved.
//   
//  NOTICE:  Adobe permits you to use, modify, and distribute this file in 
//  accordance with the terms of the Adobe license agreement accompanying it.  
//  If you have received this file from a source other than Adobe, then your use,
//  modification, or distribution of it requires the prior written permission of Adobe.
//
//  Adobe Patent or Adobe Patent Pending Invention Included Within this File
//  Adobe patent application tracking B503, entitled Charting Data Graphics - 
//  graphics drawing API that allows to draw in data space, inventors Ely Greenfield.
//  AdobePatentID="B503"
//
////////////////////////////////////////////////////////////////////////////////
package mx.charts.chartClasses
{
    
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.utils.Dictionary;
import mx.core.mx_internal;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;

use namespace mx_internal;

[DefaultProperty("dataChildren")]

/**
 * This class lets you use add graphical elements such as lines, ellipses, and other shapes
 * by using a graphics API. The values that you pass to the graphics API are in data
 * coordinates rather than screen coordinates. You can also add any DisplaObject to the canvas,
 * in the same way that you add children to containers.
 * 
 * <p>The drawing region for the canvas is determined by the <code>verticalAxis</code>
 * and <code>horizontalAxis</code>, if they are specified. Otherwise,
 * the canvas uses the default axes of the chart to compute the drawing region.</p>
 * 
 * <p>The data coordinates passed as parameters to the drawing APIs can be 
 * actual values of the data coordinate or an object of type <code>CartesianCanvasValue</code>,
 * which can hold a data coordinate value and an offset, in pixels.</p>
 * 
 * @mxml
 *  
 *  <p>The <code>&lt;mx:CartesianDataCanvas&gt;</code> tag inherits all the
 *  properties of its parent classes and adds the following properties:</p>
 *  
 *  <pre>
 *  &lt;mx:CartesianDataCanvas
 *    <strong>Properties</strong>
 *    dataChildren="<i>No default</i>"
 *    horizontalAxis="<i>No default</i>"
 *    includeInRanges="<i>false</i>"
 *    verticalAxis="<i>No default</i>"
 *  /&gt;
 *  </pre>
 */
public class CartesianDataCanvas extends ChartElement implements IDataCanvas
{
   
    private var _xMap:Dictionary;
    private var _yMap:Dictionary;
    private var _hDataDesc:DataDescription;
    private var _vDataDesc:DataDescription;
    
    private var _dataCache:CartesianDataCache;
    private var _dataCacheDirty:Boolean = true;
    private var _mappingDirty:Boolean = true;
    private var _filterDirty:Boolean = true;
    private var _transformDirty:Boolean = true;
    private var _oldUW:Number;
    private var _oldUH:Number;
    private var borderWidth:Number = 0;
    private var _bAxesDirty:Boolean = false;
    private var _childMap:Dictionary;


    //----------------------------------------------
    //
    // Constructor
    //
    //----------------------------------------------
    
    /**
     * Constructor.
     */
    public function CartesianDataCanvas()
    {
        super();
        _hDataDesc = new DataDescription();
        _vDataDesc = new DataDescription();
        _childMap = new Dictionary(true);
        
        dataTransform = new CartesianTransform();
    }
    
    //----------------------------------------------
    //
    // Properties
    //
    //----------------------------------------------
    
    /**
     * @private
     * Storage for includeInRanges property
     */
    private var _includeInRanges:Boolean = false;
    [Inspectable(category="General")]
    
    /**
     * If <code>true</code>, the computed range of the chart is affected by this
     * canvas.
     */
    
    public function get includeInRanges():Boolean
    {
        return _includeInRanges;
    }

    /**
     * @private
     */
    public function set includeInRanges(value:Boolean):void
    {
        if(_includeInRanges == value)
            return;
        _includeInRanges = value;
        dataChanged();
    }
    
    //----------------------------------
    //  verticalAxis
    //----------------------------------

    /**
     *  @private
     *  Storage for the verticalAxis property.
     */
    private var _verticalAxis:IAxis;

    [Inspectable(category="Data")]

    /**
     *  Defines the labels, tick marks, and data position
     *  for items on the y-axis.
     *  Use either the LinearAxis class or the CategoryAxis class
     *  to set the properties of the vertical axis as a child tag in MXML
     *  or create a LinearAxis or CategoryAxis object in ActionScript.
     */
    public function get verticalAxis():IAxis
    {
        return _verticalAxis;
    }
    
    /**
     *  @private
     */
    public function set verticalAxis(value:IAxis):void
    {
        _verticalAxis = value;
        _bAxesDirty = true;
        invalidateData();
        invalidateProperties();
    }
    
    //----------------------------------
    //  horizontalAxis
    //----------------------------------

    /**
     *  @private
     *  Storage for the horizontalAxis property.
     */
    private var _horizontalAxis:IAxis;
    
    [Inspectable(category="Data")]

    /**
     *  Defines the labels, tick marks, and data position
     *  for items on the x-axis.
     *  Use either the LinearAxis class or the CategoryAxis class
     *  to set the properties of the horizontal axis as a child tag in MXML
     *  or create a LinearAxis or CategoryAxis object in ActionScript.
     */
    public function get horizontalAxis():IAxis
    {
        return _horizontalAxis;
    }
    
    /**
     * @private
     */
    public function set horizontalAxis(value:IAxis):void
    {
        _horizontalAxis = value;
        _bAxesDirty = true;
        
        invalidateData();
        invalidateProperties();
    }
    
    //--------------------------------------------
    // opCodes
    //--------------------------------------------
    /**
     * @private
     * Storage for opCodes property
     */
    private var _opCodes:Array /* of OpCode */ = [];
        
    [ArrayElementType("CartesianOpCode")]
    
    /**
     * @private
     */
     
    private function get opCodes():Array /* of OpCode */
    {
        return _opCodes;
    }
    
    /**
     * @private
     */
    private function set opCodes(value:Array /* of OpCode */):void
    {       
        _opCodes = value;
        invalidateOpCodes();
    }
    
    //-----------------------------------------
    //  dataChildren
    //-----------------------------------------
    
    /**
     * @private
     * Storage for dataChildren property
     */
    private var _dataChildren:Array /* of DisplayObject */ = [];
    [Inspectable(category="General")]
    
    /**
     * An array of child objects.
     */
    public function get dataChildren():Array /* of DisplayObject */
    {
        return _dataChildren;
    }
    
    /**
     * @private
     */     
    public function set dataChildren(value:Array /* of DisplayObject */):void
    {
        for (var aChild:* in _childMap)
        {
            removeChild(_childMap[aChild].child);
        }
        _childMap = new Dictionary(true);
        _dataChildren = value;
        for (var i:int = 0; i < value.length; i++)
        {
            var dc:CartesianDataChild;
            if(value[i] is CartesianDataChild)               
                dc = value[i];
            else
                dc = new CartesianDataChild(value[i]);
                
            _childMap[dc.child] = dc;
            dc.addEventListener("change",dataChildChangeHandler,false,0,true);
            super.addChild(dc.child);           
        }
        invalidateOpCodes();
    }
        
    //----------------------------------------------
    //
    // Methods
    //
    //----------------------------------------------

    mx_internal function dataChildChangeHandler(e:Event):void
    {
        dataChildren = dataChildren;
    }

    /**
     * Adds the specified display object as a child to the current canvas.
     * 
     * @param child     The display object that is to be added as a child to current canvas.
     * @param left      Left x-coordinate of the <code>child</code> in data coordinates.
     * @param top       Top y-coordinate of the <code>child</code> in data coordinates.
     * @param right     Right x-coordinate of the <code>child</code> in data coordinates.
     * @param bottom    Bottom y-coordinate of the <code>child</code> in data coordinates.
     * @param hCenter   Middle x-coordinate of the <code>child</code> in data coordinates.
     * @param vCenter   Middle y-coordinate of the <code>child</code> in data coordinates.
     */
    public function addDataChild(child:DisplayObject,left:* = undefined, top:* = undefined, right:* = undefined, 
                                 bottom:* = undefined , hCenter:* = undefined, vCenter:* = undefined):void
    {
        var dc:CartesianDataChild = new CartesianDataChild(child,left,top,right,bottom);
        dc.addEventListener("change",dataChildChangeHandler,false,0,true);
        addChild(child);
        updateDataChild(child,left,top,right,bottom,hCenter,vCenter);
        invalidateOpCodes();
    }
    
    /**
     * @inheritDoc
     */
    override public function addChild(child:DisplayObject):DisplayObject
    {
        var dc:CartesianDataChild = new CartesianDataChild(child);
        _childMap[child] = dc;
        _dataChildren.push(dc);     
        dc.addEventListener("change",dataChildChangeHandler,false,0,true);
        invalidateOpCodes();
        return super.addChild(child);
    }
    
    /**
     * @inheritDoc
     */
    override public function addChildAt(child:DisplayObject,index:int):DisplayObject
    {
        var dc:CartesianDataChild = new CartesianDataChild(child);
        _childMap[child] = dc;
        _dataChildren.push(dc);         
        dc.addEventListener("change",dataChildChangeHandler,false,0,true);
        invalidateOpCodes();
        return super.addChildAt(child,index);
    }
        
    /**
     * @inheritDoc
     */
    override public function removeChild(child:DisplayObject):DisplayObject
    {       
        super.removeChild(child);
        if(child in _childMap)
            delete _childMap[child];
        _dataChildren.splice(_dataChildren.indexOf(child),1);
        return child;
    }
    
    /**
     * @inheritDoc
     */ 
    override public function removeChildAt(index:int):DisplayObject
    {
        var child:DisplayObject = super.removeChildAt(index);
        if(child in _childMap)
            delete _childMap[child];
        _dataChildren.splice(index,1);
        return child;
    }
    
    /**
     * Removes all data children (DisplayObject instances) of the canvas.
     */
    public function removeAllChildren():void
    {
        var len:int = _dataChildren.length;
        for (var i:int = len - 1; i >= 0; i--)
        {
            removeChildAt(i);
        }
    }
    
    /**
     * Updates the position of any child to current canvas.
     * 
     * @param child     The display object that is to be updated.
     * @param left      Left x coordinate of the child, in data coordinates.
     * @param top       Top y coordinate of the child, in data coordinates.
     * @param right     Right x coordinate of the child, in data coordinates.
     * @param bottom    Bottom y coordinate of the child, in data coordinates.
     * @param hCenter   Middle x coordinate of the child, in data coordinates.
     * @param vCenter   Middle y coordinate of the child, in data coordinates.
     * 
     * <p>For example:
     * <pre>
     *      var lbl:Label = new Label();
     *      lbl.text = "Last Month";
     *      canvas.addChild(lbl);
     *      canvas.updateDataChild(lbl,"Feb",200);
     * </pre>
     * </p>
     */
    public function updateDataChild(child:DisplayObject,left:* = undefined, top:* = undefined, right:* = undefined,
                                    bottom:* = undefined, hCenter:* = undefined, vCenter:* = undefined):void
    {
        var dc:CartesianDataChild = _childMap[child];
        dc.left = left;
        dc.top = top;
        dc.right = right;
        dc.bottom = bottom;
        dc.horizontalCenter = hCenter;
        dc.verticalCenter = vCenter;
        invalidateOpCodes();
    }

    /**
     * @copy flash.display.Graphics#clear()
     * @see flash.display.Graphics
     */
    public function clear():void
    {
        _opCodes = [];
        invalidateOpCodes();
    }

    /**
     * @copy flash.display.Graphics#beginFill()
     * @see flash.display.Graphics
     */
    public function beginFill(color:uint , alpha:Number = 1):void
    {
        pushOp(CartesianOpCode.BEGIN_FILL, { color: color, alpha: alpha} );
    }
    
    /**
     * Fills a drawing area with a bitmap image. The coordinates that you pass to this method are relative to 
     * the canvas's horizontal axis and vertical axis.
     * 
     * <p>The usage and parameters of this method are identical to the <code>beginBitmapFill()</code> method of the 
     * flash.display.Graphics class.</p>
     * 
     * @see flash.display.Graphics#beginBitmapFill()
     */
    public function beginBitmapFill(bitmap:BitmapData, x:* = undefined,
                                    y:* = undefined, matrix:Matrix = null,
                                    repeat:Boolean = true, smooth:Boolean = true):void
    {
        pushOp(CartesianOpCode.BEGIN_BITMAP_FILL, { bitmap:bitmap, x:x, y:y, repeat:repeat, smooth:smooth, matrix:matrix });
    }
    
    /**
     * Draws a curve using the current line style from the current drawing position to (anchorX, anchorY) and using the 
     * control point that (controlX, controlY) specifies. The coordinates that you pass to this method are in terms of 
     * chart data rather than screen coordinates.
     * 
     * <p>The usage and parameters of this method are identical to the <code>curveTo()</code> method of the 
     * flash.display.Graphics class.</p>
     * 
     * @see flash.display.Graphics#curveTo()
     */
    public function curveTo(controlX:*, controlY:*, anchorX:*, anchorY:*):void
    {
        pushOp(CartesianOpCode.CURVE_TO, { controlX: controlX, controlY:controlY, anchorX:anchorX, anchorY:anchorY, borderWidth: borderWidth } );
    }
    
    /**
     * The coordinates that you pass to this method are in terms of chart data rather than screen coordinates.
     * 
     * @copy flash.display.Graphics#drawCircle()
     * @see flash.display.Graphics
     */
    public function drawCircle(x:*, y:*, radius:Number):void
    {
        pushOp(CartesianOpCode.DRAW_CIRCLE, { x: x, y: y, radius: radius, borderWidth: borderWidth });
    }
    
    /**
     * The coordinates that you pass to this method are in terms of chart data rather than screen coordinates.
     * 
     * @copy flash.display.Graphics#drawEllipse()
     * @see flash.display.Graphics
     */
    public function drawEllipse(left:*, top:*, right:*, bottom:*):void
    {
        pushOp(CartesianOpCode.DRAW_ELLIPSE, { left: left, top: top, right: right, bottom: bottom, borderWidth: borderWidth });
    }
    
    /**
     * The coordinates that you pass to this method are in terms of chart data rather than screen coordinates.
     * 
     * @copy flash.display.Graphics#drawRect()
     * @see flash.display.Graphics
     */
    public function drawRect(left:*, top:*, right:*, bottom:*):void
    {
        pushOp(CartesianOpCode.DRAW_RECT, { left: left, top: top, right: right, bottom: bottom, borderWidth: borderWidth });
    }
    
    /**
     * The coordinates that you pass to this method are in terms of chart data rather than screen coordinates.
     * 
     * @copy flash.display.Graphics#drawRoundRect()
     * @see flash.display.Graphics
     */
    public function drawRoundedRect(left:*, top:*, right:*, bottom:*, cornerRadius:Number):void
    {
        pushOp(CartesianOpCode.DRAW_ROUNDRECT, { left: left, top: top, right: right, bottom: bottom, 
                                    borderWidth: borderWidth,
                                    cornerRadius: cornerRadius });
    }
    
    /** 
     * @copy flash.display.Graphics#endFill()
     * @see flash.display.Graphics
     */
    public function endFill():void
    {
        pushOp(CartesianOpCode.END_FILL);
    }
    
    /**
     * Specifies a line style that Flash uses for subsequent calls to other Graphics methods (such as <code>lineTo()</code> 
     * or <code>drawCircle()</code>) for the object.
     * 
     * <p>The usage and parameters of this method are identical to the <code>lineStyle()</code> method of the 
     * flash.display.Graphics class.</p>
     * 
     * @see flash.display.Graphics#lineStyle()
     */    
    public function lineStyle(thickness:Number, color:uint = 0, alpha:Number = 1.0,
                              pixelHinting:Boolean = false, scaleMode:String = "normal",
                              caps:String = null, joints:String = null, miterLimit:Number = 3):void
    {
        borderWidth = thickness;
        pushOp(CartesianOpCode.LINE_STYLE, { thickness: thickness, color: color, alpha: alpha, pixelHinting: pixelHinting, scaleMode: scaleMode,
                                    caps: caps, joints: joints, miterLimit: miterLimit });
    }
    
    /**
     * The coordinates that you pass to this method are in terms of chart data rather than screen coordinates.
     * 
     * @copy flash.display.Graphics#lineTo()
     * @see flash.display.Graphics
     */
    public function lineTo(x:*, y:*):void
    {
        pushOp(CartesianOpCode.LINE_TO, { x: x, y:y, borderWidth: borderWidth });
    }
    
    /**
     * The coordinates that you pass to this method are in terms of chart data rather than screen coordinates.
     * 
     * @copy flash.display.Graphics#moveTo()
     * @see flash.display.Graphics
     */
    public function moveTo(x:*, y:*):void
    {
        pushOp(CartesianOpCode.MOVE_TO, { x: x, y:y, borderWidth: borderWidth });
    }
    
    /**
     *  @inheritDoc
     */
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (_bAxesDirty)
        {
            if (dataTransform)
            {
                if(_horizontalAxis)
                {
                    _horizontalAxis.chartDataProvider = dataProvider;
                    CartesianTransform(dataTransform).setAxis(
                        CartesianTransform.HORIZONTAL_AXIS,_horizontalAxis);
                }
                
                if(_verticalAxis)
                {
                    _verticalAxis.chartDataProvider = dataProvider;
                    CartesianTransform(dataTransform).setAxis(
                        CartesianTransform.VERTICAL_AXIS, _verticalAxis);
                }
            }
            _bAxesDirty = false; 
        }
        
        var c:CartesianChart = CartesianChart(chart);
        if(c)
        {
            if(!_horizontalAxis)
            {
                if(dataTransform.axes[CartesianTransform.HORIZONTAL_AXIS] != c.horizontalAxis)
                        CartesianTransform(dataTransform).setAxis(
                            CartesianTransform.HORIZONTAL_AXIS,c.horizontalAxis);
            }
                            
            if(!_verticalAxis)
            {
                if(dataTransform.axes[CartesianTransform.VERTICAL_AXIS] != c.verticalAxis)
                        CartesianTransform(dataTransform).setAxis(
                            CartesianTransform.VERTICAL_AXIS, c.verticalAxis);
            }
        }
        dataTransform.elements = [this];
        invalidateOpCodes();
    }
    
    /**
     *  Calls the <code>updateTransform()</code> method of the canvas, if necessary.
     *  This method is called automatically by the canvas
     *  during the <code>commitProperties()</code> method, as necessary,
     *  but a derived canvas might call it explicitly
     *  if the generated values are needed at an explicit time.
     *  Filtering and transforming of data relies on specific values
     *  being calculated by the axes, which can in turn
     *  depend on the data that is displayed in the chart.
     *  Calling this function at the wrong time might result
     *  in extra work being done, if those values are updated.
     */
    protected function validateTransform():Boolean
    {
        var updated:Boolean = false;
        if (dataTransform && _transformDirty)
        {
            updated = updateTransform();
        }
        return updated;
    }
    
    /**
     *  Calls the <code>updateMapping()</code> 
     *  and <code>updateFilter()</code> methods of the canvas, if necessary.
     *  This method is called automatically by the canvas
     *  from the <code>commitProperties()</code> method, as necessary,
     *  but a derived canvas might call it explicitly
     *  if the generated values are needed at an explicit time.
     *  Loading and mapping data against the axes is designed
     *  to be acceptable by the axes at any time.
     *  It is safe this method explicitly at any point.
     */
    protected function validateData():void
    {
        if (dataTransform)
        {
            if (_mappingDirty)
            {
                updateMapping();
            }
            if(_filterDirty)
            {
                updateFilter();
            }
        }
    }
    
    /**
     *  Called when the underlying data the canvas represents
     *  needs to be filtered against the ranges represented by the axes
     *  of the associated data transform.
     *  This can happen either because the underlying data has changed
     *  or because the range of the associated axes has changed.
     *  If you implement a custom canvas type, you should override this method
     *  and filter out any outlying data using the <code>filterCache()</code>
     *  method of the axes managed by its associated data transform.  
     *  The <code>filterCache()</code> method converts any values
     *  that are out of range to <code>NaN</code>.
     *  You must be sure to call the <code>super.updateFilter()</code> method
     *  in your subclass.
     *  You should not generally call this method directly.
     *  Instead, if you need to guarantee that your data has been filtered
     *  at a given point, call the <code>validateTransform()</code> method
     *  of the CartesianDataCanvas class.
     *  You can generally assume that your <code>updateData()</code>
     *  and <code>updateMapping()</code> methods have been called
     *  prior to this method, if necessary.
     */
    
    protected function updateFilter():void
    {
        dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).filterCache(_dataCache.yCache,"mappedValue","filteredValue");
        dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).filterCache(_dataCache.xCache,"mappedValue","filteredValue");
        for (var i:int = 0; i < _dataCache.xCache.length; i++)
        {
            if(isNaN(_dataCache.xCache[i].filteredValue))
                delete _dataCache.xMap[_dataCache.xCache[i].value];
        }
        for (i = 0; i < _dataCache.yCache.length; i++)
        {
            if(isNaN(_dataCache.yCache[i].filteredValue))
                delete _dataCache.yMap[_dataCache.yCache[i].value];
        }
        stripNaNs(_dataCache.xCache,"filteredValue");
        stripNaNs(_dataCache.yCache,"filteredValue");
        _filterDirty = false;
    }
    
    /**
     * @inheritDoc
     */
        
    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        
        super.updateDisplayList(unscaledWidth, unscaledHeight);

        
        validateData();
        
        var i:int;
        
        
        var updated:Boolean = validateTransform();
        
        if(updated)
        {
            var g:Graphics = graphics;
            
            g.clear();
            for (i = 0; i < _opCodes.length; i++)
            { 
                _opCodes[i].render(this,_dataCache);
            }
            positionChildren();
        }
    }

    /**
     * @private
     */
    private function mapChildren():void
    {
        var width:Number;
        var height:Number;
        for (var aChild:* in _childMap)
        {
            var dc:CartesianDataChild = _childMap[aChild];
            if(dc.horizontalCenter != undefined)
            {
                width = widthFor(dc.child);
                split(dc.horizontalCenter)
                _dataCache.storeX(_data,width/2 - _offset,width/2 + _offset);
            }
            else if(dc.right == undefined)
            {
                split(dc.left);
                _dataCache.storeX(_data,- _offset,widthFor(dc.child) + _offset);
            }
            else if (dc.left == undefined)              
            {
                split(dc.right);
                _dataCache.storeX(_data,widthFor(dc.child) - _offset,_offset);
            }   
            else
            {
                split(dc.left);
                _dataCache.storeX(_data,-_offset,_offset);
                split(dc.right);
                _dataCache.storeX(_data,-_offset,_offset);
            }
            if(dc.verticalCenter != undefined)
            {
                height = heightFor(dc.child);
                split(dc.verticalCenter);
                _dataCache.storeY(_data,height/2 - _offset,height/2 + _offset);
            }
            else if(dc.bottom== undefined)
            {
                split(dc.top);
                _dataCache.storeY(_data,- _offset,heightFor(dc.child) + _offset);
            }
            else if (dc.top == undefined)               
            {
                split(dc.bottom);
                _dataCache.storeY(_data,heightFor(dc.child) - _offset,_offset);
            }
            else
            {
                split(dc.top);
                _dataCache.storeY(_data,-_offset,_offset);
                split(dc.bottom);
                _dataCache.storeY(_data,-_offset,_offset);
            }
        }
    }
    
    /**
     *  Removes any item from the provided cache whose <code>field</code>
     *  property is <code>NaN</code>.
     *  Derived classes can call this method from their updateFilter()
     * implementation to remove any ChartItems filtered out by the axes.
     */
    protected function stripNaNs(cache:Array /* of Object */, field:String):void
    {
        var len:int = cache.length;
        var start:int = -1;
        var end:int = -1;
        var i:int;

        if (field == "")
        {
            for (i = cache.length - 1; i >= 0; i--)
            {
                if (isNaN(cache[i]))
                {
                    if (start < 0)
                    {
                        start = end = i;
                    }
                    else if (end - 1 == i)
                    {
                        end = i;
                    }
                    else
                    {
                        cache.splice(end, start - end + 1);
                        start = end = i;
                    }
                }
            }
        }
        else
        {
            for (i = cache.length - 1; i >= 0; i--)
            {
                if (isNaN(cache[i][field]))
                {
                    if (start < 0)
                    {
                        start = end = i;
                    }
                    else if (end - 1 == i)
                    {
                        end = i;
                    }
                    else
                    {
                        cache.splice(end, start - end + 1);
                        start = end = i;
                    }
                }
            }
        }

        if (start >= 0)
            cache.splice(end, start - end + 1);
    }
    
    /**
     *  Informs the canvas that the underlying data
     *  in the data provider has changed.
     *  This method triggers calls to the <code>updateMapping()</code>
     *  and <code>updateTransform()</code> methods on the next call
     *  to the <code>commitProperties()</code> method.
     *  
     *  @param invalid <code>true</code> if the data provider's data has changed.
     */
    protected function invalidateData(invalid:Boolean = true):void
    {
        if (invalid)
        {
            invalidateDisplayList();
        }
    }
        
    /**
     * @private
     * Takes our data values and converts them into pixel values.
     */
    protected function updateMapping():void
    {
        if(_dataCacheDirty)
        {
            _dataCache = new CartesianDataCache();
            var i:int;
            var key:*;
            var record:*;
            var value:*;
            var boundedValue:BoundedValue;
            for (i = 0; i < _opCodes.length; i++)
            {
                _opCodes[i].collectValues(_dataCache);
            }

            mapChildren();
                
            _dataCache.xCache = [];
            _dataCache.yCache = [];
            _hDataDesc.min = Number.MAX_VALUE;
            _hDataDesc.max = Number.MIN_VALUE;
            _vDataDesc.min = Number.MAX_VALUE;
            _vDataDesc.max = Number.MIN_VALUE;
            for (key in _dataCache.xMap)
            {
                value = _dataCache.xMap[key];
                _dataCache.xCache.push({ value: value });             
            }
            for (key in _dataCache.yMap)
            {
                value = _dataCache.yMap[key];
                _dataCache.yCache.push({ value: value });             
            }
            _dataCacheDirty = false;
            _mappingDirty = true;
        }
        if(_mappingDirty)
        {
            dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).mapCache(_dataCache.yCache,"value","mappedValue",true);
            dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).mapCache(_dataCache.xCache,"value","mappedValue",true);
            _transformDirty = true;
            _mappingDirty = false;
            _filterDirty = true;
            var boundedValues:Array /* of BoundedValue */ = [];

            for (i = 0; i < _dataCache.xCache.length; i++)
            {
                value = _dataCache.xCache[i];
                boundedValue = _dataCache.xBoundedValues[value.value];
                if (boundedValue)
                {
                    boundedValue.value = value.mappedValue;
                    boundedValues.push(boundedValue);
                }
            }
            if(boundedValues.length > 0)
            {
                _hDataDesc.boundedValues = boundedValues;
                boundedValues = [];
            }
            for (i = 0; i < _dataCache.yCache.length; i++)
            {
                value = _dataCache.yCache[i];
                boundedValue = _dataCache.yBoundedValues[value.value];
                if (boundedValue)
                {
                    boundedValue.value = value.mappedValue;
                    boundedValues.push(boundedValue);
                }
            }
            if(boundedValues.length > 0)
            {
                _vDataDesc.boundedValues = boundedValues;
            }

            for (i = 0; i < _dataCache.yCache.length; i++)
            {
                record = _dataCache.yCache[i];
                _vDataDesc.min = Math.min(_vDataDesc.min, record.mappedValue);
                _vDataDesc.max = Math.max(_vDataDesc.max, record.mappedValue);
            }
            
            for (i = 0; i < _dataCache.xCache.length; i++)
            {
                record = _dataCache.xCache[i];
                _hDataDesc.min = Math.min(_hDataDesc.min, record.mappedValue);
                _hDataDesc.max = Math.max(_hDataDesc.max, record.mappedValue);
            }
            
        }
    }
    
    /**
     *  @inheritDoc
     */
    override public function invalidateDisplayList():void
    {
        _dataCacheDirty = true;
        _mappingDirty = true;
        _filterDirty = true;
        _transformDirty = true;
        super.invalidateDisplayList();
    } 
    
    /**
     *  @inheritDoc
     */
    override public function dataToLocal(... dataValues):Point
    {
        var data:Object = {};
        var da:Array = [ data ];
        var n:int = dataValues.length;
        
        if (n > 0)
        {
            data["d0"] = dataValues[0];
            dataTransform.getAxis(CartesianTransform.HORIZONTAL_AXIS).
                mapCache(da, "d0", "v0");
        }
        
        if (n > 1)
        {
            data["d1"] = dataValues[1];
            dataTransform.getAxis(CartesianTransform.VERTICAL_AXIS).
                mapCache(da, "d1", "v1");           
        }

        dataTransform.transformCache(da,"v0","s0","v1","s1");
        
        return new Point(data.s0 + this.x,
                         data.s1 + this.y);
    }

    /**
     *  @inheritDoc
     */
    override public function localToData(v:Point):Array
    {
        var values:Array = dataTransform.invertTransform(
                                            v.x - this.x,
                                            v.y - this.y);
        return values;
    }
    
    //----------------------------------
    //  dataTransform
    //----------------------------------

    /**
     *  @inheritDoc
     */
    override public function set dataTransform(value:DataTransform):void
    {
        if (value)
        {
            super.dataTransform = value;
        }
        else
        {
            var axis:String;
            for (axis in dataTransform.axes)
            {
                dataTransform.getAxis(axis).unregisterDataTransform(dataTransform);
            }
        }
    }
    
    /**
     * @private
     */
    protected function updateTransform():Boolean
    {
        var i:int;
        var record:Object;
        var updated:Boolean = false;
        if(_transformDirty == false)
        {
            if(unscaledHeight != _oldUW || unscaledWidth != _oldUW)
            {
                _transformDirty = true;
                _oldUW = unscaledWidth;
                _oldUH = unscaledHeight;
            }
        }

        if(_transformDirty)
        {
            updated = true;
            _transformDirty = false;
            dataTransform.transformCache(_dataCache.xCache,"mappedValue","pixelValue",null,null);           
            dataTransform.transformCache(_dataCache.yCache,null,null,"mappedValue","pixelValue");           
    
            for (i = 0; i < _dataCache.xCache.length; i++)
            {
                record = _dataCache.xCache[i];
                _dataCache.xMap[record.value] = record.pixelValue;
            }
            for (i = 0; i < _dataCache.yCache.length; i++)
            {
                record = _dataCache.yCache[i];
                _dataCache.yMap[record.value] = record.pixelValue;
            }
        }
        return updated;
    }

    /**
     * @inheritDoc
     */
    override public function describeData(dimension:String,
                                          requiredFields:uint):Array /* of DataDescription */
    {
        updateMapping();
        var result:Array /* of DataDescription */ = [];

        if(_includeInRanges)
        {
            if (dimension == CartesianTransform.VERTICAL_AXIS)
            {
                if(_dataCache.xCache.length > 0)
                    result.push(_vDataDesc);
            }
            else if (dimension == CartesianTransform.HORIZONTAL_AXIS)
            {
                if(_dataCache.yCache.length > 0)
                    result.push(_hDataDesc);
            }
        }

        return result;  
    }
        
    private var _data:*;
    private var _offset:Number;
    
    /**
     * @private
     * Retrieves value and offset from given data
     */
    private function split(v:*):void
    {
        if(v is CartesianCanvasValue)
        {
            _data = v.value;
            _offset = v.offset;
            if(isNaN(_offset))
                _offset = 0;
        }
        else
        {
            _data = v;
            _offset = 0;
        }
    }
    
    /**
     * @private
     * Retrieves value from given data
     */
    private function data(v:*):*
    {
        if(v is CartesianCanvasValue)
            return v.value;
        else
            return v;
    }
    
    /**
     * @private
     * Retrieves offset from given data
     */
    private function offset(v:*):*
    {
        if(v is CartesianCanvasValue)
            return v.offset;
        else
            return 0;
    }
        
    /**
     * @inheritDoc
     */ 
    // this function is called by the charting package when the axes that affect this element change their mapping some how.
    // that means we need to call the mapCache function again to get new mappings.  
    override public function mappingChanged():void
    {
        invalidateDisplayList();
    }
    
    /**
     * @private
     */
    private function widthFor(child:DisplayObject):Number
    {
        return  (child is IUIComponent)? IUIComponent(child).getExplicitOrMeasuredWidth() + 2:
                (child is IFlexDisplayObject)? IFlexDisplayObject(child).measuredWidth + 2:
                child.width; 
    }

    /**
     * @private
     */
    private function heightFor(child:DisplayObject):Number
    {
        return  (child is IUIComponent)? IUIComponent(child).getExplicitOrMeasuredHeight() + 2:
                (child is IFlexDisplayObject)? IFlexDisplayObject(child).measuredHeight + 2:
                child.height; 
    }
    
    /**
     * private
     */
    private function positionChildren():void
    {
        for (var aChild:* in _childMap)
        {
            var dc:CartesianDataChild = _childMap[aChild];
            var left:Number;
            var right:Number;
            var top:Number;
            var bottom:Number;
            var hCenter:Number;
            var vCenter:Number;
            var width:Number;
            var height:Number;
            
            if(dc.horizontalCenter != undefined)
            {
                hCenter = _dataCache.x(data(dc.horizontalCenter)) + offset(dc.horizontalCenter);
                width = widthFor(dc.child);
                left = hCenter - width/2;
                right = hCenter + width/2;      
            }
            else if(dc.right == undefined)
            {
                left = _dataCache.x(data(dc.left)) + offset(dc.left);
                right = left + widthFor(dc.child);
            }
            else if (dc.left == undefined)              
            {
                right = _dataCache.x(data(dc.right)) + offset(dc.right);
                left = right - widthFor(dc.child);
            }
            else
            {
                left = _dataCache.x(data(dc.left)) + offset(dc.left);
                right = _dataCache.x(data(dc.right)) + offset(dc.right);
            }
            
            if(dc.verticalCenter != undefined)
            {
                vCenter = _dataCache.y(data(dc.verticalCenter)) + offset(dc.verticalCenter);
                height = heightFor(dc.child);
                top = vCenter - height/2;
                bottom= vCenter + height/2;     
            }
            else if(dc.bottom == undefined)
            {
                top = _dataCache.y(data(dc.top)) + offset(dc.top);
                bottom = top + heightFor(dc.child);
            }
            else if (dc.top == undefined)               
            {
                bottom = _dataCache.y(data(dc.bottom)) + offset(dc.bottom);
                top = bottom - heightFor(dc.child);
            }
            else
            {
                top = _dataCache.y(data(dc.top)) + offset(dc.top);
                bottom = _dataCache.y(data(dc.bottom)) + offset(dc.bottom);
            }
            if(isNaN(left) || isNaN(right) || isNaN(top) || isNaN(bottom))
            {
                removeChild(aChild);
                continue;
            }
            if(dc.child is IFlexDisplayObject)
            {
                IFlexDisplayObject(dc.child).setActualSize(right-left,bottom-top);
                IFlexDisplayObject(dc.child).move(left, top);
            }
            else
            {
                dc.child.width = right - left;
                dc.child.height = bottom - top;
                dc.child.x = left;
                dc.child.y = top;
            }
        }
    }     

    /**
     * @private
     */
    private function invalidateOpCodes():void
    {
        dataChanged();
        invalidateDisplayList();
    }
    
    /**
     * @private
     */
    private function pushOp(code:int, params:Object = null):CartesianOpCode
    {
        var op:CartesianOpCode = new CartesianOpCode(this,code,params);
        _opCodes.push(op);
        invalidateOpCodes();
        return op;
    }
}

}

import mx.charts.chartClasses.CartesianDataCanvas;
import flash.utils.Dictionary;
import mx.charts.chartClasses.BoundedValue;
import flash.geom.Matrix;
import flash.display.Graphics;
import mx.charts.chartClasses.CartesianCanvasValue;
import mx.core.mx_internal;

use namespace mx_internal;

class CartesianOpCode
{
    public var canvas:CartesianDataCanvas;
    public var code:int;
    public var params:Object;
    
    public function CartesianOpCode(canvas:CartesianDataCanvas,code:int, params:Object = null):void
    {
        this.canvas = canvas;
        this.code = code;
        this.params = (params == null) ? {} : params;
    }
    
    public static const BEGIN_BITMAP_FILL:int =     0;
    public static const BEGIN_FILL:int =            1;
    public static const CURVE_TO:int =              2;
    public static const DRAW_CIRCLE:int =           3;
    public static const DRAW_ELLIPSE:int =          4;
    public static const DRAW_RECT:int =             5;
    public static const DRAW_ROUNDRECT:int =        6;  
    public static const END_FILL:int =              7;
    public static const LINE_STYLE:int =            8;
    public static const LINE_TO:int =               9;
    public static const MOVE_TO:int =               10;
    
    private var _data:*;
    private var _offset:Number;

    private function split(v:*):void
    {
        if(v is CartesianCanvasValue)
        {
            _data = v.value;
            _offset = v.offset;
            if(isNaN(_offset))
                _offset = 0;
        }
        else
        {
            _data = v;
            _offset = 0;
        }
    }
    
    private function data(v:*):*
    {
        if(v is CartesianCanvasValue)
            return v.value;
        else
            return v;
    }
    
    private function offset(v:*):*
    {
        if(v is CartesianCanvasValue)
            return v.offset;
        else
            return 0;
    }
    
    mx_internal function collectValues(cache:CartesianDataCache):void
    {
        switch(code)
        {
            case BEGIN_BITMAP_FILL:
                split(params.x);
                if(_data != undefined)
                    cache.storeX(_data,-_offset,_offset);
                split(params.y);
                if(_data != undefined)
                    cache.storeY(_data,-_offset,_offset);
                break;
            case CURVE_TO:
                split(params.anchorX);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.anchorY);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.controlX);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.controlY);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                break;
            case DRAW_CIRCLE:
                split(params.x);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.y);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                break;
            case MOVE_TO:
            case LINE_TO:
                split(params.x);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.y);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                break;
            case DRAW_ELLIPSE:
                split(params.left);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.top);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.right);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.bottom);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                break;
            case DRAW_RECT:
                split(params.left);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.top);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.right);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.bottom);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                break;
            case DRAW_ROUNDRECT:
                split(params.left);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.top);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.right);
                cache.storeX(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                split(params.bottom);
                cache.storeY(_data,-_offset+params.borderWidth/2,_offset+params.borderWidth/2);
                break;
        }
    }

    mx_internal function render(target:CartesianDataCanvas,cache:CartesianDataCache):void
    {
        var left:Number;
        var top:Number;
        var right:Number;
        var bottom:Number;
        var controlX:Number;
        var controlY:Number;
        var anchorX:Number;
        var anchorY:Number;
        var x:Number;
        var y:Number;
        
        var g:Graphics = target.graphics;
            switch(code)
        {
            case BEGIN_BITMAP_FILL:
                var m:Matrix;
                if(!(params.matrix))
                    m = new Matrix();
                else
                    m = params.matrix.clone();
                    
                var d:* = data(params.x);
                if(d != undefined)
                    m.tx = cache.x(d);
                m.tx  += offset(params.x);
                d = data(params.y);
                if(d != undefined)
                    m.ty = cache.y(d);
                m.ty += offset(params.y);
                g.beginBitmapFill(params.bitmap, m, params.repeat, params.smooth);
                break;
            
            case BEGIN_FILL:
                g.beginFill(params.color, params.alpha);
                break;              
            
            case CURVE_TO:
                controlX = cache.x(data(params.controlX)) + offset(params.controlX);
                controlY = cache.y(data(params.controlY)) + offset(params.controlY);
                anchorX = cache.x(data(params.anchorX)) + offset(params.anchorX);
                anchorY = cache.y(data(params.anchorY)) + offset(params.anchorY);
                if(isNaN(controlX) || isNaN(controlY) || isNaN(anchorX) || isNaN(anchorY))
                    return;
                g.curveTo(controlX, controlY, anchorX, anchorY);
                break;
            
            case DRAW_CIRCLE:
                x = cache.x(data(params.x)) + offset(params.x);
                y = cache.y(data(params.y)) + offset(params.y);
                if(isNaN(x) || isNaN(y))
                    return;
                 g.drawCircle(x, y, params.radius);
                break;
            
            case DRAW_ELLIPSE:
                left = cache.x(data(params.left)) + offset(params.left);
                top = cache.y(data(params.top)) + offset(params.top);
                right = cache.x(data(params.right)) + offset(params.right);
                bottom = cache.y(data(params.bottom)) + offset(params.bottom);
                if(isNaN(left) || isNaN(top) || isNaN(right) || isNaN(bottom))
                    return;
                g.drawEllipse(left, top, 
                            right - left,bottom - top);
                break;
                
            case DRAW_RECT:
                left = cache.x(data(params.left)) + offset(params.left);
                top = cache.y(data(params.top)) + offset(params.top);
                right = cache.x(data(params.right)) + offset(params.right);
                bottom = cache.y(data(params.bottom)) + offset(params.bottom);
                if(isNaN(left) || isNaN(top) || isNaN(right) || isNaN(bottom))
                    return;
                g.drawRect(left, top, 
                            right - left,bottom - top);
                break;
                
            case DRAW_ROUNDRECT:
                left = cache.x(data(params.left)) + offset(params.left);
                top = cache.y(data(params.top)) + offset(params.top);
                right = cache.x(data(params.right)) + offset(params.right);
                bottom = cache.y(data(params.bottom)) + offset(params.bottom);
                if(isNaN(left) || isNaN(top) || isNaN(right) || isNaN(bottom))
                    return;
                g.drawRoundRect(left, top, 
                            right - left,bottom - top,params.cornerRadius,params.cornerRadius);
                break;
                
            case END_FILL:
                g.endFill();
                break;
                    
            case LINE_STYLE:
                g.lineStyle(params.thickness,params.color,params.alpha,params.pixleHinting,params.scaleMode,params.caps,params.joints,params.miterLimit);
                break;
                
            case MOVE_TO:
                x = cache.x(data(params.x)) + offset(params.x);
                y = cache.y(data(params.y)) + offset(params.y);
                if(isNaN(x) || isNaN(y))
                    return;
                g.moveTo(x , y);
                break;
                
            case LINE_TO:
                x = cache.x(data(params.x)) + offset(params.x);
                y = cache.y(data(params.y)) + offset(params.y);
                if(isNaN(x) || isNaN(y))
                    return;
                g.lineTo(x,y);
                break;          
        }
    }
}

import mx.core.mx_internal;

use namespace mx_internal;

class CartesianDataCache
{
    public var xCache:Array /* of Object */;
    public var yCache:Array /* of Object */;
    
    public var xBoundedValues:Dictionary;
    public var yBoundedValues:Dictionary;
    public var xMap:Dictionary;
    public var yMap:Dictionary;
    
    public function CartesianDataCache():void
    {
        xMap = new Dictionary(true);
        yMap = new Dictionary(true);
        xCache = [];
        yCache = [];
        xBoundedValues = new Dictionary(true);
        yBoundedValues = new Dictionary(true);
    }
    
    mx_internal function storeX(value:*,leftMargin:Number = 0, rightMargin:Number = 0):void
    {
        var bounds:BoundedValue;

        if(leftMargin < 0)
            leftMargin = 0;
        if(rightMargin < 0)
            rightMargin = 0;
            
        xMap[value] = value;
        if(leftMargin != 0 || rightMargin != 0)
        bounds = xBoundedValues[value];
        if(leftMargin > 0)
            leftMargin += 2;
        if (rightMargin > 0)
            rightMargin += 2;
            
        if(!bounds)
        {
            xBoundedValues[value] = bounds = new BoundedValue(0,leftMargin,rightMargin);
        }
        else
        {
            bounds.lowerMargin = Math.max(bounds.lowerMargin,leftMargin);
            bounds.upperMargin = Math.max(bounds.upperMargin,rightMargin);
        }
    }

    mx_internal function storeY(value:*,topMargin:Number = 0,bottomMargin:Number = 0):void
    {
        var bounds:BoundedValue;

        yMap[value] = value;
        if(topMargin != 0 || bottomMargin != 0)
        {
            bounds = yBoundedValues[value];
            if(!bounds)
            {
                yBoundedValues[value] = bounds = new BoundedValue(0,bottomMargin,topMargin);
            }
            else
            {
                bounds.lowerMargin = Math.max(bounds.lowerMargin,bottomMargin);
                bounds.upperMargin = Math.max(bounds.upperMargin,topMargin);
            }
        }
    }
    
    mx_internal function x(value:*):Number
    {
        return Number(xMap[value]);
    }
    
    mx_internal function y(value:*):Number
    {
        return Number(yMap[value]);
    }
}

import flash.display.DisplayObject;
import flash.events.EventDispatcher;
import flash.events.Event;
use namespace mx_internal;
    
[DefaultProperty("content")]
[Event("change")]

class CartesianDataChild extends EventDispatcher
{
    public function CartesianDataChild(child:DisplayObject = null,left:* = undefined, top:* = undefined, right:* = undefined, bottom:* = undefined,
    horizontalCenter:* = undefined, verticalCenter:* = undefined):void
    {
        this.child = child;
        this.left = left;
        this.top = top;
        this.bottom = bottom;
        this.right = right;
    }
    
    public var child:DisplayObject;
    public var left:*;
    public var right:*;
    public var top:*;
    public var bottom:*;        
    public var horizontalCenter:*;
    public var verticalCenter:*;
    
    public function set content(value:*):void
    {
        if(value is DisplayObject)
            child = value;
        else if (value is Class)
            child = new value();
        dispatchEvent(new Event("change"));
    }       
}
