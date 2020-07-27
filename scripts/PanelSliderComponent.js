
'use strict';

/** Component PanelSlider */
const NAVBAR_PANEL_TIMEOUT  = 500; // ms - just in case we can't read the CSS file for it.

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
    if ( event.target !== 'fake' && event.type !== 'pageload' )
    {
        if ( event.target.parentNode )
        {
            if ( event.target.parentNode.classList.contains('displayNone') && event.target.hash === "#/content/index.html" ) { return }
        }
    }

    if ( event.target )
        if ( event.target.dataset )
            if ( event.target.dataset.forcedclick )
                return

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
            while ( theClickedElement != null && 
                    theClickedElement.nodeName != null && 
                    theClickedElement.nodeName !== 'BODY' && 
                    foundAncestor === false )
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
            if ( foundAncestor )
            {
                //console.log(`must return before hiding the menu ..`)
                return
            }
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

