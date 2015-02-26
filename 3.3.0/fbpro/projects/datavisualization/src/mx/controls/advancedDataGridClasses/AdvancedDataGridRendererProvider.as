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

import mx.core.IFactory;
import mx.core.mx_internal;

use namespace mx_internal;
    
/**
 *  An AdvancedDataGridRendererProvider instance defines the characteristics for 
 *  a single item renderer used by the AdvancedDataGrid control. 
 *  Use properties of the AdvancedDataGridRendererProvider class to 
 *  configure where an item renderer is used in an AdvancedDataGrid control.
 *
 *  <p>The following example uses the AdvancedDataGridRendererProvider class to 
 *  configure a custom item renderer named EstimateRenderer.mxml in the 
 *  myComponents subdirectory.</p>
 *
 *  <pre>
 *  &lt;mx:AdvancedDataGrid&gt;
 *      &lt;mx:columns&gt;
 *          &lt;mx:AdvancedDataGridColumn dataField="Region"/&gt;
 *          &lt;mx:AdvancedDataGridColumn dataField="Territory_Rep"
 *              headerText="Territory Rep"/&gt;
 *          &lt;mx:AdvancedDataGridColumn dataField="Actual"/&gt;
 *          &lt;mx:AdvancedDataGridColumn dataField="Estimate"/&gt;
 *      &lt;/mx:columns&gt;
 *  
 *      &lt;mx:rendererProviders&gt;
 *          &lt;mx:AdvancedDataGridRendererProvider 
 *              columnIndex="3"
 *              columnSpan="1" 
 *              renderer="myComponents.EstimateRenderer"/&gt;
 *      &lt;/mx:rendererProviders&gt;
 *  &lt;/mx:AdvancedDataGrid&gt;
 *  </pre>
 *  
 *  @mxml
 *  <p>The <code>&lt;mx:AdvancedDataGridRendererProvider&gt;</code> tag 
 *  defines the following tag attributes:</p>
 *  <pre>
 *  &lt;mx:AdvancedDataGridRendererProvider
 *    <b>Properties</b>
 *    column="<i>Not defined</i>"
 *    columnIndex="-1"
 *    columnSpan="1"
 *    dataField="<i>No default</i>"
 *    depth="<i>All depths of the tree</i>"
 *    renderer="null"
 *    rowSpan="1"
 *  /&gt;
 *
 *  @see mx.controls.AdvancedDataGrid
 *
 *  @includeExample examples/AdvancedDataGridChartRendererExample.mxml
 *  @includeExample examples/ChartRenderer.mxml -noswf
 */
public class AdvancedDataGridRendererProvider implements IAdvancedDataGridRendererProvider
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
    public function AdvancedDataGridRendererProvider()
    {
        super();
    }
    
    /** 
     *  The <code>id</code> of the column for which the renderer is used. 
     *  If you omit this property, 
     *  you can use the <code>columnIndex</code> property to specify the column. 
     */
    public var column:AdvancedDataGridColumn;
       
    /** 
     *  The column index for which the renderer is used, 
     *  where the first column is at an index of 0.
     * 
     *  @default -1
     */
    public var columnIndex:int = -1;
       
    /**
     *  Specifies how many columns the renderer should span. 
     *  Set this property to 0 to span all columns.
     *  The AdvancedDataGrid control uses this information to set the width 
     *  of the item renderer.
     * 
     *  @default 1
     */
    public var columnSpan:int = 1;
       
    /** 
     *  The data field in the data provider for the renderer. 
     *  This property is optional. 
     */
    public var dataField:String;
       
    /**
     *  Depth in the tree at which the renderer is used, 
     *  where the top-most node of the tree is at a depth of 1. 
     *  Use this property if the renderer should only be used when the tree 
     *  is expanded to a certain depth, but not for all nodes in the tree. 
     *  By default, the control uses the renderer for all levels of the tree.
     */
    public var depth:int = -1;
       
    /**
     * The ItemRenderer IFactory used to create an instance of the item renderer. 
     */
    public var renderer:IFactory;
    
    /**
     *  Specifies how many rows the renderer should span.
     *  The AdvancedDataGrid control uses this information to set the height of the renderer.
     *
     *  <p>Currently, this property is not implemented in the AdvancedDataGrid control.</p>
     *  
     *  @default 1
     */
    public var rowSpan:int = 1;
       
    /**
     *  @private
     *  Method which compares property values to given values to determine whether the 
     *  renderer should be used for the given data, depth and column.
     */
    protected function checkMatch(data:Object, dataDepth:int, column:AdvancedDataGridColumn):Boolean
    {
        var matching:Boolean = true;
        
        // check if the data object has the specified dataField
        if(dataField && (!data || !data.hasOwnProperty(dataField)))
            matching = false;
        
        // check if the column has the same columnIndex as specified in the rendererProvider
        if(columnIndex != -1 && columnIndex != column.colNum)
            matching = false;
        
        // check if the data has the same depth as specified in the rendererProvider
        if(depth != -1 && dataDepth != depth)
            matching = false;
        
        // check if this is the same column as specified in the rendererProvider
        if(this.column && this.column != column)
            matching = false;
        
        return matching;    
    }
       
    /**
     *  Updates the AdvancedDataGridRendererDescription instance with information about 
     *  this AdvancedDataGridRendererProvider instance.
     * 
     *  @param data The data item to display.
     * 
     *  @param dataDepth The depth of the data item in the AdvancedDataGrid control.
     * 
     *  @param column The column associated with the item.
     * 
     *  @param description The AdvancedDataGridRendererDescription object populated 
     *  with the renderer and column span information.
     */
    public function describeRendererForItem(data:Object, 
                                   dataDepth:int, 
                                   column:AdvancedDataGridColumn,
                                   description:AdvancedDataGridRendererDescription):void
    {
        // check for matching properties
        if(checkMatch(data,dataDepth,column))
        {
            description.columnSpan = this.columnSpan;
            description.renderer = this.renderer;
        }
    }
}

}