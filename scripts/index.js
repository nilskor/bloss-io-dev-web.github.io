
'use strict';

const ViewportFactor = 45

const _DEBUG = true
const oDebug = 
{
    loadPage: "loadPage()",
    loadPageTriggerCallback: "loadPage().xhrTrigger.callback successfully called.",
    xhrOnLoad: "xhrOnLoad()",
    xhrOnLoadSuccess: "xhrOnLoad() successfully retrieved the requested data page.",
    xhrRegisterOnloadCallback: "xhrRegisterOnloadCallback() set state to 'loaded'",
    xhrRegisterOnloadCallbackFn: "Callback function definition:",
    runOnNextEventCycle: "runOnNextEventCycle()",
    xhrOnError: "xhrOnError()",
    xhrAddListeners: "xhrAddListeners()",
    injectContentInto: "injectContentInto()",
    get_fragment: "get_fragment()",
    pageRequestViaAddressbar: "pageRequestViaAddressbar()",
    pageRequestViaAddressbar_TriggerCallback: "pageRequestViaAddressbar().xhrTrigger.callback successfully called.",
    pageRequestViaAddressbar_foundValidPage: "pageRequestViaAddressbar() 'foundValidPage' is true, do history.replaceState().",
    pageRequestViaAddressbar_noValidPage: "pageRequestViaAddressbar() noValidPage, do history.replaceState() back to index.html(page0).",
    _onDOMContentLoaded: "_onDOMContentLoaded()",
    _onClick: "_onClick()",
    _onClick_GenuineBookmark: "Signature of a genuine click on a bookmark.",
    _onClick_PageNavigation: "Signature of a page navigation click.",
    _onClick_foundValidPage: "_onClick() 'foundValidPage' is true.",
    _onClick_localStorage: "LocalStorage has remembered this many page visits:",
    _onHashChange: "_onHashChange()",
    _onHashChange_gotoBkmk_TriggerCallback: "_onHashChange().xhrTrigger.callback successfully called for 'go to bookmark'.",
    _onHashChange_goBackWithBkmk_TriggerCallback: "_onHashChange().xhrTrigger.callback successfully called for 'go Back with bookmark'.",
    _onHashChange_NativeBookmark: "_onHashChange() Native bookmark clicked.",
    _onPopState: "_onPopState()",
    _onPopState_validEventState: "_onPopState() Event.state is valid, load a page:",
    _onPopState_noEventState: "_onPopState() Event.state object is null, but we have a page:",
    _onPopState_variables: "_onPopState() variables:",
    _onPopState_allNull: "_onPopState() All objects appear to be null, which means we're probably back at index.html(page0), or should be.",
}

function runOnNextEventCycle( runCode )
{
    if ( runCode )
    {
        if (_DEBUG) console.log( oDebug.runOnNextEventCycle, `Args: runCode: `, runCode.toString() )
        let _st = setTimeout( ()=> { runCode.call() }, 0, runCode )
    }
}

/**
 * Chrome issue: asking it to work with DOM elements after the xhrOnLoad() has loaded
 *               text into an innerHTML is not reliable (too quick?)
 * 
 * https://forum.freecodecamp.org/t/how-to-make-js-wait-until-dom-is-updated/122067
 * 
 * Answer #3 by tzs
 *  
 */
function call_after_DOM_updated(fn)
{
    let delay1 = function () { window.requestAnimationFrame(fn) }
    let delay2 = function () { window.requestAnimationFrame( delay1 ) }
    window.requestAnimationFrame( delay2 )
}

function xhrRegisterOnloadCallback(id)
{
    let _id = id
    let status = ''
    let callback = null

    Object.defineProperty( this, 'status',
        {
            get: function(){},
            set: function(state)
            {
                if ( state === 'loaded' && callback )
                {
                    status = state
                    if (_DEBUG) console.log( oDebug.xhrRegisterOnloadCallback, ` for xhrTrigger #`, _id )
                    callback.call(status)
                    
                }
            }
        }
    )
    Object.defineProperty( this, 'callback',
        {
            get: function(){},
            set: function(name)
            {
                callback = name
                if (_DEBUG && callback) console.log( oDebug.xhrRegisterOnloadCallbackFn, callback.toString() )
            }
        }
    )
}

function xhrOnLoad( event, pageObject )
{
    if (_DEBUG) console.log( oDebug.xhrOnLoad, `Args: event: `, event, `, pageObject: `, pageObject )

    let xhr = event.target
    let status = xhr.status

    xhrTriggerCollection.forEach( function( value, trigger ) { trigger.status = 'loading' } )

    if( xhr.readyState === XMLHttpRequest.DONE )
    {
        const receivingElement = document.getElementById( pageObject.injector )

        if ( status === 0 || ( status >= 200 && status < 400 ) )
        {
            if (_DEBUG) console.log( oDebug.xhrOnLoadSuccess )
            receivingElement.innerHTML = ''
            receivingElement.style.minHeight = 'auto'
            receivingElement.innerHTML = xhr.responseText     // the most important piece of code in this function
            currentPage = pageObject                          // _onHashChange needs to know this ..
            xhrTriggerCollection.forEach( function( value, trigger ) { trigger.status = 'loaded' } )
            if ( pageObject.toPushStateOrNot )
            {
                let stateObj = { name: pageObject.name, pageIndexNumber: pageObject.pageIndexNumber }
                history.pushState( stateObj, pageObject.title, pageObject.hashTag )
            }
            document.title = pageObject.title                 /* https://stackoverflow.com/a/27692636 */
        }
        else
        {
            receivingElement.innerHTML = xhr.statusText
        }
    }
}

function xhrOnError( event )
{
    if (_DEBUG) console.log( oDebug.xhrOnError, `Args: event: `, event )
    xhRequest.onerror = function (e) { receivingElement.innerHTML = xhRequest.statusText + ", " + xhRequest.status }
}

function xhrAddListeners( xhr, pageObject )
{
    if (_DEBUG) console.log( oDebug.xhrAddListeners, `Args: xhr: `, xhr, `, pageObject: `, pageObject )

    xhr.addEventListener( 'load' , (event) => { xhrOnLoad( event, pageObject ) } )
    xhr.addEventListener( 'error', (event) => { xhrOnError( event )            } )
}

function injectContentInto( thisPageObject )
{
    if (_DEBUG) console.log( oDebug.injectContentInto, `Args: thisPageObject: `, thisPageObject )
                    
    const xhRequest = new XMLHttpRequest()

    xhrAddListeners( xhRequest, thisPageObject )

    xhRequest.open( 'GET', thisPageObject.sourceURL )

    xhRequest.send(null)

}

function loadPage( thisPage, toPushStateOrNot = true )
{
    if (_DEBUG) console.log( oDebug.loadPage, `Args: thisPage: `, thisPage, `, toPushStateOrNot: `, toPushStateOrNot )

    xhrTriggerCollection.clear()

    if ( currentPage )
        if ( currentPage.pageIndexNumber )
        {
            sessionStorage.setItem( currentPage.pageIndexNumber, Math.max(document.body.scrollTop, document.documentElement.scrollTop) )
        }

    if ( pages[thisPage] )
    {
        pages[thisPage].toPushStateOrNot = toPushStateOrNot   // add a property to the page object
        pages[thisPage].pageIndexNumber  = thisPage

        let xhrTrigger = new xhrRegisterOnloadCallback(1)
        // define the trigger function
        xhrTrigger.callback = function() // # 1 - color the visited links.
        {
            if (_DEBUG) console.log( oDebug.loadPageTriggerCallback )
            // color the links ..
            let links = document.getElementsByTagName('a')
            for ( let i = 0; i < links.length; i++ )
            {   
                var link = links[i]
                if (link)
                    if (link.dataset)
                        if (link.dataset.id)
                            if (localStorage.getItem(link.dataset.id))
                                link.style.color = "purple"
            }
            //set the state of the Table of Contents toggle
            if ( pages[thisPage].tocToggle ) toggleTOC( pages[thisPage].tocToggle )
            
            // remember where on the page we were last time ..
            // but first, wait for 2x animation frames to occur
            // before scrolling to that place.
            // and btw, only do this for pages that are NOT a pushState
            if ( thisPage  && !toPushStateOrNot )
            {
                if ( sessionStorage.getItem( thisPage ) )
                {
                    setTimeout( function()
                        {
                            let _temp618 = function()
                            {
                                window.scroll( {left: 0, top: sessionStorage.getItem( thisPage ), behavior: "auto" } )
                            }
                            call_after_DOM_updated( _temp618 )
                        },100
                    )
                }
            }
            else if ( thisPage  && toPushStateOrNot )
            {
                window.scrollTo(0,0)
            }
            // reset the trigger callback to nothing
            xhrTrigger.callback = null
            // delete the trigger from the collection
            xhrTriggerCollection.delete(xhrTrigger)
        }
        // add this trigger to the collection as #1
        xhrTriggerCollection.set( xhrTrigger, 1 )
        //pages[thisPage].callback = xhrTrigger
        injectContentInto( pages[thisPage] )
        let newEvent = new CustomEvent( 'pageload', {target: 'fake'} )
        // if someone has asked for new page content, let's lose the menu slider.
        hideMenuPanels(newEvent) 
        // A new page, so let's go to the top.
        //window.scrollTo(0,0)
    }
}

/**
 *  In this framework's SPA logic, a URL may contain two
 *  # tags, the first representing the #page, the second 
 *  representing the #bookmark (#bkmk).
 *  If we process the incoming URL with a Regular Expression
 *  (RegExp), and ask any results to be shoved straight into
 *  an array via 'matchAll', then in theory, we have the page
 *  sitting in array[0][0] and the bookmark in array[1][0].
 *  If we default the type of fragment we want to 0 (type=0),
 *  then our 'get_fragment' function will always try and
 *  return the page as a default answer. Passing a type=1
 *  will try and return any bookmark if there is any.
 */
function get_fragment( url, type = 0 )
{
    if ( url )
    {
        if (_DEBUG) console.log( oDebug.get_fragment, `Args: url: `, url, `, type: `, type )
        // make sure the requested url doesn't contain '%20'
        // but rather just a plain space character.
        url = url.replace( /%20/g , ' ' )
        let regex = /(#{1}[^#]*)/g
        let array = [...url.matchAll(regex)]

        if ( array )
        {
            if ( array.length === 1 && !url.includes("#bkmk") && type === 0 ) // chances are very good we only have a page
            {
                if ( array[0] ) return array[0][0]
            }
            else if ( array.length === 1 && url.includes("#bkmk") && type === 1 )
            {
                if ( array[0] ) return array[0][0]
            }
            else if ( array.length === 2 )
            {
                if ( array[type] ) return array[type][0]
            }
            else
            {
                return null
            }
        }
        else
        {
            return null
        }
    }
    return null
}

function pageRequestViaAddressbar( page, bkmk )
{
    
    if (_DEBUG) console.log( oDebug.pageRequestViaAddressbar, `Args: page: `, page, `, bkmk: `, bkmk )

    // the results of an imminent JSON search will be stored in this variable
    let foundValidPage

    /* 
     * If there appears to be a valid page fragment for us, go and look it up in the JSON object by filtering for it.
     */
    if ( page )
    {
        foundValidPage = Object.keys(pages).filter( function(row)
            {
                return pages[row].hashTag === page
            }
        )
        // if the page given on the URL was valid, load the page.
        if ( foundValidPage.length > 0 ) loadPage( foundValidPage[0], false )
    }
    /*
     * If there appears to be a valid bookmark fragment for us, wait for the page to load and then scroll to it.
     */
    if ( bkmk )
    {
        /*
         * The following callback gets called by the pageLoad function, once it's done loading all the content. If we 
         * don't wait, it's super easy to trigger an error because the element isn't on the page yet!
         */
        let xhrTrigger = new xhrRegisterOnloadCallback(3)
        // define the trigger function
        xhrTrigger.callback = function() // # 3 goto bookmark from pageRequestViaAddressbar()
        {
            if (_DEBUG) console.log( oDebug.pageRequestViaAddressbar_TriggerCallback )

            window.scrollTo(0,0)
            
            let element  = document.getElementById( bkmk.replace( /^#/g , '') )
            let elemRect = element.getBoundingClientRect()

            window.scroll( 0, ( elemRect.y - 70 ) )

            // reset the trigger callback to nothing
            xhrTrigger.callback = null
            // delete the trigger from the collection
            xhrTriggerCollection.delete(xhrTrigger)

            runOnNextEventCycle(()=>{  document.title = `${currentPage.title} - ${bkmk.replace( /^#/g , '')}`  })

        }
        // add this trigger to the collection as #3
        xhrTriggerCollection.set( xhrTrigger, 3 )
    }

    // browser history is augmented with our own state object
    let stateObj

    if ( foundValidPage )
    {
        if (_DEBUG) console.log( oDebug.pageRequestViaAddressbar_foundValidPage )
        stateObj = { name: pages[foundValidPage[0]].name, pageIndexNumber: foundValidPage[0] }
        bkmk ? history.replaceState( stateObj, pages[foundValidPage[0]].title, `${page}${bkmk}` ) : 
               history.replaceState( stateObj, pages[foundValidPage[0]].title, page )
    }
    else
    {
        if (_DEBUG) console.log( oDebug.pageRequestViaAddressbar_noValidPage )
        stateObj = { name: "Index", pageIndexNumber: "page0" }
        loadPage('page0', false)
        history.replaceState( stateObj, "Index", "#/content/index.html" )
    }
}

/**
 *  Fires when the web site first loads, and only fires once.
 *  That said, there are 3 circumstances that need to be 
 *  catered for:
 *      1) Straight site visit eg. www.bloss.io
 *      2) The person hits the page reload button on their browser
 *      3) The person clicks on a browser saved bookmark, triggering
 *         a site visit with a pre-determined URL already.
 * 
 */
function _onDOMContentLoaded( event )
{

    if (_DEBUG) console.log( oDebug._onDOMContentLoaded, `Args: event: `, event )

    // grab everything we can about the URL on this event.
    let page  = get_fragment( event.target.URL , 0 )
    let bkmk  = get_fragment( event.target.URL , 1 )

    pageRequestViaAddressbar(page,bkmk)

}

function _onClick( event )
{

    if (_DEBUG) console.log( oDebug._onClick, `Args: event: `, event )
    
    bookmarkClicked = false

    // signature for a native, anchor bookmark click ..
    if ( event.isTrusted && event.target.tagName === 'A' && event.target.hash !== "" && event.target.href !== "" )
    {
        if (_DEBUG) console.log( oDebug._onClick_GenuineBookmark )
        bookmarkClicked = true
    }

    /*
     * Signature for a normal navigation link click. Let's get its data-id and look it up in the 'pages' JSON-type 
     * object, and then load the page from there.
     */
    if ( event.target.dataset.id )
    {
        if (_DEBUG) console.log( oDebug._onClick_PageNavigation, event.target.dataset.id )

        let foundValidPage = Object.keys(pages).filter( function(row)
            {
                return row === `${event.target.dataset.id}`
            }
        )

        if ( foundValidPage.length > 0 )
        {
            if (_DEBUG) console.log( oDebug._onClick_foundValidPage, foundValidPage[0] )

            loadPage( foundValidPage[0] )

            localStorage.setItem( event.target.dataset.id, true )

            if (_DEBUG && localStorage.length > 0 ) console.log( oDebug._onClick_localStorage, localStorage.length )
        }
    }

    //console.log( Math.max(document.body.scrollTop, document.documentElement.scrollTop) )

}

function _onHashChange( event )
{
    if (_DEBUG) console.log( oDebug._onHashChange, `Args: event: `, event )

    // grab everything we can about the URL on this hashChange event.
    let page    = get_fragment( event.newURL , 0 )
    let bkmk    = get_fragment( event.newURL , 1 )
    let oldPage = get_fragment( event.oldURL , 0 )
    let oldBkmk = get_fragment( event.oldURL , 1 )

    if (_DEBUG) console.log( oDebug._onHashChange, `Variables: `, page, bkmk, oldPage, oldBkmk, bookmarkClicked, currentPage )

    if ( bookmarkClicked ) // refer to the _onClick event ..
    {
        bookmarkClicked = false // now that we've used it, reset the flag marker.

        document.title = `${currentPage.title} - ${bkmk.replace( /^#/g , '')}`
        /*
         * Because this was actual navigation (albeit on the same page), we still update our history state to reflect 
         * this occurrence.
         */
        let stateObj = { name: currentPage.name, pageIndexNumber: currentPage.pageIndexNumber }
        history.replaceState( stateObj, currentPage.title, `${currentPage.hashTag}${bkmk}` )

        event.preventDefault
    }


    if ( bkmk &&  page === oldPage )
    {
        let xhrTrigger = new xhrRegisterOnloadCallback(5)
        // define the trigger function
        xhrTrigger.callback = function() // #5 goto the bookmark
        {
            if (_DEBUG) console.log( oDebug._onHashChange_gotoBkmk_TriggerCallback, bkmk )

            window.scrollTo(0,0)

            let element  = document.getElementById( bkmk.replace( /^#/g , '') )
            let elemRect = element.getBoundingClientRect()

            window.scroll( 0, ( elemRect.y - 70 ) )

            // reset the trigger callback to nothing
            xhrTrigger.callback = null
            // delete the trigger from the collection
            xhrTriggerCollection.delete(xhrTrigger)

            runOnNextEventCycle(()=>{  document.title = `${currentPage.title} - ${bkmk.replace( /^#/g , '')}`  })

        }
        // add this trigger to the collection as #5
        xhrTriggerCollection.set( xhrTrigger, 5 )
        return
    }

    // signature for Back(1) navigation - and that the previous history page was a bookmark on that page
    if ( bkmk && ( page !== oldPage || bkmk !== oldBkmk ) ) 
    {
        let xhrTrigger = new xhrRegisterOnloadCallback(7)
        // define the trigger function
        xhrTrigger.callback = function() // #7 go back with bkmk
        {
            if (_DEBUG) console.log( oDebug._onHashChange_goBackWithBkmk_TriggerCallback, bkmk )

            window.scrollTo(0,0)
            
            let element  = document.getElementById( bkmk.replace( /^#/g , '') )
            let elemRect
            if (element) { elemRect = element.getBoundingClientRect() }
            if (elemRect) window.scroll( 0, ( elemRect.y - 70 ) )

            // reset the trigger callback to nothing
            xhrTrigger.callback = null
            // delete the trigger from the collection
            xhrTriggerCollection.delete(xhrTrigger)

            runOnNextEventCycle(()=>{  document.title = `${currentPage.title} - ${bkmk.replace( /^#/g , '')}`  })

        }
        // add this trigger to the collection as #7
        xhrTriggerCollection.set( xhrTrigger, 7 )
        /* return here? */
    }

        if ( bkmk && oldPage === currentPage.hashTag )
        {
            if (_DEBUG) console.log( oDebug._onHashChange_NativeBookmark, bkmk )

            event.preventDefault
            
            window.scrollTo(0,0)
            
            let element = document.getElementById( bkmk.replace( /^#/g , '') )
            let elemRect
            if (element) { elemRect = element.getBoundingClientRect() }
            if (elemRect) window.scroll( 0, ( elemRect.y - 70 ) )

        }

}

/**
 *  Fires when we hit the Back/Forward navigation buttons.
 *  Because we've been writing history state objects with
 *  'pushState' as we've been clicking around the site,
 *  we now have a trigger/marker to tell us when a person
 *  has hit the Back/Forward buttons.
 */
function _onPopState( event )
{
    if (_DEBUG) console.log( oDebug._onPopState, `Args: event: `, event )

    let page = get_fragment( window.location.hash , 0 )
    let bkmk = get_fragment( window.location.hash , 1 )

    if ( event.state )
    {
        if (_DEBUG) console.log( oDebug._onPopState_validEventState, event.state.pageIndexNumber )
        // sanity check! before we go and load a page, are we actually on the same page but just 
        // changing between "page" and "bkmk"?
        if ( currentPage.hashTag === page ) return
        //else        
        loadPage( event.state.pageIndexNumber, false )

    }
    else
    {
        if ( page )
        {
            if (_DEBUG) console.log( oDebug._onPopState_noEventState, page, bkmk )
            pageRequestViaAddressbar(page,bkmk)
        }
    }

    if (_DEBUG) console.log( oDebug._onPopState_variables, page, bkmk, window.location.hash )
    /*
     * If everything about pages, bookmarks and history state objects are null, chances are very good that we're back at 
     * the start - 'index.html'
     */
    if ( page == null && bkmk == null && event.state == null )
    {
        if (_DEBUG) console.log( oDebug._onPopState_allNull )
        loadPage('page0', false)
    }

}

/**
 * @function getStyleSheetPropertyValue
 * @description
 * Searches any local (non-external domain) CSS files for the 
 * requested class:propertyName and retrieves the value if any.
 * The class to find is optional, in which case all properties
 * are searched for and possibly returned. The function searches
 * backwards, given CSS styles are applied top-to-bottom.
 * The return type is always an array or null. 
 * @param {String} [classToFind] an optional? string to go looking for
 * @param {String} propertyName the property name to get the value of
 * @return {String[]} returns either an array or null
 */
function getStyleSheetPropertyValue( classToFind, propertyName )
{
    let properties = []
    for ( let s = document.styleSheets.length - 1; s >= 0; s-- )
    {
        let thisStyleSheet = document.styleSheets[s]

        if ( doURIsMatch( window.location , thisStyleSheet.href ) )
        {
            let cssRules = thisStyleSheet.cssRules

            for ( let c = cssRules.length - 1; c >= 0; c-- )
            {
                if ( classToFind != null ) // looking for a specific className
                {
                    if ( cssRules[c].selectorText === classToFind )
                    {
                        // style[propertyName] = some css value
                        // eg. is the same as { color: #black; }
                        if ( cssRules[c].style.getPropertyValue(propertyName) !== "" )
                            properties.push( cssRules[c].style.getPropertyValue(propertyName).trim() )
                    }
                }
                else // looking thru all classes to find a property value
                {
                    if ( cssRules[c].type === CSSRule.STYLE_RULE )
                    {
                        // style[propertyName] = some css value
                        // eg. is the same as { color: #black; }
                        if ( cssRules[c].style.getPropertyValue(propertyName) !== "" )
                        {
                            properties.push( cssRules[c].style.getPropertyValue(propertyName).trim() )
                        }
                    }
                }
            }
        }
    }

    if ( properties.length > 0 ) { return properties }
    else {
        return null; }
}

/**
 * @function doURIsMatch
 * @description
 * Simple test to see if the origin (http://some.domain)
 * is in both URIs that have been passed in for checking.     
 * URI-1 u1 is the web site this file is on and       
 * URI-2 u2 is some linked in CSS file, local or external      
 * The overall goal is to provide a true or false test to weed
 * out external CSS files, avoiding cross-origin errors.
 * @param {String} u1 your web-site
 * @param {String} u2 some linked in file, typically a CSS
 * @return {Boolean} returns true or false for externally linked files or not
 */
function doURIsMatch( u1, u2 )
{
    if ( u2 != null ) { return ( u2.includes(u1.origin) ? true : false ) }
}

/**
 * @function logPrimaryWidth
 * 
 * @param {*} thisElementID 
 */
function logPrimaryWidth()
{
    let navBar = document.getElementsByClassName('aNavBar')

    document.body.style.setProperty
        ( "--navBarWidth" , `${( navBar.width || document.body.clientWidth || document.documentElement.clientWidth )}px` );

    document.body.style.setProperty
        ( "--docoWidth" , `${( navBar.width || document.body.clientWidth || document.documentElement.clientWidth )}` );
    
    let viewportRatio = document.documentElement.clientWidth / document.documentElement.clientHeight;
    //console.log(viewportRatio)
    if ( viewportRatio < 0.871 )
    {
        /** viewportFactor is a simple linear equation y = mx + b, or vh = 58 x AspectRatio - 5.5
         *  What it means is that the grid holding the hero image will resize itself
         *  continuously if the viewport is resized to be really skinny.
         */
        //let viewportFactor = (( viewportRatio * 58.0431 ) - 5.4975)
        let calcViewportFactor = (( viewportRatio * 58.0431 ) - 5.4975).toFixed(0)
        document.body.style.setProperty( "--viewportFactor"  , `${calcViewportFactor}vh` )
    }
    else
    {
        document.body.style.setProperty( "--viewportFactor"  , `${ViewportFactor}vh`  )
    }
}

function toggleTOC( forceState = false )
{
    let toc    = document.getElementById("toc")
    let toggle = document.getElementById("toggle")

    let tocBox = document.querySelector(".toc-container")
    let tocBoxRect 
    if ( tocBox ) tocBoxRect = tocBox.getBoundingClientRect()

    if ( forceState != false && forceState === "(<span>show</span>)" )
    {
                toggle.innerHTML = "(<span>hide</span>)"
                toc.style.setProperty("display", "inline-block")
    }
    else if ( forceState != false && forceState === "(<span>hide</span>)" )
    {
            toggle.innerHTML = "(<span>show</span>)"
            toc.style.setProperty("display", "none")
            if ( tocBox ) tocBox.style.width = `${tocBoxRect.width.toFixed(0)}px`
            console.log(tocBoxRect.width)
    }

    toggle.innerHTML  === "(<span>show</span>)" ? toggle.innerHTML = "(<span>hide</span>)" : toggle.innerHTML = "(<span>show</span>)"
    if ( toc.style.display === "inline-block" )
    {
        toc.style.setProperty("display", "none")
        if ( tocBox )
        {
            tocBox.style.width = `${tocBoxRect.width.toFixed(0)}px`
            console.log(tocBox.clientWidth)
        }
    }
    else
        toc.style.setProperty("display", "inline-block")

    if ( forceState != false)
    {
        console.log(`toggleTOC has to exit now because it was forced.`)
        return
    }

    //console.log(`toggleTOC: `)
    //let stateObj = {}
    //if ( history.state && toggle.innerHTML.length > 0 && currentPage.name === history.state.name )
    //{
        // stateObj is great for the _onPopState event ..
        //stateObj = history.state
        //stateObj.tocToggle = toggle.innerHTML
        //history.replaceState(stateObj, null, currentPage.hashTag )
        // currentPage works with a click event
        currentPage.tocToggle = toggle.innerHTML
    //}
    //console.log( stateObj )
    //console.log( history.state )
    
}

//#region objectToString
/** 
 *  useful little function
 *  Object.prototype.toString.call(foo)
 *  objectToString.call(foo)
 */
//#endregion
let objectToString = Object.prototype.toString

function captureAllEvents()
{

    const getEventNames = (root) => {
        let events = [ ];

        const objectHasSubPrototype = (object, comp) => {
            let proto = Object.getPrototypeOf(object);

            while(proto !== null && proto !== EventTarget) {
            proto = Object.getPrototypeOf(proto);
            }

            return (proto !== null);
        };

        const addEventNames = (propNames) => {
            propNames.filter(x => x.match(/^on\w+$/)).forEach((propName) => {
            propName = propName.substr(2);
            if(events.indexOf(propName) === -1) {
                events.push(propName);
            }
            });
        };

        Object.getOwnPropertyNames(root).forEach((name) => {
            let value = root[name];

            if(value) {
            if(objectHasSubPrototype(value, EventTarget)) {
                let propNames = Object.getOwnPropertyNames(Object.getPrototypeOf(value).prototype);
                addEventNames(propNames);

                propNames = Object.getOwnPropertyNames(window);
                addEventNames(propNames);
            }
            }
        });

        return events;
    };

    // Attach all events to the window
    getEventNames(window).forEach((eventName) => 
    {
        if ( ! eventName.includes("mouse") &&
             ! eventName.includes("pointer") /* &&
             ! eventName.includes("scroll")*/ )
        {
            window.addEventListener(eventName, (event) => console.log(eventName, event));
        }
    });

}

//#region Notes:
/*
    Page navigation via buttons and links: only creates a click event
                                           fires the loadPage function
                                           creates a history.pushState

    Reloading only generates a DOMContentLoaded event, but we force a fake hashchange

    Back/Forward button generates both a popstate and a hashchange event

    Native anchor bookmarks generate: a click, 
                                      popstate and a 
                                      hashchange event
*/
//#endregion