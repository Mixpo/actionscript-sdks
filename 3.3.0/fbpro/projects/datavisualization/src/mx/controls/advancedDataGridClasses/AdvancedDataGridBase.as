////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2007 Adobe Systems Incorporated and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.controls.advancedDataGridClasses
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;

import mx.collections.ArrayCollection;
import mx.collections.CursorBookmark;
import mx.collections.ItemResponder;
import mx.collections.errors.ChildItemPendingError;
import mx.collections.errors.ItemPendingError;
import mx.controls.listClasses.AdvancedListBase;
import mx.controls.listClasses.AdvancedListBaseContentHolder;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseSeekPending;
import mx.controls.listClasses.ListRowInfo;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IFontContextComponent;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.ListEvent;
import mx.events.ScrollEvent;
import mx.events.ScrollEventDetail;
import mx.events.ScrollEventDirection;
import mx.events.TweenEvent;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="maxHorizontalScrollPosition", kind="property")]
[Exclude(name="maxVerticalScrollPosition", kind="property")]


//--------------------------------------
//  Other metadata
//--------------------------------------


/**
 *  @private
 *
 *  Please read the terms of the Charts EULA.
 */
[RequiresLicense(id="mx.fbpro", handler="mx.controls.advancedDataGridClasses.DMVLicenseHandler")]


/**
 *  The AdvancedDataGridBase class is the base class for controls
 *  that display lists of items in multiple columns,
 *  such as the AdvancedDataGrid and OLAPDataGrid controls.
 *  It is not used directly in applications.
 *  
 *  @mxml
 *  
 *  <p>The AdvancedDataGridBase class inherits all the properties of its parent classes
 *  and adds the following properties:</p>
 *  
 *  <pre>
 *  &lt;mx:<i>tagname</i>
 *    headerHeight="depends on styles and header renderer"
 *    headerWordWrap="false|true"
 *    selectionMode="SINGLE_ROW"
 *    showHeaders="true|false"
 *    sortItemRenderer="null"
 *    styleFunction="null"
 *  /&gt;
 *  </pre>
 */
public class AdvancedDataGridBase extends AdvancedListBase implements IFontContextComponent
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------

    // 'Cell Selection' constants
    /**
     *  Constant definition for the <code>selectionMode</code> property.
     *  No selection is allowed in the control, 
     *  and the <code>selectedCells</code> property is null. 
     *
     *  @see mx.controls.AdvancedDataGrid#selectedCells
     */
    public static const NONE:String           = "none";
    /**
     *  Constant definition for the <code>selectionMode</code> property
     *  to allow the selection of a single row.
     *  Click any cell in the row to select the row.
     *
     *  @see mx.controls.AdvancedDataGrid#selectedCells
     */
    public static const SINGLE_ROW:String     = "singleRow";
    /**
     *  Constant definition for the <code>selectionMode</code> property
     *  to allow the selection of multiple rows.
     *  Click any cell in the row to select the row.
     *  While holding down the Control key, click any cell in another row to select 
     *  the row for discontiguous selection. 
     *  While holding down the Shift key, click any cell in another row to select 
     *  multiple, contiguous rows.
     *
     *  @see mx.controls.AdvancedDataGrid#selectedCells
     */
    public static const MULTIPLE_ROWS:String  = "multipleRows";
    /**
     *  Constant definition for the <code>selectionMode</code> property
     *  to allow the selection of a single cell.
     *  Click any cell to select the cell.
     *
     *  @see mx.controls.AdvancedDataGrid#selectedCells
     */
    public static const SINGLE_CELL:String    = "singleCell";
    /**
     *  Constant definition for the <code>selectionMode</code> property
     *  to allow the selection of multiple cells.
     *  Click any cell in the row to select the cell.
     *  While holding down the Control key, click any cell to select 
     *  the cell for discontiguous selection. 
     *  While holding down the Shift key, click any cell to select 
     *  multiple, contiguous cells.
     *
     *  @see mx.controls.AdvancedDataGrid#selectedCells
     */
    public static const MULTIPLE_CELLS:String = "multipleCells";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     */
    public function AdvancedDataGridBase()
    {
        super();

        try
        {
            var licenseHandlerClass:Class = Class(getDefinitionByName(
                                                      "mx.controls.advancedDataGridClasses.DMVLicenseHandler"));
            if (licenseHandlerClass != null)
                licenseHandlerClass["displayWatermark"](this);
        }
        catch(e:Error)
        {
        }


        listType = "vertical";

        lockedRowCount = 0;
        defaultRowCount = 7;    // default number of rows is 7
        columnMap = {};
        freeItemRenderersTable = new Dictionary(false);
        itemRendererToFactoryMap = new Dictionary(false);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  A map of item renderers to columns.
     *  Like <code>AdvancedListBase.rowMap</code>, this property contains 
     *  a hash map of item renderers and the columns they belong to.
     *  Item renderers are indexed by their DisplayObject name.
     *
     *  @see mx.controls.listClasses.ListBase#rowMap
     */
    protected var columnMap:Object;

    /**
     *  @private
     *  A per-factory table of unused item renderers. 
     *  Most list classes recycle item renderers that they have already created 
     *  as they scroll off screen. 
     *  The recycled renderers are stored here.
     *  The table is a Dictionary where the entries are Arrays indexed
     *  by the actual factory used to create them (not the column's dataField or other
     *  properties), and each array is a stack of currently unused renderers
     */
    protected var freeItemRenderersTable:Dictionary;
    
    /**
     *  @private
     *  Denotes if the child item is pending
     */
    protected var itemPending:Boolean;

    /**
     *  The set of visible columns.
     */
    mx_internal var visibleColumns:Array;

    /**
     *  The set sub content area holding the scrollable list items.
     */
    mx_internal var listSubContent:AdvancedListBaseContentHolder;

    /**
     *  Flag specifying that the set of visible columns and/or their sizes needs to
     *  be recomputed.
     */
    mx_internal var columnsInvalid:Boolean = true;

    // these three keep track of the key selection that caused
    // the page fault
    /**
     *  @private
     */
    protected var bShiftKey:Boolean = false;
    /**
     *  @private
     */
    protected var bCtrlKey:Boolean = false;
    /**
     *  @private
     */
    protected var lastKey:uint = 0;

    /**
     *  @private
     */
    protected var bSelectItem:Boolean = false;

    // these variable keep track of the current item been drawn
    /**
     *  The height, in pixels, of the current row.
     */
    protected var currentRowHeight:Number;

    /**
     *  Contains the index of the column for which a renderer is currently being created.
     */
    protected var currentColNum:int;

    /**
     *  Contains the index of the row for which a renderer is currently being created.
     */
    protected var currentRowNum:int;

    /**
     *  Contains the top position of the renderer that is currently being created.
     */
    protected var currentItemTop:Number;

    /**
     *  @private
     *  An Array of AdvancedDataGridHeaderRenderer instances that 
     *  define the header item renderers for the control.
     *
     *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer
     */
    public var headerItems:Array = [];

    /**
     *  An Array of ListRowInfo instances that cache header height and 
     *  other information for the headers in the <code>headerItems</code> Array.
     */
    protected var headerRowInfo:Array = [];

    /**
     *  Maps item renderers to the Factory instacne from which they have been created.
     * 
     */
    protected var itemRendererToFactoryMap:Dictionary;

    /**
     *  @private
     *  Array of Columns
     */
    protected var _columns:Array; /* of AdvancedDataGridColumns */

    /**
     *  An Array of AdvancedDataGridHeaderInfo instances for all columns
     *  in the control.
     *
     *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderInfo
     */
    protected var headerInfos:Array;

    /**
     *  An Array of AdvancedDataGridHeaderRenderer instances that 
     *  define the header item renderers for the displayable columns.
     *
     *  @see mx.controls.advancedDataGridClasses.AdvancedDataGridHeaderRenderer
     */
    protected var visibleHeaderInfos:Array;


    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  fontContext
    //----------------------------------
    
    /**
    * @inheritDoc 
    */
    public function get fontContext():IFlexModuleFactory
    {
        return moduleFactory;
    }

	/**
    * @private
    */
    public function set fontContext(moduleFactory:IFlexModuleFactory):void
    {
        this.moduleFactory = moduleFactory;
    }
    
    /**
     *  @private
     */
    private var lockedRowCountResetShowHeaders:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------
    
    // 'Cell Selection' properties
    //--------------------------------------------------------------------------
    // selectionMode
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    protected var _selectionMode:String = SINGLE_ROW;

    [Inspectable(category="General",
        enumeration="none,singleRow,multipleRows,singleCell,multipleCells",
        defaultValue="singleRow")]
    /**
     *  The selection mode of the control. Possible values are:
     *  <code>MULTIPLE_CELLS</code>, <code>MULTIPLE_ROWS</code>, <code>NONE</code>, 
     *  <code>SINGLE_CELL</code>, and <code>SINGLE_ROW</code>.
     *  Changing the value of this property 
     *  sets the <code>selectedCells</code> property to null.
     *
     *  <p>You must set the <code>allowMultipleSelection</code> property to <code>true</code> 
     *  to select more than one item in the control at the same time.</p> 
     *
     *  <p>Information about the selected cells is written to the <code>selectedCells</code> property.</p>
     *
     *  @default SINGLE_ROW
     */
    public function get selectionMode():String
    {
        return _selectionMode;
    }

    public function set selectionMode(value:String):void
    {
        setSelectionMode(value);
        itemsSizeChanged = true;
        invalidateDisplayList();
    }

    /**
     *  If there have been values set using selectedCells setter, but they have not
     *  yet been processed because they have never come into display.
     *
     *  @private
     */
    protected var cellsWaitingToBeDisplayed:Boolean = true;

    /**
     *  The list of selectedCells never displayed till now.
     *  Each cell is an Object with attributes rowIndex and columnIndex referring to
     *  their respective absolute values for the cell.
     *
     *  @private
     */
    protected var pendingCellSelection:ArrayCollection = new ArrayCollection([]);

    //----------------------------------
    //  headerHeight
    //----------------------------------

    /**
     *  @private
     *  Storage for the headerHeight property.
     */
    mx_internal var _headerHeight:Number = 22;

    /**
     *  @private
     */
    mx_internal var _explicitHeaderHeight:Boolean;

    [Bindable("resize")]
    [Inspectable(category="General", defaultValue="22")]

    /**
     *  The height of the header cell of the column, in pixels.
     *  If set explicitly, that height will be used for all of
     *  the headers.  If not set explicitly, 
     *  the height will based on style settings and the header
     *  renderer.  
     */
    public function get headerHeight():Number
    {
        return _headerHeight;
    }

    /**
     *  @private
     */
    public function set headerHeight(value:Number):void
    {
        _headerHeight = value;
        _explicitHeaderHeight = true;
        itemsSizeChanged = true;

        invalidateDisplayList();
    }
    
    //----------------------------------
    //  headerWordWrap
    //----------------------------------

    /**
     *  @private
     *  Storage for the headerWordWrap property.
     */
    private var _headerWordWrap:Boolean;

    [Inspectable(category="General")]

    /**
     *  If <code>true</code>, specifies that text in the header is
     *  wrapped if it does not fit on one line.
     *  
     *  If the <code>headerWordWrap</code> property is set in AdvancedDataGridColumn,
     *  this property will not have any effect.
     *
     *  @default false
     */
    public function get headerWordWrap():Boolean
    {
        return _headerWordWrap;
    }

    /**
     *  @private
     */
    public function set headerWordWrap(value:Boolean):void
    {        
        if (value == _headerWordWrap)
            return;

        _headerWordWrap = value;

        itemsSizeChanged = true;

        invalidateDisplayList();

        dispatchEvent(new Event("headerWordWrapChanged"));
    }

    //----------------------------------
    //  showHeaders
    //----------------------------------

    /**
     *  @private
     *  Storage for the showHeaders property.
     */
    private var _showHeaders:Boolean = true;

    [Bindable("showHeadersChanged")]
    [Inspectable(category="General", defaultValue="true")]

    /**
     *  A flag that indicates whether the control should show
     *  column headers.
     *  If <code>true</code>, the control shows column headers. 
     *
     *  @default true
     */
    public function get showHeaders():Boolean
    {
        return _showHeaders;
    }

    /**
     *  @private
     */
    public function set showHeaders(value:Boolean):void
    {
        _showHeaders = value;
        itemsSizeChanged = true;

        invalidateDisplayList();

        dispatchEvent(new Event("showHeadersChanged"));
    }

    /**
     *  @private
     *  headers are not renderered if showHeaders = false
     *  or headerheight = 0, so this test is whether row0 is
     *  a header or not.
     */
    mx_internal function get headerVisible():Boolean
    {
        return showHeaders && (headerHeight > 0);
    }

    //----------------------------------
    //  headerRenderer
    //----------------------------------

    private var _headerRenderer:IFactory;

    [Inspectable(category="Data")]
    [Bindable("headerRendererChanged")]

    /**
     *  The header renderer used to display the header rows of the column.
     *
     *  @default AdvancedDataGridHeaderRenderer
     */
    public function get headerRenderer():IFactory
    {
        return _headerRenderer;
    }

    /**
     *  @private
     */
    public function set headerRenderer(value:IFactory):void
    {
        _headerRenderer = value;

        invalidateSize();
        invalidateDisplayList();

        itemsSizeChanged = true;
        rendererChanged = true;

        dispatchEvent(new Event("headerRendererChanged"));
    }

    //----------------------------------
    //  sortItemRenderer
    //----------------------------------

    /**
     *  @private
     *  Storage for the sortItemRenderer property.
     */
    private var _sortItemRenderer:IFactory;

    [Inspectable]
    [Bindable("sortItemRendererChanged")]

    /**
     *  The sort item renderer to be used to display the sort icon in the
     *  column header.
     */
    public function get sortItemRenderer():IFactory
    {
        return _sortItemRenderer;
    }

    /**
     *  @private
     */
    public function set sortItemRenderer(value:IFactory):void
    {
        _sortItemRenderer = value;

        itemsSizeChanged = true;
        rendererChanged = true;

        invalidateSize();
        invalidateDisplayList();

        dispatchEvent(new Event("sortItemRendererChanged"));
    }

    //----------------------------------
    //  styleFunction
    //----------------------------------

    /**
     *  @private
     */
    private var _styleFunction:Function;

    /**
     *  A callback function called while rendering each cell.
     *
     *  The signature of the callback function is:
     *
     *   <pre>function myStyleFunction(data:Object, column:AdvancedDataGridColumn):Object</pre>
     *
     *   <p>where <code>data</code> is the data object associated with the item renderer being rendered, 
     *   and <code>column</code> is the AdvancedDataGridColumn instance with which the item renderer is associated.</p>
     *
     *  <p>The return value should be a Object with styles as properties.
     *  For example: <code>{ color:0xFF0000, fontWeight:"bold" }</code>.</p>
     */
    public function get styleFunction():Function
    {
        return _styleFunction;
    }

    public function set styleFunction(value:Function):void
    {
        _styleFunction = value;

        invalidateDisplayList();
    }

    /**
     *  Creates the column headers.
     *  After creating the headers, this method updates the <code>currentItemTop</code> property 
     *  with the height of the header area. 
     *  It also updates the <code>headerHeight</code> property 
     *  if <code>headerHeight</code> has not been specified explicitly.
     *
     *  @param left The x coordinate of the header renderer.
     *
     *  @param top The y coordinate of the header renderer.
     */
    protected function createHeaders(left:Number, top:Number):void
    {
        var xx:Number;
        var ww:Number;
        var hh:Number;
        var item:IListItemRenderer;
        var extraItem:DisplayObject;
        var c:AdvancedDataGridColumn;
        var rowData:AdvancedDataGridListData;
        var i:int;
        var maxHeaderHeight:Number = 0;
        if(!headerItems[0] || !headerItems[0][0] || (top < headerItems[0][0].y + headerItems[0][0].height)) 
        {
            xx = left;
            hh = 0;
            currentRowNum = 0;
            currentColNum = 0;  // visible columns compensate for firstCol offset
            
            //Clear the dangling pointers of headerItems from headerInfo structures
            for( i = 0; i < headerInfos.length; i++)
                headerInfos[i].headerItem = null;

            var optimumColumns:Array = getOptimumColumns();
            while (/* xx < right && */ currentColNum < optimumColumns.length)
            {
                c = optimumColumns[currentColNum];
                if (!headerItems[currentRowNum])
                    headerItems[currentRowNum] = [];
                else if (headerItems[currentRowNum][currentColNum])
                {
                    // add header to the free item renderers table
                    addHeaderToFreeItemRenderers(headerItems[currentRowNum][currentColNum], c);
                }
                // get the header renderer
                item = getHeaderRenderer(c);
                // passing rowNum as -1 for headers
                rowData = AdvancedDataGridListData(makeListData(c, uid, -1, c.colNum, c));
                rowMap[item.name] = rowData;
                if (item is IDropInListItemRenderer)
                    IDropInListItemRenderer(item).listData = rowData;
                item.data = c;
                item.styleName = c;
                headerItems[currentRowNum][currentColNum] = item;
                headerInfos[c.colNum].headerItem = item;
                // set prefW so we can compute prefH
                item.explicitWidth = ww = c.width;
                UIComponentGlobals.layoutManager.validateClient(item, true);
                // but size it regardless of what prefW is
                currentRowHeight = item.getExplicitOrMeasuredHeight();
                item.setActualSize(ww, _explicitHeaderHeight ?
                                   _headerHeight - cachedPaddingTop - cachedPaddingBottom : currentRowHeight);
                item.move(xx, currentItemTop + cachedPaddingTop);
                xx += ww;
                hh = Math.ceil(Math.max(hh, _explicitHeaderHeight ?
                                        _headerHeight : currentRowHeight + cachedPaddingBottom + cachedPaddingTop));
                maxHeaderHeight = Math.max(maxHeaderHeight, _explicitHeaderHeight ?
                                           _headerHeight - cachedPaddingTop - cachedPaddingBottom : currentRowHeight);
                item.visible = headerVisible;
                currentColNum++;
            }
            if (headerItems[currentRowNum])
            {
                // expand all headers to be of maximum height
                for (i = 0; i < headerItems[currentRowNum].length; i++)
                {
                    headerItems[currentRowNum][i].setActualSize(headerItems[currentRowNum][i].width, maxHeaderHeight);
                    
                    // invalide the header item.
                    // InvalidateDisplayList of the header will not be called if the width/height
                    // of the header has not changed.
                    // We have to call it explicitly.
                    var headerItem:IInvalidating = headerItems[currentRowNum][i] as IInvalidating;
                    
                    if (headerItem)
                    	IInvalidating(headerItem).invalidateDisplayList();
                    
                }

                while (headerItems[currentRowNum].length > currentColNum)
                {
                    // remove extra columns
                    extraItem = headerItems[currentRowNum].pop();
                    extraItem.parent.removeChild(extraItem);
                }
            }
            headerRowInfo[currentRowNum] = new ListRowInfo(currentItemTop, hh, uid);
            if (headerVisible)
                currentItemTop += item ? hh : 0;
            if (!_explicitHeaderHeight)
                _headerHeight = item ? hh : 0;

        }
    }
    
    /**
     *  Creates the locked rows, if necessary. 
     *
     *  @param left The x coordinate of the upper-left corner of the header renderer.
     *
     *  @param top The y coordinate of the upper-left corner of the header renderer.
     *
     *  @param right The x coordinate of the lower-right corner of the header renderer.
     *
     *  @param bottom The y coordinate of the lower-right corner of the header renderer.
     */
    protected function createLockedRows(left:Number, top:Number, right:Number, bottom:Number):void
    {
        var more:Boolean = true;
        var numLocked:int = lockedRowCount;
        var i:int;
        var rowsMade:int = 0;
        if(lockedRowCount > 0 && (!listItems[lockedRowCount-1] || !listItems[lockedRowCount-1][0] || (top < listItems[lockedRowCount-1][0].y + listItems[lockedRowCount-1][0].height)))
        {
            currentRowNum = 0;
            var bookmark:CursorBookmark;
            if (numLocked && iterator)
            {
                bookmark = iterator.bookmark;
                try 
                {
                    iterator.seek(CursorBookmark.FIRST);
                }
                catch (e:ItemPendingError)
                {
                    lastSeekPending = new ListBaseSeekPending(CursorBookmark.FIRST, 0);
                    e.addResponder(new ItemResponder(seekPendingResultHandler, seekPendingFailureHandler, 
                                                     lastSeekPending));
                    iteratorValid = false;
                }

            }
            more = (iterator != null && !iterator.afterLast && iteratorValid);
            for (i = 0; i < numLocked; i++)
            {
                createRow(left,top,right,bottom,more);
                more = moveIterator(more);
                ++rowsMade;
            }

            if (bookmark)
            {
                try 
                {
                    iterator.seek(bookmark, numLocked);
                }
                catch (e:ItemPendingError)
                {
                    lastSeekPending = new ListBaseSeekPending(CursorBookmark.CURRENT, 0)
                        e.addResponder(new ItemResponder(seekPendingResultHandler, seekPendingFailureHandler, 
                                                         lastSeekPending));
                    iteratorValid = false;
                }
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */
    override protected function makeRowsAndColumns(left:Number, top:Number,
                                                   right:Number, bottom:Number,
                                                   firstCol:int, firstRow:int,
                                                   byCount:Boolean = false, rowsNeeded:uint = 0):Point
    {
        // ignoring padding left
        // Use paddingLeft for each item
        /* if(left == 0)
           left = getStyle("paddingLeft"); */

        var xx:Number;
        var ww:Number;
        var hh:Number;

        var rowData:AdvancedDataGridListData;

        var i:int;

        currentColNum = lockedColumnCount;
        currentRowNum = lockedRowCount;

        var rowsMade:int = 0;

        var item:IListItemRenderer;
        var extraItem:DisplayObject;

        // bail if we have no columns
        if (!visibleColumns || visibleColumns.length == 0)
        {
            // remove the header items and list items
            purgeHeaderRenderers();
            purgeItemRenderers();
            visibleData = {};
            return new Point(0,0);
        }

        invalidateSizeFlag = true;

        var uid:String;
        var c:AdvancedDataGridColumn;
        var more:Boolean = true;

        currentItemTop = top;
        // if we have headers or other locked items and either haven't created the
        // items for those items or we're redrawing the items above the locked region...
        if ( firstRow <= lockedRowCount)
        {
            //If needed
            createHeaders(left, top);
            //If needed
            createLockedRows(left, top, right, bottom);
        }
        else
        {
            currentRowNum = firstRow;
        }
        more = (iterator != null && !iterator.afterLast && iteratorValid);
        while ((!byCount && currentItemTop < bottom) || (byCount && rowsNeeded > 0))
        {
            if (byCount)
                rowsNeeded--;

            createRow(left,top,right,bottom,more);

            more = moveIterator(more);
            ++rowsMade;
        }

        // byCount means we're making rows and wont get all the way to the bottom
        // so we skip this cleanup pass
        if (!byCount)
        {
            // delete extra rows
            while (currentRowNum < listItems.length)
            {
                var rr:Array = listItems.pop();
                rowInfo.pop();
                while (rr.length)
                {
                    item = rr.pop();
                    addToFreeItemRenderers(item);
                }
            }
        }

        invalidateSizeFlag = false;

        return new Point(currentColNum, rowsMade);
    }

    /**
     *  @private
     */
    override protected function purgeItemRenderers():void
    {
        // To Do
        rendererChanged = false;
        var item:IListItemRenderer;
        while (listItems.length)
        {
            currentRowNum = listItems.length - 1;
            while (listItems[currentRowNum].length)
            {
                // remove extra columns
                item = listItems[currentRowNum].pop();
                item.parent.removeChild(DisplayObject(item));
            }
            listItems.pop();
        }
        rowMap = {};
        rowInfo = [];
    }
    
    /**
     *  @private
     */
    protected function purgeHeaderRenderers():void
    {
        var item:IListItemRenderer;
        while(headerItems.length)
        {
            var headerRow:Array = headerItems.pop();
            while(headerRow.length)
            {
                item = IListItemRenderer(headerRow.pop());
                addHeaderToFreeItemRenderers(item, item.data as AdvancedDataGridColumn);
            }
        }
    }
    
    /**
     *  @private
     */
    override protected function drawItem(item:IListItemRenderer,
                                         selected:Boolean = false,
                                         highlighted:Boolean = false,
                                         caret:Boolean = false,
                                         transition:Boolean = false):void
    {
        if (!item)
            return;
        if (rowMap[item.name] == null)
            return;

        super.drawItem(item, selected, highlighted, caret, transition);

        var rowIndex:int = rowMap[item.name].rowIndex;
        var optimumColumns:Array = getOptimumColumns();
        var n:int = optimumColumns.length;
        for (var columnIndex:int = 0; columnIndex < n; columnIndex++)
        {
            var r:IListItemRenderer = listItems[rowIndex][columnIndex];
            updateDisplayOfItemRenderer(r);
        }
    }

    /**
     *  @private
     */
    protected function updateDisplayOfItemRenderer(r:IListItemRenderer):void
    {
        if (r is IInvalidating)
        {
            var ui:IInvalidating = IInvalidating(r);
            ui.invalidateDisplayList();
            ui.validateNow();
        }
    }

    /**
     *  Sets the cell defined by <code>uid</code> to use the item renderer
     *  specified by <code>item</code>.
     *
     *  @param uid The UID of the cell.
     *
     *  @param item The item renderer to use for the cell.
     */
    protected function setVisibleDataItem(uid:String, item:IListItemRenderer):void
    {
        if (uid && currentColNum == 0)
            visibleData[uid] = item;
    }

    /**
     *  Draws the item renderer corresponding to the specified UID.
     *
     *  @param uid The UID of the selected cell.
     *
     *  @param selected Set to <code>true</code> to draw the cell as selected.
     *
     *  @param highlighted Set to <code>true</code> to draw the cell as highlighted.
     *
     *  @param caret Set to <code>true</code> to draw the cell with a caret.
     *
     *  @param Set to <code>true</code> to animate the change to the cell's appearance.
     */
    protected function drawVisibleItem(uid:String,
                                       selected:Boolean = false,
                                       highlighted:Boolean = false,
                                       caret:Boolean = false,
                                       transition:Boolean = false):void
    {
        if (isRowSelectionMode())
            if (visibleData[uid])
                drawItem(visibleData[uid], selected, highlighted, caret);
    }

    /**
     *  @private
     *
     *  @return The newly selected item or <code>null</code> if the selection
     *  has not changed.
     */
    override protected function moveSelectionVertically(
        code:uint, shiftKey:Boolean,
        ctrlKey:Boolean):void
    {
        var newVerticalScrollPosition:Number;
        var listItem:IListItemRenderer;
        var uid:String;
        var len:int;

        showCaret = true;

        var rowCount:int = listItems.length;

        if (rowCount == 0)
            return;

        var partialRow:int = 0;
        if (rowInfo[rowCount - 1].y +
            rowInfo[rowCount - 1].height > listContent.height)
        {
            partialRow++;
        }

        var bUpdateVerticalScrollPosition:Boolean = false;
        bSelectItem = false;

        switch (code)
        {
        case Keyboard.UP:
        {
            if (caretIndex > 0)
            {
                caretIndex--;
                bUpdateVerticalScrollPosition = true;
                bSelectItem = true;
            }
            break;
        }

        case Keyboard.DOWN:
        {
            if (caretIndex < collection.length - 1)
            {
                caretIndex++;
                bUpdateVerticalScrollPosition = true;
                bSelectItem = true;
            }
            else if ((caretIndex == collection.length - 1) && partialRow)
            {
                if (verticalScrollPosition < maxVerticalScrollPosition)
                    newVerticalScrollPosition = verticalScrollPosition + 1;
            }
            break;
        }

        case Keyboard.PAGE_UP:
        {
            if (caretIndex < lockedRowCount)
            {
                newVerticalScrollPosition = 0;
                caretIndex = 0;
            }
            // if the caret is on-screen, but not at the top row
            // just move the caret to the top row
            else if (caretIndex > verticalScrollPosition + lockedRowCount &&
                     caretIndex < verticalScrollPosition + rowCount)
            {
                caretIndex = verticalScrollPosition + lockedRowCount;
            }
            else
            {
                // paging up is really hard because we don't know how many
                // rows to move because of variable row height.  We would have
                // to double-buffer a previous screen in order to get this exact
                // so we just guess for now based on current rowCount
                caretIndex = Math.max(caretIndex - rowCount + lockedRowCount, 0);
                newVerticalScrollPosition = Math.max(caretIndex - lockedRowCount,0)
                    }
            bSelectItem = true;

            break;
        }

        case Keyboard.PAGE_DOWN:
        {
            if (caretIndex < lockedRowCount)
            {
                newVerticalScrollPosition = 0;
            }
            // if the caret is on-screen, but not at the bottom row
            // just move the caret to the bottom row (not partial row)
            else if (caretIndex >= verticalScrollPosition + lockedRowCount &&
                     caretIndex < verticalScrollPosition + rowCount - partialRow - 1)
            {
                caretIndex = Math.min(verticalScrollPosition + listItems.length
                                      + lockedRowCount,
                                      collection.length - 1);
            }
            else if (lockedRowCount >= rowCount - partialRow - 1)
            {
                newVerticalScrollPosition = Math.min(verticalScrollPosition + 1, maxVerticalScrollPosition);
            }
            else
            {
                newVerticalScrollPosition = Math.min(caretIndex - lockedRowCount, maxVerticalScrollPosition);
            }
            bSelectItem = true;
            break;
        }

        case Keyboard.HOME:
        {
            if (caretIndex > 0)
            {
                caretIndex = 0;
                newVerticalScrollPosition = 0;
                bSelectItem = true;
            }
            break;
        }

        case Keyboard.END:
        {
            if (caretIndex < collection.length - 1)
            {
                caretIndex = collection.length - 1;
                newVerticalScrollPosition = maxVerticalScrollPosition;
                bSelectItem = true;
            }
            break;
        }

        case Keyboard.SPACE:
        {
            bUpdateVerticalScrollPosition = true;
            bSelectItem = true;
            break;
        }
        }

        if (bUpdateVerticalScrollPosition)
        {
            if (caretIndex < lockedRowCount)
            {
                newVerticalScrollPosition = 0;
            }
            else if (caretIndex < verticalScrollPosition + lockedRowCount)
            {
                newVerticalScrollPosition = caretIndex - lockedRowCount;
            }
            else if (caretIndex >= verticalScrollPosition + rowCount - partialRow)
            {
                newVerticalScrollPosition = Math.min(maxVerticalScrollPosition,
                                                     caretIndex - rowCount + partialRow + 1);
            }
        }

        if (!isNaN(newVerticalScrollPosition))
        {
            if (verticalScrollPosition != newVerticalScrollPosition)
            {
                var se:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
                se.detail = ScrollEventDetail.THUMB_POSITION;
                se.direction = ScrollEventDirection.VERTICAL;
                se.delta = newVerticalScrollPosition - verticalScrollPosition;
                se.position = newVerticalScrollPosition;

                verticalScrollPosition = newVerticalScrollPosition;

                dispatchEvent(se);
            }
            // bail if we page faulted
            if (!iteratorValid) 
            {
                keySelectionPending = true;
                return;
            }
        }

        bShiftKey = shiftKey;
        bCtrlKey = ctrlKey;
        lastKey = code;

        finishKeySelection();
    }

    /**
     *  @private
     */
    override protected function finishKeySelection():void
    {
        var uid:String;
        var rowCount:int = listItems.length;
        var partialRow:int = (rowInfo[rowCount-1].y + rowInfo[rowCount-1].height >
                              listContent.height) ? 1 : 0;

        if (lastKey == Keyboard.PAGE_DOWN)
        {
            if (lockedRowCount >= rowCount - partialRow - 1)
                caretIndex = Math.min(verticalScrollPosition + lockedRowCount,
                                      collection.length - 1);
            // set caret to last full row of new screen
            else
                caretIndex = Math.min(verticalScrollPosition + rowCount - partialRow - 1,
                                      collection.length - 1);
        }

        var listItem:IListItemRenderer;
        var bSelChanged:Boolean = false;

        if (bSelectItem && caretIndex - verticalScrollPosition >= 0)
        {
            if (caretIndex - verticalScrollPosition > listItems.length - 1)
                caretIndex = listItems.length - 1 + verticalScrollPosition;

            listItem = listItems[caretIndex - verticalScrollPosition][0];
            if (listItem)
            {
                uid = itemToUID(listItem.data);
                listItem = visibleData[uid];
                if (listItem)
                {
                    if (lastKey == Keyboard.SPACE)
                    {
                        bSelChanged = selectItem(listItem, bShiftKey, bCtrlKey);
                    }
                    else
                    {
                        if (!bCtrlKey)
                        {
                            selectItem(listItem, bShiftKey, bCtrlKey);
                            bSelChanged = true;
                        }
                        if (bCtrlKey)
                        {
                            drawItem(listItem, selectedData[uid] != null, uid == highlightUID, true);
                        }
                    }
                }
            }
        }

        if (bSelChanged)
        {
            var evt:ListEvent = new ListEvent(ListEvent.CHANGE);
            evt.itemRenderer = listItem;
            var pt:Point = itemRendererToIndices(listItem);
            if (pt)
            {
                evt.rowIndex = pt.y;
                evt.columnIndex = pt.x;
            }
            dispatchEvent(evt);
        }
    }

    /**
     *  @private
     */
    protected function addHeaderToFreeItemRenderers(item:IListItemRenderer, c:AdvancedDataGridColumn):void
    {       
        DisplayObject(item).visible = false;

        var factory:IFactory = itemRendererToFactoryMap[item];
        if (!freeItemRenderersTable[c])
            freeItemRenderersTable[c] = new Dictionary(false);
        if (!freeItemRenderersTable[c][factory])
            freeItemRenderersTable[c][factory] = [];
        freeItemRenderersTable[c][factory].push(item);
    }

    /**
     *  @private
     */
    override protected function addToFreeItemRenderers(item:IListItemRenderer):void
    {       
        DisplayObject(item).visible = false;

        delete rowMap[item.name];
        
        // Only delete from visibleData if we are freeing the renderer for
        // the first visible column
        var UID:String = itemToUID(item.data);
        if (visibleData[UID] == item)
            delete visibleData[UID];

        if (columnMap[item.name])
        {
            var c:AdvancedDataGridColumn = columnMap[item.name];
            var factory:IFactory = itemRendererToFactoryMap[item];
            if (!freeItemRenderersTable[c])
                freeItemRenderersTable[c] = new Dictionary(false);
            if (!freeItemRenderersTable[c][factory])
                freeItemRenderersTable[c][factory] = [];
            freeItemRenderersTable[c][factory].push(item);
            delete columnMap[item.name];
        }
        // Remove the item if it is not present in the column map.
        // it cant be recycled
        // If we are coming here, renderers are not getting recycled properly.
        else
            item.parent.removeChild(DisplayObject(item));
    }

    /**
     *  @private
     */
    override protected function adjustListContent(unscaledWidth:Number = -1,
                                       unscaledHeight:Number = -1):void
    {
        super.adjustListContent(unscaledWidth, unscaledHeight);
        listSubContent.setActualSize(listContent.width, listContent.height);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------

    /**
     *  Creates a new AdvancedDataGridListData instance and populates the fields based on
     *  the input data provider item. 
     *  
     *  @param data The data provider item used to populate the ListData.
     * 
     *  @param uid The UID for the item.
     * 
     *  @param rowNum The index of the item in the data provider.
     * 
     *  @param columnNum The column index associated with this item. 
     * 
     *  @param column The column associated with this item.
     *  
     *  @return A newly constructed AdvancedDataGridListData object.
     */
    protected function makeListData(data:Object, uid:String, 
                                    rowNum:int, columnNum:int, column:AdvancedDataGridColumn):BaseListData
    {
        if (data is AdvancedDataGridColumn)
        {
            return new AdvancedDataGridListData((column.headerText != null) ? column.headerText : column.dataField, 
                                                column.dataField, columnNum, uid, this, rowNum);
        }
        else
        { 
            var label:String = column.itemToLabel(data);
            return new AdvancedDataGridListData(label, column.dataField, 
                                                columnNum, uid, this, rowNum);
        }
    }

    /**
     *  @private
     *  This grid just returns the column size,
     *  but could handle column spanning.
     */
    mx_internal function getWidthOfItem(item:IListItemRenderer,
                                        col:AdvancedDataGridColumn, visibleColumnIndex:int):Number
    {
        return col.width;
    }

    /**
     *  Calculates the row height of columns in a row.
     *  If <code>skipVisible</code> is <code>true</code> 
     *  the AdvancedDataGridBase already knows the height of
     *  the renderers for the column that do fit in the display area,
     *  so this method only needs to calculate for the item renderers
     *  that would exist if other columns in that row were in the
     *  display area.  This is needed so that if the user scrolls
     *  horizontally, the height of the row does not adjust as different
     *  columns appear and disappear.
     *
     *  @param data The data provider item for the row.
     *
     *  @param hh The current height of the row.
     *
     *  @param skipVisible If <code>true</code>, no need to measure item
     *  renderers in visible columns.
     *
     *  @return The row height, in pixels.
     */
    protected function calculateRowHeight(data:Object, hh:Number, skipVisible:Boolean = false):Number
    {
        return NaN;
    }

    /**
     *  Get the appropriate renderer for a column, using the default renderer if none specified
     */
    mx_internal function columnItemRenderer(c:AdvancedDataGridColumn, forHeader:Boolean, itemData:Object):IListItemRenderer
    {
        var factory:IFactory = columnItemRendererFactory(c,forHeader,itemData);
        var renderer:IListItemRenderer = factory.newInstance();

        itemRendererToFactoryMap[renderer] = factory;

        renderer.owner = this;
        return renderer;
    }

    /**
     *  Get the appropriate renderer factory for a column, 
     *  using the default renderer if none specified
     */
    mx_internal function columnItemRendererFactory(c:AdvancedDataGridColumn, forHeader:Boolean, itemData:Object):IFactory
    {
        var factory:IFactory;
        if (forHeader)
        {
            if (c.headerRenderer)
                factory = c.headerRenderer;
            else
                factory = headerRenderer;
        }
        else
        {
            if (c.itemRenderer)
            {
                factory = c.itemRenderer;
            }
        }
        if (!factory)
        {   
            factory = itemRenderer;
        }

        return factory;
    }

    /**
     *  Get the headerWordWrap for a column, using the default wordWrap if none specified
     */
    mx_internal function columnHeaderWordWrap(c:AdvancedDataGridColumn):Boolean
    {
        if (c.headerWordWrap == true)
            return true;
        if (c.headerWordWrap == false)
            return false;

        return headerWordWrap;
    }

    /**
     *  Get the wordWrap for a column, using the default wordWrap if none specified
     */
    mx_internal function columnWordWrap(c:AdvancedDataGridColumn):Boolean
    {
        if (c.wordWrap == true)
            return true;
        if (c.wordWrap == false)
            return false;

        return wordWrap;
    }

    /**
     *  @private
     */
    override protected function drawHighlightIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
        if (isRowSelectionMode())
            width = unscaledWidth - viewMetrics.left - viewMetrics.right;

        super.drawHighlightIndicator(indicator, x, y, width, height, color, itemRenderer);
    }

    /**
     *  @private
     */
    override protected function drawCaretIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
        if (isRowSelectionMode())
            width = unscaledWidth - viewMetrics.left - viewMetrics.right;

        super.drawCaretIndicator(indicator, x, y, width, height, color, itemRenderer);
    }

    /**
     *  @private
     */
    override protected function drawSelectionIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
    {
        if (isRowSelectionMode())
            width = unscaledWidth - viewMetrics.left - viewMetrics.right;

        super.drawSelectionIndicator(indicator, x, y, width, height, color, itemRenderer);
    }

    /**
     *  @private
     */
    override mx_internal function mouseEventToItemRendererOrEditor(event:MouseEvent):IListItemRenderer
    {
        var target:DisplayObject = DisplayObject(event.target);

        if (target == listContent)
        {
            var pt:Point = new Point(event.stageX, event.stageY);
            pt = listContent.globalToLocal(pt);
            // if ADG is empty then length of rowInfo is 0
            var yy:Number = rowInfo.length == 0 ? 0 : rowInfo[0].y;
            var n:int = listItems.length;
            for (var i:int = 0; i < n; i++)
            {
                if (listItems[i].length)
                {
                    if (pt.y < yy + rowInfo[i].height)
                    {
                        var xx:Number = 0;
                        var m:int = listItems[i].length;
                        for (var j:int = 0; j < m; j++)
                        {
                            if (pt.x < xx + visibleColumns[j].width)
                                return listItems[i][j];
                            xx += visibleColumns[j].width;
                        }
                    }
                }
                yy += rowInfo[i].height;
            }
        }
        else if (target == highlightIndicator)
            return lastHighlightItemRenderer;

        while (target && target != this)
        {
            if (target is IListItemRenderer && 
                (target.parent == listSubContent || target.parent == listContent))
            {
                if (target.visible)
                    return IListItemRenderer(target);
                break;
            }

            if (target is IUIComponent)
                target = IUIComponent(target).owner;
            else 
                target = target.parent;
        }
        return null;
    }

    /**
     *  @private
     */
    mx_internal function get gridColumnMap():Object
    {
        return columnMap;
    }

    /**
     *  @private
     */
    private function createRow(left:Number,top:Number,right:Number,bottom:Number,more:Boolean):void
    {
        var xx:Number;
        var ww:Number;
        var hh:Number;

        var j:int;

        var c:AdvancedDataGridColumn;
        var item:IListItemRenderer;
        var rowData:AdvancedDataGridListData;
        var extraItem:IListItemRenderer;

        var bSelected:Boolean = false;
        var bHighlight:Boolean = false;
        var bCaret:Boolean = false;
        var itemData:Object;

        var uid:String = null;

        // fill the itemData with Data Loading if the item is pending 
        if (itemPending)
        {
            var optimumColumns:Array = getOptimumColumns();
            var obj:Object = {};
            for (var count:int = 0; count < optimumColumns.length; count++)
                obj[AdvancedDataGridColumn(optimumColumns[count]).dataField] = "Data Loading";
                
            itemData = obj;
        }
        else
            itemData = more ? iterator.current : null;

        xx = left;
        hh = 0;
        currentColNum = 0;
        if (!listItems[currentRowNum])
            listItems[currentRowNum]= [];
        if (more)
        {
            uid = itemToUID(itemData);
            // create the renderers
            setupRenderer(itemData,uid);
        }
        else
        {
            // if we've run out of data, we dont make renderers
            // and we inherit the previous row's height or rowHeight
            // if it is the first row.
            hh = currentRowNum > 1 ? rowInfo[currentRowNum - 1].height : rowHeight;
        }

        // layout the renderers
        hh = layoutRow(more,left,hh);
        while (listItems[currentRowNum].length > currentColNum)
        {
            // remove extra columns
            extraItem = listItems[currentRowNum].pop();
            addToFreeItemRenderers(extraItem);
        }
        if (more && variableRowHeight)
        {
            hh = Math.ceil(calculateRowHeight(itemData, hh, true));
        }

        if (listItems[currentRowNum])
        {
            var itemHeight:Number = hh - cachedPaddingTop - cachedPaddingBottom;
            for (j = 0; j < listItems[currentRowNum].length; j++)
            {
                listItems[currentRowNum][j].setActualSize(
                    listItems[currentRowNum][j].width, itemHeight);
            }
        }
        if (cachedVerticalAlign != "top")
        {
            if (cachedVerticalAlign == "bottom")
            {
                for (j = 0; j < currentColNum; j++)
                {
                    item = listItems[currentRowNum][j];
                    item.move(item.x, currentItemTop + hh - cachedPaddingBottom - item.getExplicitOrMeasuredHeight());
                }
            }
            else
            {
                for (j = 0; j < currentColNum; j++)
                {
                    item = listItems[currentRowNum][j];
                    item.move(item.x, currentItemTop + cachedPaddingTop + (hh - cachedPaddingBottom - cachedPaddingTop - item.getExplicitOrMeasuredHeight()) / 2);
                }
            }

        }
        bSelected = selectedData[uid] != null;
        bHighlight = highlightUID == uid;
        bCaret = caretUID == uid;
        rowInfo[currentRowNum] = new ListRowInfo(currentItemTop, hh, uid);

        if (more)
            drawVisibleItem(uid, bSelected, bHighlight, bCaret);

        if (hh == 0) // hh can be zero if we had zero width
            hh = rowHeight;
        currentItemTop += hh;
        currentRowNum++;
    }

    /**
     *  Moves the iterator to the next item.
     * 
     *  @private
     */
    private function moveIterator(more:Boolean):Boolean
    {
        if (itemPending)
        {
            itemPending = false;
            return true;
        }
        if (iterator && more)
        {
            try
            {
                more = iterator.moveNext();
            }
            catch (e:ChildItemPendingError)
            {
                itemPending = true;
            }
            catch (e:ItemPendingError)
            {
                lastSeekPending = new ListBaseSeekPending(CursorBookmark.CURRENT, 0)
                    e.addResponder(new ItemResponder(seekPendingResultHandler, seekPendingFailureHandler, 
                                                     lastSeekPending));
                more = false;
                iteratorValid = false;
            }
        }

        return more;
    }

    /**
     *  Contains the layout logic for the rows.
     * 
     *  @private
     */
    protected function layoutRow(more:Boolean,xx:Number,hh:Number):Number
    {
        var rh:Number = 0;
        if (more)
        {
            var item:IListItemRenderer;
            var c:AdvancedDataGridColumn;
            var ww:Number;
            currentColNum = 0;
            var itemYPos:Number = currentItemTop + cachedPaddingTop;
            var cachedPadding:Number = cachedPaddingTop + cachedPaddingBottom;

            var optimumColumns:Array = getOptimumColumns();

            while (currentColNum < optimumColumns.length)
            {
                c = optimumColumns[currentColNum];
                item = listItems[currentRowNum][currentColNum];

                ww = getWidthOfItem(item, c, currentColNum);

                item.explicitWidth = ww;

                //from list - setting variableRowHeight/wordWrap at runtime will adjust the data
                if ((item is IInvalidating) && 
                    (wordWrapChanged || 
                     variableRowHeight))
                    IInvalidating(item).invalidateSize();

                UIComponentGlobals.layoutManager.validateClient(item, true);
                currentRowHeight = item.getExplicitOrMeasuredHeight();
                rh = getRowHeight(item.data);
                item.setActualSize(ww, variableRowHeight
                                   ? currentRowHeight
                                   : rh - cachedPaddingTop - cachedPaddingBottom);
                item.move(xx, itemYPos);
                xx += c.width;

                // consider the height of the visible item only
                // otherwise its height will be taken into account 
                // while calculating rowHeight in case of variableRowHeight being true
                if(variableRowHeight && item.visible)
                {
                    hh = Math.ceil(Math.max(hh, variableRowHeight ? currentRowHeight + cachedPadding : rh));
                }
                currentColNum++;
            }
        }

        if (!variableRowHeight)
            hh = rh != 0 ? rh : getRowHeight();

        return hh;
    }
    
    /**
     *  Returns the row height.
     *
     *  @param itemData The data provider object for the row.
     *
     *  @return The height of the row, in pixels.
     * 
     */
    protected function getRowHeight(itemData:Object = null):Number
    {
        return rowHeight;
    }

    /**
     *  Returns the header item renderer.
     *
     *  @param c The column of the control.
     *
     *  @param The header item renderer.
     *
     *  @return The header item renderer.
     * 
     */
    protected function getHeaderRenderer(c:AdvancedDataGridColumn):IListItemRenderer
    {
        var renderer:IListItemRenderer;
        var factory:IFactory = columnItemRendererFactory(c, true, null);

        if (freeItemRenderersTable[c]
                && freeItemRenderersTable[c][factory]
                && freeItemRenderersTable[c][factory].length)
        {
            renderer = freeItemRenderersTable[c][factory].pop();
        }
        else
        {
            renderer = columnItemRenderer(c, true, null);
            addRendererToContentArea(renderer, c);
        }

        return renderer;
    }

    /**
     *  Return the item renderer
     * 
     */
    mx_internal function getRenderer(c:AdvancedDataGridColumn, itemData:Object, forDragProxy:Boolean = false ):IListItemRenderer
    {
        var renderer:IListItemRenderer;
        var factory:IFactory = columnItemRendererFactory(c, false, itemData);

        if (freeItemRenderersTable[c]
                && freeItemRenderersTable[c][factory]
                && freeItemRenderersTable[c][factory].length)
        {
            renderer = freeItemRenderersTable[c][factory].pop();
        }
        else
        {
            renderer = columnItemRenderer(c, false, itemData);
            renderer.styleName = c;
        }

        return renderer;
    }

    /**
     *  @private
     *  Make renderer and populate <code>listItems</code> with them.
     *
     *  @param itemData The data provider object for the row.
     *
     *  @param uid The UID of the row.
     *
     *  @param insertItems 
     * 
     */
    protected function setupRenderer(itemData:Object,uid:String,insertItems:Boolean = false):void
    {
        var c:AdvancedDataGridColumn;
        var item:IListItemRenderer;
        var rowData:AdvancedDataGridListData;
        var row:Array = [];

        var optimumColumns:Array = getOptimumColumns();
        while (currentColNum < optimumColumns.length)
        {
            c = optimumColumns[currentColNum];
            if (insertItems)
            {   
                item = getRenderer(c, itemData);
                // as the itemRenderer can move between listContent and listSubContent
                // we need to fix the reparting here
                addRendererToContentArea(item, c);
                // add item to column map, so that they can be recycled
                columnMap[item.name] = c;
            }
            else
            {
                item = listItems[currentRowNum][currentColNum];
                if (!item || itemToUID(item.data) != uid
                    || columnMap[item.name] != c)
                {
                    item = getRenderer(c, itemData);
                    // as the itemRenderer can move between listContent and listSubContent
                    // we need to fix the reparting here
                    addRendererToContentArea(item, c);
                    // a space is used if no data so text widgets get some default size
                    columnMap[item.name] = c;
                    if (listItems[currentRowNum][currentColNum])
                        addToFreeItemRenderers(listItems[currentRowNum][currentColNum]);
                    listItems[currentRowNum][currentColNum] = item;
                }
            }

            rowData = AdvancedDataGridListData(makeListData(itemData, uid, currentRowNum, c.colNum, c));
            rowMap[item.name] = rowData;
            if (item is IDropInListItemRenderer)
            {
                IDropInListItemRenderer(item).listData = itemData ? rowData : null;
            }
            item.data = itemData;
            item.visible = true;
            setVisibleDataItem(uid, item);
            row[currentColNum] = item ;
            currentColNum++;
        }

        // If we are opening AdvancedDataGrid Node then insert into listItems
        if (insertItems)
            listItems.splice(currentRowNum, 0, row);
    }

    /**
     *  @private
     */
    override protected function removeIndicators(uid:String):void
    {
        if (isRowSelectionMode())
            super.removeIndicators(uid);
    }

    /**
     *  Removes all selection and highlight and caret indicators.
     */
    override protected function clearIndicators():void
    {
        if (isRowSelectionMode())
            super.clearIndicators();
    }

    override mx_internal function clearHighlight(item:IListItemRenderer):void
    {
        if (isRowSelectionMode())
            super.clearHighlight(item);
    }

    // Cell Selection methods
    /**
     * Return <code>true</code> if <code>selectedMode</code> is 
     * <code>SINGLE_ROW</code> or <code>MULTIPLE_ROWS</code>.
     */
    protected function isRowSelectionMode():Boolean
    {
        return (selectionMode == SINGLE_ROW || selectionMode == MULTIPLE_ROWS);
    }

    /**
     *  Returns <code>true</code> if <code>selectedMode</code> is 
     *  <code>SINGLE_CELL</code> or <code>MULTIPLE_CELLS</code>.
     *
     *  @return <code>true</code> if <code>selectedMode</code> is 
     *  <code>SINGLE_CELL</code> or <code>MULTIPLE_CELLS</code>. 
     */
    protected function isCellSelectionMode():Boolean
    {
        return (selectionMode == SINGLE_CELL || selectionMode == MULTIPLE_CELLS);
    }

    /**
     *  Handle selection mode changing.
     *
     *  @private
     */
    protected function setSelectionMode(newSelectionMode:String):void
    {
        if (selectionMode == newSelectionMode)
            return;

        if (newSelectionMode == NONE)
        {
            selectable = false;
        }
        else
        {
            if (!selectable)
                selectable = true;
        }

        if (newSelectionMode == SINGLE_ROW || newSelectionMode == SINGLE_CELL)
        {
            if (allowMultipleSelection)
                allowMultipleSelection = false;
        }
        else if (newSelectionMode == MULTIPLE_ROWS || newSelectionMode == MULTIPLE_CELLS)
        {
            if (!allowMultipleSelection)
                allowMultipleSelection = true;
        }
        else if (newSelectionMode != NONE)
        {
            // Default to single row selection mode
            newSelectionMode = SINGLE_ROW;
            if (allowMultipleSelection)
                allowMultipleSelection = false;
        }

        clearAllSelection();

        _selectionMode = newSelectionMode;
    }

    /**
     *  @private
     */
    protected function selectionTween_updateHandler(event:TweenEvent):void
    {
        Sprite(event.target.listener).alpha = Number(event.value);
    }

    /**
     *  @private
     */
    protected function selectionTween_endHandler(event:TweenEvent):void
    {
        selectionTween_updateHandler(event);
    }

    /**
     *  @private
     */
    protected function onSelectionTweenUpdate(value:Number):void
    {
    }

    /**
     *  @private
     */
    protected function addRendererToContentArea(item:IListItemRenderer, column:AdvancedDataGridColumn):void
    {
        if (column.colNum < lockedColumnCount)
        {
            if (item.parent != listContent)
                listContent.addChild(DisplayObject(item));
        }
        else
        {
            if (item.parent != listSubContent)
                listSubContent.addChild(DisplayObject(item));
        }
    }

    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();

        if (!listSubContent)
        {
            listSubContent = new AdvancedListBaseContentHolder(this);
            listSubContent.styleName = this;
            listContent.addChild(listSubContent);
        }
    }
    /**
     *  @private
     *  Returns the columns array which is optimum for the current context.
     *  If users are not using horizontal scrolling and rendererProviders/columnGrouping
     *  then visibleColumns array is best. If users are using any of the other features
     *  then displayableColumns need to be used.
     */
    protected function getOptimumColumns():Array
    {
        return visibleColumns;
    }

    /**
     * @private
     *
     * Clear all the selected data.
     *
     */
    protected function clearAllSelection():void
    {
        if (isRowSelectionMode())
        {
            clearSelected();
            clearIndicators();
        }
    }
}

}
