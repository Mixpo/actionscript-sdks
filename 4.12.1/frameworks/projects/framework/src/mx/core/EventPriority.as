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

package mx.core
{

/**
 *  The EventPriority class defines constant values
 *  for the <code>priority</code> argument of the
 *  <code>addEventListener()</code> method of EventDispatcher.
 *
 *  <p>The higher the number, the higher the priority of the event listener.
 *  All listeners with priority <code>N</code> will be processed
 *  before listeners of priority <code>N - 1</code>.
 *  If two or more listeners share the same priority,
 *  they are processed in the order in which they were added.</p>
 *
 *  <p>Priorities can be positive, 0, or negative.
 *  The default priority is 0.</p>
 *
 *  <p>You should not write code that depends on the numeric values
 *  of these constants.
 *  They are subject to change in future versions of Flex.</p>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 9
 *  @playerversion AIR 1.1
 *  @productversion Flex 3
 */
public final class EventPriority
{
	include "../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class constants
	//
	//--------------------------------------------------------------------------

	/**
	 *  The CursorManager has handlers for mouse events
	 *  which must be executed before other mouse event handlers,
	 *  so they have a high priority.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const CURSOR_MANAGEMENT:int = 200;
	
	/**
	 *  Autogenerated event handlers that evaluate data-binding expressions
	 *  need to be executed before any others, so they have a higher priority
	 *  than the default.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const BINDING:int = 100;

	/**
	 *  Event handlers on component instances are executed with the default
	 *  priority, <code>0</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const DEFAULT:int = 0;

	/**
	 *  Some components listen to events that they dispatch on themselves
	 *  and let other listeners call the <code>preventDefault()</code>
	 *  method to tell the component not to perform a default action.
	 *  Those components must listen with a lower priority than the default
	 *  priority, so that the other handlers are executed first and have
	 *  a chance to call <code>preventDefault()</code>.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const DEFAULT_HANDLER:int = -50;

	/**
	 *  Autogenerated event handlers that trigger effects are executed
	 *  after other event handlers on component instances, so they have
	 *  a lower priority than the default.
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public static const EFFECT:int = -100;
}

}
