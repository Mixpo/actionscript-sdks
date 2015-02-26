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

/*
 *  The ISprite interface defines the basic set of APIs
 *  for web version of flash.display.Sprite
 */

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.geom.Rectangle;
import flash.media.SoundTransform;

    /**
     *  @copy flash.display.Sprite#graphics
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get graphics():Graphics;

    /**
     *  @copy flash.display.Sprite#buttonMode
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get buttonMode():Boolean;
    function set buttonMode(value:Boolean):void;

    /**
     *  @copy flash.display.Sprite#startDrag()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void;

    /**
     *  @copy flash.display.Sprite#stopDrag()
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function stopDrag():void;

    /**
     *  @copy flash.display.Sprite#dropTarget
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get dropTarget():DisplayObject;

    /**
     *  @copy flash.display.Sprite#hitArea
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get hitArea():Sprite;
    function set hitArea(value:Sprite):void;


    /**
     *  @copy flash.display.Sprite#useHandCursor
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get useHandCursor():Boolean;
    function set useHandCursor(value:Boolean):void;


    /**
     *  @copy flash.display.Sprite#soundTransform
     *  
     *  @langversion 3.0
     *  @playerversion Flash 9
     *  @playerversion AIR 1.1
     *  @productversion Flex 3
     */
    function get soundTransform():SoundTransform;
    function set soundTransform(sndTransform:SoundTransform):void;

