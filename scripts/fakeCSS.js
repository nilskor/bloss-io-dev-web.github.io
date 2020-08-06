
'use strict';



function forEachIn(obj, fn) {
    var index = 0;
    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            fn(obj[key], key, index++);
        }
    }
}

function extend() {
    var result = {};
    for (var i = 0; i < arguments.length; i++) {
        forEachIn(arguments[i],
            function(obj, key) {
                result[key] = obj;
            });
    }
    return result;
}

HTMLDocument.prototype.querySelectorAllHas = function( selectorString = false )
{
    const hasClause = ':has('
    let nodeList = {}

    if ( selectorString )
    {
        if ( selectorString.includes( hasClause ) )
        {
            let parentElement = selectorString.slice( 0, selectorString.indexOf( hasClause ) )
            if ( parentElement )
            {
                if ( parentElement.length > 0 )
                {
                    let _parentResults = document.querySelectorAll( parentElement )
                    if ( _parentResults )
                    {

                        let singleSelector = selectorString.replace( hasClause, ' ' )
                            singleSelector = singleSelector.replace( ')', '' )

                        if ( singleSelector )
                        {
                            if ( singleSelector.length > 0 )
                            {
                                for (const parenElem of _parentResults)
                                {
                                    let _childResults = parenElem.querySelectorAll( singleSelector )
                                    if ( _childResults )
                                        if( _childResults.length > 0 )
                                        {
                                            console.log( _childResults )
                                            nodeList = extend( nodeList, _childResults )
                                        }
                                }
                                console.log(nodeList)
                            }
                        }
                        else
                        {
                            console.log(`Invalid syntax. No child element specified inside the has clause.`)
                        }
                    }
                }
            }
            else
            {
                console.log(`Invalid syntax. No parent element specified in front of the has clause.`)
            }
        }
        else
        {
            console.log(`Invalid syntax. Missing has clause.`)
        }

    }

    return this
}

function checkResize (mutations)
{
    console.log(`checkResize`)
    var el = mutations[0].target;
    var w = el.clientWidth;
    var h = el.clientHeight;
    
    var isChange = mutations
    .map((m) => m.oldValue + '')
    .some((prev) => prev.indexOf('width: ' + w + 'px') == -1 || prev.indexOf('height: ' + h + 'px') == -1);

    if (!isChange)
    return;

    var event = new CustomEvent('resize', {detail: {width: w, height: h}});
    el.dispatchEvent(event);
}
function checkResizeSetup(theElement)
{
    theElement.addEventListener('resize', (event) => console.log(event.detail))

    var observer = new MutationObserver(checkResize)
    observer.observe(theElement, {attributes: true, attributeOldValue: true, attributeFilter: ['style']})

    console.log(theElement,observer)
}
// Example:
// var div = document.getElementById("testDiv")
// div.pseudoStyle("before","content","'test'").pseudoStyle("before","color","purple")

/** References:
 * 
 *  http://mcgivery.com/htmlelement-pseudostyle-settingmodifying-before-and-after-in-javascript/
 * 
 *  http://jsfiddle.net/Tf69a/1/
 * 
 */
