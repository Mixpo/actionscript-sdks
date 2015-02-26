////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////

package mx.accessibility
{

import flash.accessibility.Accessibility;
import flash.events.Event;

import mx.accessibility.AccConst;
import mx.collections.CursorBookmark;
import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.controls.Tree;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.HierarchicalCollectionView;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.TreeEvent;

use namespace mx_internal;

/**
 *  TreeAccImpl is a subclass of AccessibilityImplementation
 *  which implements accessibility for the Tree class.
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public class TreeAccImpl extends AccImpl
{
    include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Enables accessibility in the Tree class.
	 * 
	 *  <p>This method is called by application startup code
	 *  that is autogenerated by the MXML compiler.
	 *  Afterwards, when instances of Tree are initialized,
	 *  their <code>accessibilityImplementation</code> property
	 *  will be set to an instance of this class.</p>
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static function enableAccessibility():void
	{
		Tree.createAccessibilityImplementation =
			createAccessibilityImplementation;
	}

	/**
	 *  @private
	 *  Creates a Tree's AccessibilityImplementation object.
	 *  This method is called from UIComponent's
	 *  initializeAccessibility() method.
	 */
	mx_internal static function createAccessibilityImplementation(
								component:UIComponent):void
	{
		component.accessibilityImplementation =
			new TreeAccImpl(component);
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
	 *  @param master The UIComponent instance that this AccImpl instance
	 *  is making accessible.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public function TreeAccImpl(master:UIComponent)
	{
		super(master);

		role = AccConst.ROLE_SYSTEM_OUTLINE;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden properties: AccImpl
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  eventsToHandle
	//----------------------------------

	/**
	 *  @private
	 *	Array of events that we should listen for from the master component.
	 */
	override protected function get eventsToHandle():Array
	{
		return super.eventsToHandle.concat(
			[ "change", TreeEvent.ITEM_OPEN, TreeEvent.ITEM_CLOSE ]);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccessibilityImplementation
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Gets the role for the component.
	 *
	 *  @param childID children of the component
	 */
	override public function get_accRole(childID:uint):uint
	{
		return childID == 0 ? role : AccConst.ROLE_SYSTEM_OUTLINEITEM;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the value of the TreeItem/Tree
	 *  which is spoken out by the screen reader
	 *  A Tree item reports its depth as its value.
	 *  The Tree itself reports no value.
	 *
	 *  @param childID uint
	 *
	 *  @return Name String
	 */
	override public function get_accValue(childID:uint):String
	{
		var accValue:String;
		
		if (childID != 0)
		{
			// Assuming childID is always ItemID + 1
			// because getChildIDArray is not always invoked.
			var index:int = childID - 1;
			var item:Object = getItemAt(index);
			if (!item)
				return accValue;
			
			var tree:Tree = Tree(master);
			var depth:int = tree.getItemDepth(
				item, index - tree.verticalScrollPosition);
			accValue = String(depth - 1);
		}

		return accValue;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the state of the TreeItem.
	 *  States are predefined for all the components in MSAA.
	 *  Values are assigned to each state.
	 *  Depending upon the treeItem being Selected, Selectable,
	 *  Invisible, Offscreen, a value is returned.
	 *
	 *  @param childID uint
	 *
	 *  @return State uint
	 */
	override public function get_accState(childID:uint):uint
	{
		var accState:uint = getState(childID);
		
		if (childID > 0)
		{
			var tree:Tree = Tree(master);

			var index:int = childID - 1;

			// For returning states (OffScreen and Invisible)
			// when the list Item is not in the displayed rows.
			if (index < tree.verticalScrollPosition ||
				index >= tree.verticalScrollPosition + tree.rowCount)
			{
				accState |= AccConst.STATE_SYSTEM_INVISIBLE;
			}
			else
			{
				accState |= AccConst.STATE_SYSTEM_SELECTABLE;

				var item:Object = getItemAt(index);

				if (item && tree.dataDescriptor.isBranch(item, tree.dataProvider))
				{
					if (tree.isItemOpen(item))
						accState |= AccConst.STATE_SYSTEM_EXPANDED;
					else
						accState |= AccConst.STATE_SYSTEM_COLLAPSED;
				}

				var renderer:IListItemRenderer =
					tree.itemToItemRenderer(item);

				if (renderer != null && tree.isItemSelected(renderer.data))
					accState |= AccConst.STATE_SYSTEM_SELECTED | AccConst.STATE_SYSTEM_FOCUSED;
			}
		}
		return accState;
	}

	/**
	 *  @private
	 *  IAccessible method for returning the Default Action.
	 *
	 *  @param childID uint
	 *
	 *  @return name of default action.
	 */
	override public function get_accDefaultAction(childID:uint):String
	{
		if (childID == 0)
			return null;

		var tree:Tree = Tree(master);

		var item:Object = getItemAt(childID - 1);
		if (!item)
			return null;
		
		if (tree.dataDescriptor.isBranch(item, tree.dataProvider))
			return tree.isItemOpen(item) ? "Collapse" : "Expand";

		return null;
	}

	/**
	 *  @private
	 *  IAccessible method for executing the Default Action.
	 *
	 *  @param childID uint
	 */
	override public function accDoDefaultAction(childID:uint):void
	{
		var tree:Tree = Tree(master);

		if (childID == 0 || !tree.enabled)
			return;

		var item:Object = getItemAt(childID - 1);
		if (!item)
			return;
		
		if (tree.dataDescriptor.isBranch(item, tree.dataProvider))
			tree.expandItem(item, !tree.isItemOpen(item)); 
	}

 	/**
	 *  @private
	 *  Method to return an array of childIDs.
	 *
	 *  @return Array
	 */
	override public function getChildIDArray():Array
	{
		var n:int = Tree(master).dataProvider ?
					Tree(master).collectionLength :
					0;

		return createChildIDArray(n);
	}
	
	/**
	 *  @private
	 *  IAccessible method for returning the bounding box of the TreeItem.
	 *
	 *  @param childID uint
	 *
	 *  @return Location Object
	 */
	override public function accLocation(childID:uint):*
	{
		var tree:Tree = Tree(master);
		
		var index:int = childID - 1;
		
		if (index < tree.verticalScrollPosition ||
			index >= tree.verticalScrollPosition + tree.rowCount)
		{
			return null;
		}

		return tree.itemToItemRenderer(getItemAt(index));
	}

	/**
	 *  @private
	 *  IAccessible method for returning the childFocus of the List.
	 *
	 *  @param childID uint
	 *
	 *  @return focused childID.
	 */
	override public function get_accFocus():uint
	{
		var index:int = Tree(master).selectedIndex;
		
		return index >= 0 ? index + 1 : 0;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  method for returning the name of the TreeItem/Tree
	 *  which is spoken out by the screen reader
	 *  The TreeItem should return the label as the name
	 *  with m of n string with level info and
	 *  Tree should return the name specified in the Accessibility Panel.
	 *
	 *  @param childID uint
	 *
	 *  @return Name String
	 */
	override protected function getName(childID:uint):String
	{
		if (childID == 0)
			return "";

		var tree:Tree = Tree(master);
		
		var item:Object = getItemAt(childID - 1);

		var name:String = "";
		
		if (!item)
			return name;
		
		if (tree.itemToLabel(item))
			name = tree.itemToLabel(item);

		return name;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function getItemAt(index:int):Object
	{
		var iterator:IViewCursor = Tree(master).collectionIterator;
		iterator.seek(CursorBookmark.FIRST, index);
		return iterator.current;
	}

	//--------------------------------------------------------------------------
	//
	//  Overridden event handlers: AccImpl
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 *  Override the generic event handler.
	 *  All AccImpl must implement this
	 *  to listen for events from its master component. 
	 */
	override protected function eventHandler(event:Event):void
	{
		// Let AccImpl class handle the events
		// that all accessible UIComponents understand.
		$eventHandler(event);

		var index:int = Tree(master).selectedIndex;
		
		var childID:uint = index + 1;

		switch (event.type)
		{
			case "change":
			{
				if (index >= 0)
				{
					Accessibility.sendEvent(master, childID,
											AccConst.EVENT_OBJECT_FOCUS);

					Accessibility.sendEvent(master, childID,
											AccConst.EVENT_OBJECT_SELECTION);
				}
				break;
			}
										
			case TreeEvent.ITEM_OPEN:
			case TreeEvent.ITEM_CLOSE:
			{
				if (index >= 0)
				{
					Accessibility.sendEvent(master, childID,
											AccConst.EVENT_OBJECT_STATECHANGE);
				}
				break;
			}
		}
	}
}

}
