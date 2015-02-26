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
package flashx.textLayout.elements
{
	import flashx.textLayout.tlf_internal;
	
	use namespace tlf_internal;
	
	/** 
	 * <p> TableRowElement is an item in a TableElement. It most commonly contains one or more TableDataCellElement objects, 
	 * A TableRowElement always appears within a TableElement, TableBodyElement.</p>
	 *
	 * 
	 * @playerversion Flash 10
	 * @playerversion AIR 1.5
	 * @langversion 3.0
	 *
	 */
	public final class TableRowElement extends TableFormattedElement
	{		
		public var x:Number;
		public var y:Number;
		public var height:Number;
		public var rowIndex:int;
		
		// This is used for background drawing
		public var parcelIndex:int;
		
		public var columnIndex:Number = 0;
		public var iMaxRowDepth:Number = 0;
		public var beyondParcel:Boolean = false;
		
		/** @private */
		override protected function get abstract():Boolean
		{ return false; }
		
		/** @private */
		tlf_internal override function get defaultTypeName():String
		{ return "tr"; }
		
		/** @private */
		tlf_internal override function canOwnFlowElement(elem:FlowElement):Boolean
		{
			return (elem is TableDataCellElement);
		}
		
		/** @private if its in a numbered list expand the damage to all list items - causes the numbers to be regenerated */
		tlf_internal override function modelChanged(changeType:String, elem:FlowElement, changeStart:int, changeLen:int, needNormalize:Boolean = true, bumpGeneration:Boolean = true):void
		{
			super.modelChanged(changeType,elem,changeStart,changeLen,needNormalize,bumpGeneration);
		}

	}
}
