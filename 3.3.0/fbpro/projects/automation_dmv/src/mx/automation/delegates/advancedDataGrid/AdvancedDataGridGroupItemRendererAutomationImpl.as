////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.automation.delegates.advancedDataGrid
{
import flash.display.DisplayObject;
import flash.events.Event;
import mx.automation.Automation;

import mx.automation.delegates.core.UITextFieldAutomationImpl;
import mx.automation.IAutomationObjectHelper;
import mx.automation.delegates.core.UIComponentAutomationImpl;
import mx.controls.listClasses.ListItemRenderer;
import mx.controls.advancedDataGridClasses.AdvancedDataGridGroupItemRenderer;
import mx.core.mx_internal;
import mx.core.IUITextField;

use namespace mx_internal;

[Mixin]
/**
 * 
 *  Defines methods and properties required to perform instrumentation for the 
 *  AdvancedDataGridGroupItemRenderer class.
 *  
 *  @see x.controls.advancedDataGridClasses.AdvancedDataGridGroupItemRenderer
 *
 */
public class  AdvancedDataGridGroupItemRendererAutomationImpl extends UIComponentAutomationImpl
{
   
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
        Automation.registerDelegateClass(AdvancedDataGridGroupItemRenderer, AdvancedDataGridGroupItemRendererAutomationImpl);
    }   

    //--------------------------------------------------------------------------
    // 
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /** 
     *  Constructor.
     * @param obj AdvancedDataGridGroupItemRenderer object to be automated.     
     */
    public function AdvancedDataGridGroupItemRendererAutomationImpl(obj:AdvancedDataGridGroupItemRenderer)
    {
    
        super(obj);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     *  storage for the owner component
     */
    protected function get listItemRend():AdvancedDataGridGroupItemRenderer
    {
        return uiComponent as AdvancedDataGridGroupItemRenderer;
    }


    //--------------------------------------------------------------------------
    //
    //  Overridden properties
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  automationName
    //----------------------------------
   
    /**
     *  @private
     */
    override public function get automationName():String
    {
        
        return ( listItemRend.listData.label ||  super.automationName);
    }

    //----------------------------------
    //  automationValue
    //----------------------------------
   
    /**
     *  @private
     */
    override public function get automationValue():Array
    {
        return [automationName];
    }

}
}