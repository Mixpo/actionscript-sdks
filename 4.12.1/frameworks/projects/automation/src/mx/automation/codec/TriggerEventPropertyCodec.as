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

package mx.automation.codec
{
	
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import mx.automation.tool.IToolPropertyDescriptor;
	import mx.automation.IAutomationManager;
	import mx.automation.IAutomationObject;
	
	/**
	 * Translates between internal Flex triggerEvent property and automation-friendly version
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class TriggerEventPropertyCodec extends DefaultPropertyCodec
	{
		public function TriggerEventPropertyCodec()
		{
			super();
		}
		
		override public function encode(automationManager:IAutomationManager,
										obj:Object, 
										propertyDescriptor:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):Object
		{
			var val:Object = getMemberFromObject(automationManager, obj, propertyDescriptor);
			
			/* return (val is MouseEvent ? "mouse" :
			val is KeyboardEvent ? "keyboard" : null); */
			return (val is MouseEvent ? 1 :
				val is KeyboardEvent ? 2 : null); 
		}
		
		override public function decode(automationManager:IAutomationManager,
										obj:Object, 
										value:Object,
										propertyDescriptor:IToolPropertyDescriptor,
										relativeParent:IAutomationObject):void
		{
			obj[propertyDescriptor.name] = 
				(value == 1 ? new MouseEvent(MouseEvent.CLICK) :
					value == 2 ? new KeyboardEvent(KeyboardEvent.KEY_UP) : null);
		}
	}
	
}
