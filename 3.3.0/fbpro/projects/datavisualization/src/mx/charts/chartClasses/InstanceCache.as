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

import flash.text.TextFormat;

import mx.core.ClassFactory;
import mx.core.ContextualClassFactory;
import mx.core.IFactory;
import mx.core.UITextField;

/**
 *  InstanceCache is a utility that governs the task of creating and managing
 *  a set of <i>n</i> object instances, where <i>n</i> changes frequently.
 */   
public class InstanceCache
{
    include "../../core/Version.as";

    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------

    /**
     *  Constructor.
     *
     *  @param type The type of object to construct.
     *  This can be either a Class or an IFactory.
     *
     *  @param parent An optional DisplayObject to add new instances to.
     *
     *  @param insertPosition Where in the parent's child list
     *  to insert instances. Set to -1 to add the children to the end of the child list.
     */
    public function InstanceCache(type:Object, parent:Object = null,
                                  insertPosition:int = -1)
    {
        super();

        _parent = parent;
        
        if (type is IFactory)
        {
            _factory = IFactory(type);
        }
        else if (type is Class)
        {
            _class = Class(type);
            _factory = new ContextualClassFactory(Class(type));
        }

        _insertPosition = insertPosition;
    }

    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private var _parent:Object;
    
    /**
     *  @private
     */
    private var _class:Class = null;
    
    /**
     *  @private
     */
    private var _insertPosition:int;
    
    /**
     *  @private
     */
    private var _instanceCount:int = 0;
    
    //--------------------------------------------------------------------------
    //
    //  Properties
    //
    //--------------------------------------------------------------------------

    //----------------------------------
    //  count
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  The number of items currently required in the cache.
     */
    public function get count():int
    {
        return _instanceCount;
    }

    /**
     *  @private
     */
    public function set count(value:int):void
    {
        if (value == _instanceCount)
            return;
            
        var newInstanceCount:int = value;
        var oldInstanceCount:int = _instanceCount;
        var availableInstanceCount:int = _instances.length;
        var insertBase:int;
        if(_parent != null)
        {
              insertBase = Math.min(_insertPosition,
                _parent.numChildren - availableInstanceCount);
        }
        
        if (newInstanceCount> oldInstanceCount)
        {
            if (!_factory) 
            {
                value = 0;              
            }
            else 
            {
                for (var i:int = oldInstanceCount;
                     i < newInstanceCount && i < availableInstanceCount;
                     i++) 
                {
                    if (hide)
                        _instances[i].visible = true;
                    
                    if (_parent && remove)
                    {
                        if (insertBase >= 0)
                            _parent.addChildAt(_instances[i],insertBase + i);
                        else
                            _parent.addChild(_instances[i]);
                    }
                }
            
                for (; i < newInstanceCount; i++)
                {
                    var newInst:Object = _factory.newInstance();
                      
                    if (_parent)
                    {
                        if (insertBase > 0)
                            _parent.addChildAt(newInst, insertBase + i);
                        else
                            _parent.addChild(newInst);
                    }

                    if (creationCallback != null)
                        creationCallback(newInst,this);
                    
                    _instances.push(newInst);
                }

                applyProperties(availableInstanceCount, newInstanceCount);
                
                if (_format)
                    applyFormat(availableInstanceCount, newInstanceCount);
            }
        }

        else if (newInstanceCount < oldInstanceCount)
        {
            if (remove)
            {
                for (i = newInstanceCount; i < oldInstanceCount; i++)
                {
                    _parent.removeChild(_instances[i]);
                }
            }

            if (hide)
            {
                for (i = newInstanceCount; i < oldInstanceCount; i++)
                {
                    _instances[i].visible = false;
                }
            }

            if (discard)
                _instances = _instances.slice(0, newInstanceCount);         
        }

        _instanceCount = value;
    }   

    //----------------------------------
    //  creationCallback
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  A callback invoked when new instances are created.
     *  This callback has the following signature:
     *  <pre>
     *  function creationCallback(<i>newInstance</i>:Object, <i>cache</i>:InstanceCache):void;
     *  </pre>
     */
    public var creationCallback:Function;
    
    //----------------------------------
    //  discard
    //----------------------------------
    
    [Inspectable(environment="none")]

    /** 
     *  Determines if unneeded instances are discarded.
     *  If set to <code>true</code>, extra elements are discarded
     *  when the cache count is reduced.
     *  Otherwise, extra elements are kept in a separate cache
     *  and reused when the count is increased.
     */
    public var discard:Boolean = false;
    
    //----------------------------------
    //  factory
    //----------------------------------
    
    /**
     *  @private
     */
    private var _factory:IFactory;
    
    [Inspectable(environment="none")]

    /**
     *  A factory that generates the type of object to cache.
     *  Assigning to this discards all current instances
     *  and recreate new instances of the correct type.
     */
    public function get factory():IFactory
    {
        return _factory;
    }

    /**
     *  @private
     */
    public function set factory(value:IFactory):void 
    {
        if (value == _factory ||
            ((value is ClassFactory) &&
            (_factory is ClassFactory) &&
            (ClassFactory(_factory).generator == ClassFactory(value).generator) &&
            (!(value is ContextualClassFactory))))
            return;

        _factory = value;
        _class = null;

        var instanceCount:Number = _instanceCount;
        count = 0;
        count = instanceCount;
    }
    
    //----------------------------------
    //  format
    //----------------------------------

    /**
     *  @private
     */
    private var _format:TextFormat;

    [Inspectable(environment="none")]

    /**
     *  A TextFormat to apply to any instances created.
     *  If set, this format is applied as the current and default format
     *  for the contents of any instances created.
     *  This property is only relevant if the factory
     *  generates TextField instances.  
     */
    public function get format():TextFormat
    {
        return _format;
    }

    /**
     *  @private
     */
    public function set format(value:TextFormat):void
    {
        _format = value;

        if (_format)
            applyFormat(0, _instances.length);
    }

    //----------------------------------
    //  hide
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  Determines if unneeded instances should be hidden.
     *  If <code>true</code>, the <code>visible</code> property
     *  is set to <code>false</code> on each extra element
     *  when the cache count is reduced, and set to <code>true</code>
     *  when the count is increased.
     *  
     *  <p>This property is only relevant when the factory
     *  generates DisplayObjects.
     *  Setting this property to <code>true</code> for other factory types
     *  generates a run-time error.</p>
     */
    public var hide:Boolean = true;
    
    //----------------------------------
    //  insertPosition
    //----------------------------------
    
    [Inspectable(environment="none")]

    /** 
     *  The position of the instance in the parent's child list. 
     */
    public function set insertPosition(value:int):void
    {
        if (value != _insertPosition)
        {
            _insertPosition = value;

            if (_parent)
            {
                for (var i:int = 0; i < _instances.length; i++)
                {
                    _parent.setChildIndex(_instances[i], i + _insertPosition);
                }
            }
        }
    }

    //----------------------------------
    //  instances
    //----------------------------------

    /**
     *  @private
     */
    private var _instances:Array = [];
    
    [Inspectable(environment="none")]

    /**
     *  The Array of cached instances.
     *  There may be more instances in this Array than currently requested.
     *  You should rely on the <code>count</code> property
     *  of the instance cache rather than the length of this Array.
     */
    public function get instances():Array
    {
        return _instances;
    }
    
    //----------------------------------
    //  properties
    //----------------------------------

    /**
     *  @private
     */
    private var _props:Object = {};
    
    [Inspectable(environment="none")]

    /**
     *  A hashmap of properties to assign to new instances.
     *  Each key/value pair in this hashmap is assigned
     *  to each new instance created.
     *  The property hashmap is assigned to any existing instances when set.
     *  
     *  <p>The values in the hashmap are not cloned;
     *  object values are shared by all instances.</p>
     */
    public function get properties():Object
    {
        return _props;
    }

    /**
     *  @private
     */
    public function set properties(value:Object):void
    {
        _props = value;

        applyProperties(0, _instances.length);
    }

    //----------------------------------
    //  remove
    //----------------------------------

    [Inspectable(environment="none")]

    /**
     *  Determines if unneeded instances should be removed from their parent.
     *  If <code>true</code>, the <code>removeChild()</code> method
     *  is called on the parent for each extra element
     *  when the cache count is reduced.
     *  
     *  <p>This property is only relevant when the factory
     *  generates DisplayObjects.
     *  Setting this property to <code>true</code> for other factory types
     *  generates a run-time error.</p>
     */
    public var remove:Boolean = false;

    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    private function applyProperties(start:int, end:int):void
    {   
        for (var i:int = start; i < end; i++)
        {
            var newInst:Object = _instances[i];

            for (var aProp:String in _props)
            {
                newInst[aProp] = _props[aProp];
            }           
        }
    }

    /**
     *  @private
     */
    private function applyFormat(start:int, end:int):void
    {   
        for (var i:int = start; i < end; i++)
        {
            var newField:UITextField = _instances[i];
            newField.setTextFormat(_format);
            newField.defaultTextFormat = _format;
            
        }
    }
}

}