///////////////////////////////////////////////////////////////////////////////////////
//  
//  ADOBE SYSTEMS INCORPORATED
//   Copyright 2007 Adobe Systems Incorporated
//   All Rights Reserved.
//   
//  NOTICE:  Adobe permits you to use, modify, and distribute this file in 
//  accordance with the terms of the Adobe license agreement accompanying it.  
//  If you have received this file from a source other than Adobe, then your use,
//  modification, or distribution of it requires the prior written permission of Adobe.
//
///////////////////////////////////////////////////////////////////////////////////////

package mx.olap
{

import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.collections.ICollectionView;
import mx.collections.IList;
import mx.collections.IViewCursor;
import mx.core.mx_internal;
import mx.resources.ResourceManager;

use namespace mx_internal;

//--------------------------------------
//  Excluded APIs
//--------------------------------------

[Exclude(name="dimension", kind="property")]

//--------------------------------------
//  metadata
//--------------------------------------

[DefaultProperty("elements")]

/**
 *  The OLAPDimension class represents a dimension of an OLAP cube.
 *
 *  @mxml
 *  <p>
 *  The <code>&lt;mx:OLAPDimension&gt;</code> tag inherits all of the tag attributes
 *  of its superclass, and adds the following tag attributes:
 *  </p>
 *  <pre>
 *  &lt;mx:OLAPDimension
 *    <b>Properties</b>
 *    attributes=""
 *    elements=""
 *    hierarchies=""
  *  /&gt;
 *
 *  @see mx.olap.IOLAPDimension
 */
public class OLAPDimension extends OLAPElement implements IOLAPDimension
{
    include "../core/Version.as";

    /**
     *  Constructor
     *
     *  @param name The name of the OLAP dimension that includes the OLAP schema hierarchy of the element.
     *
     *  @param displayName The name of the OLAP dimension, as a String, which can be used for display. 
     */
    public function OLAPDimension(name:String=null, displayName:String=null)
    {
        OLAPTrace.traceMsg("Creating dimension: " + name, OLAPTrace.TRACE_LEVEL_3);
        super(name, displayName);
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------

    //map of attributes using name as the key
    private var attributeMap:Dictionary = new Dictionary(true);

    //map of hierarchies using name as the key
    private var _hierarchiesMap:Dictionary = new Dictionary(true);

    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    private var _attributes:IList = new ArrayCollection;
    
    /**
     *  @inheritDoc
     */
    public function get attributes():IList
    {
        return _attributes;
    }
    
    /**
     *  @private
     */
    public function set attributes(value:IList):void
    {
        _attributes = value;
        for (var attrIndex:int = 0; attrIndex < value.length; ++attrIndex)
        {
            var attr:OLAPAttribute = value.getItemAt(attrIndex) as OLAPAttribute;
            attr.dimension = this;
            attributeMap[attr.name] = attr;
        }
    }
    
    private var _cube:IOLAPCube;
    
    /**
     *  @inheritDoc
     */
    public function get cube():IOLAPCube
    {
        return _cube;
    }
    
    /**
     *  @private
     */
    public function set cube(value:IOLAPCube):void
    {
        _cube = value;
    }

    mx_internal function get dataProvider():ICollectionView
    {
        return OLAPCube(cube).dataProvider;
    }
    
    /**
     *  @inheritDoc
     */
    public function get defaultMember():IOLAPMember
    {
        // get the default hierarchy here
        if ((hierarchies.length + attributes.length) > 1)
        {
            var message:String = ResourceManager.getInstance().getString(
                        "olap", "multipleHierarchies");
            throw Error(message);
        }
        
        return hierarchies[0].defaultMember;
    }
    
    /**
     *  Processes the input Array and initializes the <code>attributes</code>
     *  and <code>hierarchies</code> properties based on the elements of the Array.
     *  Attributes are represented in the Array by instances of the OLAPAttribute class, 
     *  and hierarchies are represented by instances of the OLAPHierarchy class.
     *
     *  <p>Use this property to define the attributes and hierarchies of a cube in a single Array.</p>
     */
    public function set elements(value:Array):void
    {
        var attrs:ArrayCollection = new ArrayCollection();
        var userHierarchies:ArrayCollection = new ArrayCollection();
        for each (var element:Object in value)
        {
            if (element is OLAPAttribute)
                attrs.addItem(element);
            else if (element is OLAPHierarchy)
                userHierarchies.addItem(element);
            else
                OLAPTrace.traceMsg("Invalid element specified for dimension elements");
        }
        
        attributes = attrs;
        hierarchies = userHierarchies;
    }
    
    private var _hierarchies:IList = new ArrayCollection;

    /**
     *  @inheritDoc
     */
    public function get hierarchies():IList
    {
        return _hierarchies;
    }
    
    /**
     *  @private
     */
    public function set hierarchies(value:IList):void
    {
        //limitation till we support multiple hierarchies.
        if (value.length > 1)
        {
            var message:String = ResourceManager.getInstance().getString(
                        "olap", "multipleHierarchiesNotSupported", [name]);
            throw Error(message);
        }
        
        _hierarchies = value;
        for (var hIndex:int = 0; hIndex < value.length; ++hIndex)
        {
            var h:OLAPHierarchy = value.getItemAt(hIndex) as OLAPHierarchy;
            h.dimension = this;
            _hierarchiesMap[h.name] = h;
        }
    }

    private var _isMeasureDimension:Boolean = false;
    
    /**
     *  @inheritDoc
     */
    public function get isMeasure():Boolean
    {
        return _isMeasureDimension;
    }
    
    /**
     *  @private
     */
    mx_internal function setAsMeasure(value:Boolean):void
    {
        _isMeasureDimension = value;
    }

    /**
     *  @inheritDoc
     */
    public function get members():IList
    {
        var temp:Array = [];
        
        for (var hIndex:int = 0; hIndex < hierarchies.length; ++hIndex)
            temp = temp.concat(hierarchies.getItemAt(hIndex).members.toArray());
        
        return new ArrayCollection(temp);
    }

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Creates a hierarchy of the dimension.
     *
     *  @param name The name of the hierarchy.
     *
     *  @return An OLAPHierarchy instance that represents the new hierarchy.
     */
    mx_internal function createHierarchy(name:String):OLAPHierarchy
    {
        var h:OLAPHierarchy = new OLAPHierarchy(name);
        h.dimension = this;
        _hierarchies.addItem(h);
        _hierarchiesMap[h.name] = h;
        return h;
    }
    
    /**
     *  @inheritDoc
     */
     public function findHierarchy(name:String):IOLAPHierarchy
    {
        return _hierarchiesMap[name];
    }
    
    /**
    *  @inheritDoc
    */
    public function findAttribute(name:String):IOLAPAttribute
    {
        return attributeMap[name];
    }
    
    /**
     *  @inheritDoc
     */
    public function findMember(name:String):IOLAPMember
    {
        var member:IOLAPMember;
        var hIndex:int = 0;
        var h:OLAPHierarchy;
        
        for (hIndex = 0; hIndex < attributes.length; ++hIndex)
        {
            h = attributes.getItemAt(hIndex) as OLAPHierarchy;
            member = h.findMember(name);
            if (member)
                break;
        }
        
        if (!member)
        {
            for (hIndex = 0; hIndex < hierarchies.length; ++hIndex)
            {
                h = hierarchies.getItemAt(hIndex) as OLAPHierarchy;
                member = h.findMember(name);
                if (member)
                    break;
            }
        }
        
        return member;          
    }

    /**
     *  @private
     */
    mx_internal function refresh():void
    {
        //if dimension is of measure type we have nothing to do.
        if (isMeasure)
            return;
        var temp:Object;
        var dataHandlers:Array  =[];
        
        for (hIndex = 0; hIndex < attributes.length; ++hIndex)
        {
            temp = attributes.getItemAt(hIndex);
            dataHandlers.push(temp);
        }
        
        for (var hIndex:int = 0; hIndex < hierarchies.length; ++hIndex)
        {
            temp = hierarchies.getItemAt(hIndex);
            temp.refresh(); 
            dataHandlers.push(temp);
        }
        
        for (hIndex = 0; hIndex < hierarchies.length; ++hIndex)
        {
            var h:OLAPHierarchy = hierarchies.getItemAt(hIndex) as OLAPHierarchy;
            var levels:IList = h.levels;
            for (var lIndex:int = 0; lIndex < levels.length; ++lIndex)
            {
                var level:OLAPLevel = levels[lIndex];
                //levels doesn't include allLevel
                //if (level == h.allLevel)
                //    continue;
                var a:OLAPAttribute = findAttribute(level.name) as OLAPAttribute;
                a.userHierarchy = level.hierarchy;
                a.userHierarchyLevel = level;
            }
        }
        
        // we need to refresh attributes here because we need the userHierarchy
        // userLevels to be set before refresh can happen.
        for (hIndex = 0; hIndex < attributes.length; ++hIndex)
        {
            temp = attributes.getItemAt(hIndex);
            temp.refresh(); 
        }
            
        var iterator:IViewCursor = dataProvider.createCursor();
        
        while (!iterator.afterLast)
        {
            var currentData:Object = iterator.current;
            for each (temp in dataHandlers)
                temp.processData(currentData);
            iterator.moveNext();
        }
    }

    /**
     *  @private
     */
    mx_internal function addAttribute(name:String, dataField:String):IOLAPAttribute
    {
        var attrHierarchy:OLAPAttribute = attributeMap[name];
        if (!attrHierarchy)
        {
            attrHierarchy = new OLAPAttribute(name);
            attrHierarchy.dataField = dataField;
            attrHierarchy.dimension = this;
            attributeMap[name] = attrHierarchy;
            _attributes.addItem(attrHierarchy);
        }
        return attrHierarchy;
    }

}

}
