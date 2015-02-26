////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package mx.charts.skins.halo
{

import flash.display.Graphics;
import flash.geom.Rectangle;
import mx.charts.chartClasses.GraphicsUtilities;
import mx.graphics.IFill;
import mx.graphics.IStroke;
import mx.skins.ProgrammaticSkin;

/**
 *  @private
 */
public class SelectionSkin extends ProgrammaticSkin
{
    include "../../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function SelectionSkin() 
	{
		super();
	}

    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
	{
		super.updateDisplayList(unscaledWidth, unscaledHeight);

		var fill:IFill =
			GraphicsUtilities.fillFromStyle(getStyle("selectionFill"));
		var stroke:IStroke = getStyle("selectionStroke");
				
		var w:Number = stroke ? stroke.weight / 2 : 0;
		var rc:Rectangle = new Rectangle(w, w, width - 2 * w, height - 2 * w);
		
		var g:Graphics = graphics;
		g.clear();		
		g.moveTo(rc.left, rc.top);
		if (stroke)
			stroke.apply(g);
		if (fill)
			fill.begin(g, rc);
		g.lineTo(rc.right, rc.top);
		g.lineTo(rc.right, rc.bottom);
		g.lineTo(rc.left, rc.bottom);
		g.lineTo(rc.left, rc.top);
		if (fill)
			fill.end(g);
	}
}

}
