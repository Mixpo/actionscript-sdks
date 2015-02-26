////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////
  
package mx.charts.chartClasses
{

import flash.display.DisplayObjectContainer;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getDefinitionByName;

[ExcludeClass]

/**
 *  @private
 */
public class ChartsLicenseHandler
{
    include "../../core/Version.as";

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

    /**
	 *  Constructor.
	 */
    public static function displayWatermark(where:DisplayObjectContainer):void
    {
        // to handle the partner licensing issue, till a separate key is available 
    	// the following logic is added.
    	// No detailed comments  for obvious reasons.
        var PartnerClass:Class = null;
    	try
        {
             PartnerClass = Class(getDefinitionByName("ilog.utils.ElixirWR"));
    
        }
        catch(e:Error)
        {
        	if(PartnerClass == null)
       	 		new Watermark(where);
        }
    }
}

}

////////////////////////////////////////////////////////////////////////////////
//
//  Helper class: Watermark
//
////////////////////////////////////////////////////////////////////////////////

import flash.display.*;
import flash.utils.*;
import flash.text.*;
import flash.events.*;
import flash.filters.*;

class Watermark
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

    /**
	 *  Constructor.
	 */
	public function Watermark(p:DisplayObjectContainer)
    {
		super();

        this.p = p;
		
		// Do not use a weak references here.
		// Even though we typically do not allow subobjects to add
		// strong reference listeners to parent objects (because the
		// parent object then has another reference to the subobject),
		// in this case the subobject is not referenced from its parent
		// so this has to be the only thing that keeps it around.
        this.p.addEventListener("enterFrame", enterFrameHandler);
    }

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
	private var p:DisplayObjectContainer;

    /**
	 *  @private
	 */
    private var textField:TextField;

    /**
	 *  @private
	 */
    private var dx:int = 1;

    /**
	 *  @private
	 */
    private var dy:int = 1;

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

    /**
	 *  @private
	 */
    private function enterFrameHandler(event:Event):void
    {
        if (!textField)
        {
            textField = new TextField();
            textField.selectable = false;
            textField.autoSize = TextFieldAutoSize.CENTER;
            textField.textColor = 0xffffff;
            textField.backgroundColor = 0x000000;
        
            var tf:TextFormat = new TextFormat();
            tf.font = "Verdana";
            tf.size = 25;
            tf.bold = true;
            textField.defaultTextFormat = tf;
            textField.text = "Flex Data Visualization Trial";
//          textField.blendMode = BlendMode.DIFFERENCE;
            textField.alpha = 0.35;
            textField.mouseEnabled = false;
              
	    var a:Array = [];
            a.push(new GlowFilter(0x000000, 1.0, 6.0, 6.0, 2, 1, false, true));
            textField.filters = a;     
            
                         
            
			textField.x = Math.round(-10 * Math.random());
            textField.y = Math.round(-40 * Math.random());
        }

        if (!textField.parent)
            p.addChild(textField);

        if (!textField.visible)
            textField.visible = true;

		/*
        if (textField.x + textField.width > textField.parent.width)
            dx = -1;
        if (textField.x < 0)
            dx = 1;
        if (textField.y + textField.height > textField.parent.height)
            dy = -1;
        if (textField.y < 0)
            dy = 1;

        textField.x += dx;
        textField.y += dy;
		*/

        textField.x = textField.parent.width / 2 - textField.width / 2;
        textField.y = textField.parent.height / 2 - textField.height / 2;
    }
}
