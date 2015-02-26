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
package spark.skins.mobile
{
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Sprite;

import mx.core.DPIClassification;

import spark.components.Group;
import spark.components.SpinnerListContainer;
import spark.layouts.HorizontalLayout;
import spark.skins.mobile.supportClasses.MobileSkin;
import spark.skins.mobile120.assets.SpinnerListContainerBackground;
import spark.skins.mobile120.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile120.assets.SpinnerListContainerShadow;
import spark.skins.mobile160.assets.SpinnerListContainerBackground;
import spark.skins.mobile160.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile160.assets.SpinnerListContainerShadow;
import spark.skins.mobile240.assets.SpinnerListContainerBackground;
import spark.skins.mobile240.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile240.assets.SpinnerListContainerShadow;
import spark.skins.mobile320.assets.SpinnerListContainerBackground;
import spark.skins.mobile320.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile320.assets.SpinnerListContainerShadow;
import spark.skins.mobile480.assets.SpinnerListContainerBackground;
import spark.skins.mobile480.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile480.assets.SpinnerListContainerShadow;
import spark.skins.mobile640.assets.SpinnerListContainerBackground;
import spark.skins.mobile640.assets.SpinnerListContainerSelectionIndicator;
import spark.skins.mobile640.assets.SpinnerListContainerShadow;
/**
 *  ActionScript-based skin for the SpinnerListContainer in mobile applications. 
 * 
 *  @see spark.components.SpinnerListContainer
 * 
 *  @langversion 3.0
 *  @playerversion AIR 3
 *  @productversion Flex 4.6
 */
public class SpinnerListContainerSkin extends MobileSkin
{
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     * 
     */
    public function SpinnerListContainerSkin()
    {
        super();
        
        switch (applicationDPI)
        {
			case DPIClassification.DPI_640:
			{
				// Note provisional may need changes
				borderClass = spark.skins.mobile640.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile640.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile640.assets.SpinnerListContainerShadow;
				
				cornerRadius = 20;
				borderThickness = 3;
				selectionIndicatorHeight = 182;
				break;
			}
			case DPIClassification.DPI_480:
			{
				// Note provisional may need changes
				borderClass = spark.skins.mobile480.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile480.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile480.assets.SpinnerListContainerShadow;
				
				cornerRadius = 16;
				borderThickness = 2;
				selectionIndicatorHeight = 144;
				break;
			}
            case DPIClassification.DPI_320:
            {
                borderClass = spark.skins.mobile320.assets.SpinnerListContainerBackground;
                selectionIndicatorClass = spark.skins.mobile320.assets.SpinnerListContainerSelectionIndicator;
                shadowClass = spark.skins.mobile320.assets.SpinnerListContainerShadow;
                
                cornerRadius = 10;
                borderThickness = 2;
                selectionIndicatorHeight = 96;
                break;
            }
			case DPIClassification.DPI_240:
			{
				borderClass = spark.skins.mobile240.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile240.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile240.assets.SpinnerListContainerShadow;
				
				cornerRadius = 8;
				borderThickness = 1;
				selectionIndicatorHeight = 72;
				break;
			}
			case DPIClassification.DPI_120:
			{
				borderClass = spark.skins.mobile120.assets.SpinnerListContainerBackground;
				selectionIndicatorClass = spark.skins.mobile120.assets.SpinnerListContainerSelectionIndicator;
				shadowClass = spark.skins.mobile120.assets.SpinnerListContainerShadow;
				
				cornerRadius = 4;
				borderThickness = 1;
				selectionIndicatorHeight = 37;
				break;
			}
            default: // default DPI_160
            {
                borderClass = spark.skins.mobile160.assets.SpinnerListContainerBackground;
                selectionIndicatorClass = spark.skins.mobile160.assets.SpinnerListContainerSelectionIndicator;
                shadowClass = spark.skins.mobile160.assets.SpinnerListContainerShadow;
            
                cornerRadius = 5;
                borderThickness = 1;
                selectionIndicatorHeight = 48;
                
                break;
            }
        }
        
        minWidth = 30;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Pixel thickness of the border. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var borderThickness:Number;
    
    /**
     *  Radius of the border corners.
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var cornerRadius:Number;
    
    /**
     *  Height of the selection indicator.  
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var selectionIndicatorHeight:Number;
    
    /**
     *  Class for the border part. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var borderClass:Class;
    
    /**
     *  Class for the selection indicator skin part. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var selectionIndicatorClass:Class;
    
    /**
     *  Class for the shadow skin part.  
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var shadowClass:Class;
    
    /**
     *  Border skin part which includes the background. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var border:InteractiveObject;
    
    /**
     *  Selection indicator skin part. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var selectionIndicator:InteractiveObject;
    
    /**
     *  Shadow skin part. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var shadow:InteractiveObject;
    
    /**
     *  Mask for the content group. 
     *       
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    protected var contentGroupMask:Sprite;
    
    //--------------------------------------------------------------------------
    //
    //  Skin parts 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  An optional skin part that defines the Group where the content 
     *  children are pushed into and laid out.
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var contentGroup:Group;
    
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------
    /** 
     *  @copy spark.skins.spark.ApplicationSkin#hostComponent
     *  
     *  @langversion 3.0
     *  @playerversion AIR 3
     *  @productversion Flex 4.6
     */
    public var hostComponent:SpinnerListContainer;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods 
    //
    //--------------------------------------------------------------------------
    /**
     *  @private
     */
    override protected function createChildren():void
    {
        super.createChildren();
        
        if (!border)
        {
            // Border and background
            border = new borderClass();
            border.mouseEnabled = false;
            addChild(border);
        }
        
        if (!contentGroup)
        {
            // Contains the child elements
            contentGroup = new Group();
            var hLayout:HorizontalLayout = new HorizontalLayout();
            hLayout.gap = 0;
            hLayout.verticalAlign = "middle";
            contentGroup.layout = hLayout;
            contentGroup.id = "contentGroup";
            addChild(contentGroup);
        }
        
        if (!shadow)
        {
            // Shadowing sits on top of the content
            shadow = new shadowClass();
            shadow.mouseEnabled = false;
            addChild(shadow);
        }
        
        if (!selectionIndicator)
        {
            // Selection indicator is on top
            selectionIndicator = new selectionIndicatorClass();
            selectionIndicator.mouseEnabled = false;
            addChild(selectionIndicator);
        }
        
        if (!contentGroupMask)
        {
            // Create a mask for the content
            contentGroupMask = new Sprite();
            addChild(contentGroupMask);
        }
    }   
    
    /**
     *  @private
     */
    override protected function measure():void
    {
        super.measure();
        
        var contentW:Number = contentGroup.getPreferredBoundsWidth();
        var contentH:Number = contentGroup.getPreferredBoundsHeight();
        
        measuredWidth = measuredMinWidth = contentW + borderThickness * 2;
        measuredHeight = contentH + borderThickness * 2;
        
        measuredMinHeight = selectionIndicatorHeight + borderThickness * 4;
        minHeight = measuredMinHeight;
    }
        
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
        super.layoutContents(unscaledWidth, unscaledHeight);
                
        unscaledHeight = Math.max(unscaledHeight, selectionIndicatorHeight + borderThickness * 4);
        
        setElementSize(contentGroup, unscaledWidth - borderThickness * 2, unscaledHeight - borderThickness * 2);
        setElementPosition(contentGroup, borderThickness, borderThickness);
        
        // Inset by the borderThickness horizontally because the selectionIndicator starts at 0
        setElementSize(border, unscaledWidth - borderThickness * 2, unscaledHeight);
        setElementPosition(border, borderThickness, 0);
        
        setElementSize(shadow, unscaledWidth - borderThickness * 4, unscaledHeight - borderThickness * 2);
        setElementPosition(shadow, borderThickness * 2, borderThickness);
                
        setElementSize(selectionIndicator, unscaledWidth, selectionIndicatorHeight);
        setElementPosition(selectionIndicator, 0, Math.floor((unscaledHeight - selectionIndicatorHeight) / 2));
                
        // The SpinnerLists contain a left and right border. We don't want to show the leftmost 
        // SpinnerLists's left border nor the rightmost one's right border. 
        // We inset the mask on the left and right sides to accomplish this. 
        var g:Graphics = contentGroupMask.graphics;
        g.clear();
        g.beginFill(0x00FF00);
        g.drawRoundRect(borderThickness * 2, borderThickness, 
                        unscaledWidth - borderThickness * 4,
                        unscaledHeight - borderThickness * 2,
                        cornerRadius, cornerRadius);
        g.endFill();
        
        contentGroup.mask = contentGroupMask;       
    }
}
}