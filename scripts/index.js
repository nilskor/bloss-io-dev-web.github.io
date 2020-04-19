
// #region - Initial comment block with global information.
/**
 * ------------------------------------------------------------------------------------------------
 * @description
 * 
 *  GLOBALS
 * 
 *  NOTICE:
 * 
 *  Do NOT pollute or cross-contaminate code between components on the page.
 * 
 *  Better to have all code belonging to an element / component in one place
 *  than scattered or mixed-in or intertwined. Better yet, consider a new
 *  javascript file per component.
 *
 * 
 * ------------------------------------------------------------------------------------------------
 */
// #endregion


'use strict';


/** Component PanelSlider */
const NAVBAR_PANEL_TIMEOUT = 500; // ms - just in case we can't read the CSS file for it.


 /** 
  * @function parseURL
  * @description
  * Artificially 'clicks' on address bookmarks (hashes)(#) to make SPA
  * (Single Page Application) routing work. Is typically triggered by
  * an automatic addEventListener attached to the forward / backward
  * navigation, using the 'popstate' event.
  * @param  {null} null - takes no arguments
  * @return {null} returns nothing
  */
function parseURL()
{
    if ( window.location.hash !== "" )
    {
        let whatToFind = `[href="${window.location.hash}"]`
        
        if ( document.querySelector(whatToFind) != null )
        {
            document.querySelector(whatToFind).click()
            console.log(`The search for ${window.location.hash} on this page was successful, so now we artificially click on it`)
            if ( history.length > 0 )
            {
                for( let i = 0 ; i < window.history.length; i++ )
                {
                    console.log(`::window.history[i]: ${window.history[i]}`);
                }
            }
        }
        else
        {
            console.log(`Could not find ${window.location.hash} on this page, nothing will happen.`)
            injectContentInto( 'injectHere', null )
        }
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
 * @function testForValidDisplayTypeWith
 * @description
 * Takes a CSS property string and checks if it is a known
 * 'display as' type.      
 * eg. { display: block }                            
 * Takes one string parameter and returns a boolean
 * @param {String} thisCssProperty a css property string to test
 */
function testForValidDisplayTypeWith( thisCssProperty )
{
    const DISPLAY = [ 'block ', 'contents', 'flex', 'grid', 'none',
                      'initial', 'inherit', 'list-item', 'run-in',
                      'inline', 'inline-block', 'inline-flex', 'inline-grid', 'inline-table',
                      'table', 'table-caption', 'table-column-group', 'table-header-group',
                      'table-footer-group', 'table-row-group', 'table-cell', 'table-column',
                      'table-row'
                    ];

    return ( DISPLAY.includes( thisCssProperty ) ? true : false)
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
    
    let viewportRatio = document.documentElement.clientWidth / document.documentElement.clientHeight;
    if ( viewportRatio < 0.871 )
    {
        /** viewportFactor is a simple linear equation y = mx + b, or vh = 58xAspectRatio - 5.5
         *  What it means is that the grid holding the hero image will resize itself
         *  continuously if the viewport is resized to be really skinny.
         */
        let viewportFactor = ( viewportRatio * 58.0431 ) - 5.4975 
        document.body.style.setProperty( "--viewportFactor" , `${viewportFactor}vh` )
    }
}

/** A routing function for this event */
function documentOnclick(event)
{
    hideMenuPanels(event)
}


//#region - COMPONENTS ==================================================================
 /**
  * @description
  * Like Angular, this framework here attempts to separate
  * out the components from one another, such that maintenance
  * becomes 'easier'.
  */
//#endregion


/** Component PanelSlider
 * 
 * @method panelSlider
 * @description
 * This method has a simple task of toggling a class on and off,     
 * onto or from the given (passed in) element (thisElementID).      
 * Additionally, it checks any peers for the same attributes and    
 * will first "turn them off" before toggling this current element.  
 * Requirements:                                                         
 * An element with class="navbarChildPanel" assigned to it.          
 * Two CSS classes that control the behaviour, namely:               
 * - navbarChildPanel
 * - panelShowing                                                    
 * 
 * The overall effect is a sliding set of panels, whereby only one   
 * is showing at any point in time.
 * @param {String} thisElementID
 * @param {String} type 'child' or 'grandChild'
 */
function panelSlider( thisElementID, type )
{
    const panelFlavour = { type: type, className: "", toggleName: "" }

    switch ( type )
    {
        case 'child':
            panelFlavour.className  = "navbarChildPanel"
            panelFlavour.toggleName = "panelShowing"
            break;
    
        case 'grandChild':
            panelFlavour.className  = "grandchildPanel"
            panelFlavour.toggleName = "grandchildPanelShowing"
            break;

        default:
            break;
    }

    // all grand-children should dispappear if the parent is swapping ..
    if ( panelFlavour.type === 'child' ) 
    {
        let grandKids = document.getElementsByClassName( 'grandchildPanel' )
        for ( let grandchild of grandKids )
        {
            if ( grandchild.classList.contains( 'grandchildPanelShowing' ) )
                {
                    grandchild.classList.remove( 'grandchildPanelShowing' )
                }
        }
    }

    // get a reference to the object
    let thisHTMLElement = document.getElementById( thisElementID );

    // get a reference to all other peer-level sliding panels that will be affected
    let peerPanels = document.getElementsByClassName( panelFlavour.className )

    let mustWait = false

    // hide every panel first
    for ( let panel of peerPanels )
    {
        if ( thisHTMLElement.id !== panel.id )
        {
            if ( panel.classList.contains( panelFlavour.toggleName ) )
                {
                    panel.classList.remove( panelFlavour.toggleName )
                    mustWait = true
                }
        }
    }

    let cssSearch = getStyleSheetPropertyValue( ":root", "--navBarPanelTimeout")
    let navBarPanelTimeout = NAVBAR_PANEL_TIMEOUT

    if ( cssSearch.length > 0 )
    {
        navBarPanelTimeout = cssSearch[0]
        if ( navBarPanelTimeout.includes( 'ms' ) )
        {
            navBarPanelTimeout = navBarPanelTimeout.slice( 0, navBarPanelTimeout.length - 2 )
        }
    }

    if (mustWait) { setTimeout( () => { thisHTMLElement.classList.toggle( panelFlavour.toggleName ) }, navBarPanelTimeout ); }
    else {
        thisHTMLElement.classList.toggle( panelFlavour.toggleName ) }
}

/** Not to be confused with panelSlider */
/** This is to hide the menus when the person clicks on the page somewhere. */
function hideMenuPanels( event )
{
    /** this weeds out the initial page load, which has a fake click "event" */
    if ( event.target.parentNode.classList.contains('displayNone') &&
         event.target.hash === "#index" ) { return }

    let theClickedElement = event.target
    
    /** Pseudo:
     *  Find any element that has the panelShowing
     *  or grandchildShowing on it.
     *  Toggle them off
     */
    /** find all known panels */
    let queryResult   = document.querySelectorAll(`[class*='navbarChildPanel'], [class*='grandchildPanel']`)
    let allMenuPanels = []
    /** create a new array and immediately store the only and only navBar element */
    allMenuPanels.push( document.getElementsByClassName( 'aNavBar' )[0] )
    /** then add all the other known panels to that array too */
    Array.prototype.forEach.call( queryResult, (elem) => { allMenuPanels.push(elem) } );
    
    /** now we have an array with all known panels, which we can use to test children against */
    /** if the clicked element is a child of one of these, ignore it */
    /** if the clicked element belongs to somewhere else on the body, remove the menus */
    if ( allMenuPanels.length > 0 )
    {
        let foundAncestor = false
        /** start with the clicked element and work its way up its family tree to see */
        /** if it intersects with this Parent element. */
        for ( let aParentMenuPanel of allMenuPanels )
        {
            while ( theClickedElement.nodeName !== 'BODY' && foundAncestor === false && theClickedElement != null )
            {
                if ( aParentMenuPanel.isEqualNode( theClickedElement ) )
                {
                    //console.log(`nodes are equal`)
                    foundAncestor = true
                }
                else
                {
                    theClickedElement = theClickedElement.parentNode
                }
            }
            /** was that parent in the family of the clicked element? */
            if ( foundAncestor ) return
            else
            {
                /** if not, check the next parent .. */
                theClickedElement = event.target
            }
        }
        //console.log(`hide the menus??`)
        for ( let panel of allMenuPanels )
        {
            if ( panel.classList.contains( 'panelShowing' ) )
            {
                panel.classList.remove( 'panelShowing' )
            }
            if ( panel.classList.contains( 'grandchildPanelShowing' ) )
            {
                panel.classList.remove( 'grandchildPanelShowing' )
            }
        }
    }
    
}


function toggleTOC()
{
    let toc    = document.getElementById("toc")
    let toggle = document.getElementById("toggle")

    if ( toc.style.display === "initial" )
    {
        toc.style.setProperty("display", "none")
        toggle.innerHTML = "show"
    }
    else
    {
        toc.style.setProperty("display", "initial")
        toggle.innerHTML = "hide"
    }
}
