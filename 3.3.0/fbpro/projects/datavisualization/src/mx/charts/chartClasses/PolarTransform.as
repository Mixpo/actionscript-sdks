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

import flash.geom.Point;
import mx.charts.chartClasses.DataTransform;

/**
 *  The PolarTransform object represents a set of axes
 *  used to map data values to angle/distance polar coordinates
 *  and vice versa.  
 *
 *  <p>You typically do not need to interact with the PolarTransform object.
 *  Transforms are created automatically by the built-in chart types
 *  and are used by the series contained within to transform data
 *  into rendering coordinates.</p>
 */
public class PolarTransform extends DataTransform
{   
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Class constants
    //
    //--------------------------------------------------------------------------
    
    /**
     *  A string representing the radial axis.
     */
    public static const RADIAL_AXIS:String = "r";
    
    /**
     *  A string representing the angular axis.
     */
    public static const ANGULAR_AXIS:String = "a";

    /**
     *  @private
     */
    private static const TWO_PI:Number = 2 * Math.PI;

    //--------------------------------------------------------------------------
    //
    //  Constructor 
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     */
    public function PolarTransform()
    {
        super();
    }
        
    //--------------------------------------------------------------------------
    //
    //  Properties 
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  radius
    //----------------------------------

    /**
     *  @private
     *  Storage for the radius property.
     */
    private var _radius:Number;
    
    [Inspectable(environment="none")]

    /**
     *  The radius used by the transform to convert data units
     *  to polar coordinates.
     */
    public function get radius():Number
    {
        return _radius;
    }

    //----------------------------------
    //  origin
    //----------------------------------

    /**
     *  @private
     *  Storage for the origin property.
     */
    private var _origin:Point;
    
    [Inspectable(environment="none")]

    /**
     *  The origin of the polar transform.
     *  This point is used by associated series to convert data units
     *  to screen coordinates.
     */
    public function get origin():Point
    {
        return _origin;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods: DataTransform
    //
    //--------------------------------------------------------------------------

    /**
     *  @private
     */
    override public function invertTransform(...values):Array
    {
        var result:Array = [];
                
        if (values.length > 0 && values[0] != null)
        {
            result[0] =
                getAxis(ANGULAR_AXIS).invertTransform(values[0] / TWO_PI);
        }
        
        if (values.length > 1 && values[1] != null)
        {
            result[1] =
                getAxis(RADIAL_AXIS).invertTransform(values[1] / _radius);
        }
        
        return result;
    }

    /**
     *  @inheritDoc 
     */
    override public function transformCache(cache:Array, aField:String,
                                            aConvertedField:String,
                                            rField:String,
                                            rConvertedField:String):void
    {
         var i:int;
         var v:Object;
         
         if (aField != null)
         {
            getAxis(ANGULAR_AXIS).transformCache(cache, aField,
                                                 aConvertedField);
            
            for (i = 0; i < cache.length; i++)
            {
                v = cache[i][aConvertedField];
                if (v != null)
                    cache[i][aConvertedField] = Number(v) * TWO_PI;
            }
        }

        if (rField != null)
        {
            getAxis(RADIAL_AXIS).transformCache(cache, rField,
                                                rConvertedField);
            
            for (i = 0; i < cache.length; i++)
            {
                v = cache[i][rConvertedField];
                if (v != null)
                    cache[i][rConvertedField] = Number(v) * _radius;
            }
        }
    }

    //--------------------------------------------------------------------------
    //
    //  Methods 
    //
    //--------------------------------------------------------------------------

    /**
     *  Sets the width and height that the PolarTransform uses
     *  when calculating origin and radius.
     *  The containing chart calls this method.
     *  You should not generally call this method directly. 
     *  
     *  @param width The width, in pixels, of the PolarTransform.
     *  
     *  @param height The height, in pixels, of the PolarTransform. 
     */
    public function setSize(width:Number, height:Number):void
    {
        _radius = Math.min(width / 2, height / 2);
        _origin = new Point(width / 2, height / 2);
    }
}

}
