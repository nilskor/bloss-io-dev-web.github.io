
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


const PAGE_TEXT_FADE_TIMEOUT = 180;


/** Component ContentInjector
 * 
 * @method injectContentInto
 * @description
 * This framework revolves almost entirely around this one
 * method, as it mimics Angular's Single Page Application
 * functionality. Using the XMLHttpRequest object, page
 * content is read from files and injected into the target
 * element (thisElement).                                            
 * Requirements:                                                     
 * For this component method to work it needs at least one
 * html element with an 'id' that matches the passed-in
 * target element :                                                  
 * - <div id="injectHere">content goes here</div>
 * - onclick="injectContentInto( 'injectHere', '/_index.html' )"       
 * 
 * @param {String} thisElement 
 * @param {String} fromThisPage 
 */
function injectContentInto( thisElement, fromThisPage, title )
{
    let receivingElement = document.getElementById( thisElement )
    let xhRequest = new XMLHttpRequest()
    let pageTitle = "bloss.io"

    fromThisPage = `https://www.bloss.tech${fromThisPage}`

    if ( title != null ) { pageTitle = title }

    xhRequest.open("GET", fromThisPage, true)

    xhRequest.onload = function (e)
    {
        if ( xhRequest.readyState === 4 )
        {
            if ( xhRequest.status === 200 )
            {
                let theCurrentTextColor = getStyleSheetPropertyValue( `.${thisElement}`, 'color' )
                let theBackgroundColor  = window.getComputedStyle( receivingElement ).backgroundColor

                receivingElement.style.transition = `color ${PAGE_TEXT_FADE_TIMEOUT}ms ease-in-out`;
                receivingElement.style.color      = theBackgroundColor;
                
                setTimeout( () => 
                    {
                        receivingElement.innerHTML   = xhRequest.responseText; // the only important bit !!
                        receivingElement.style.color = theCurrentTextColor;
                        document.title = pageTitle;
                    },
                    PAGE_TEXT_FADE_TIMEOUT * 2
                );
            }
            else { receivingElement.innerHTML = xhRequest.statusText }
        }
    }

    xhRequest.onerror = function (e) { receivingElement.innerHTML = xhRequest.statusText }

    xhRequest.send(null)

}


//#region - MDN documentation for loading a file with XMLHttpRequest
/**
 * MDN example 2:
 * 
 * https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/Synchronous_and_Asynchronous_Requests#Asynchronous_request
 * 
 * function xhrSuccess()
 * { 
 *     this.callback.apply(this, this.arguments); 
 * }
 * 
 * function xhrError()
 * { 
 *     console.error(this.statusText); 
 * }
 * 
 * function loadFile(url, callback /*, opt_arg1, opt_arg2, ... *)
 * {
 *     var xhr = new XMLHttpRequest();
 *     xhr.callback = callback;
 *     xhr.arguments = Array.prototype.slice.call(arguments, 2);
 *     xhr.onload = xhrSuccess;
 *     xhr.onerror = xhrError;
 *     xhr.open("GET", url, true);
 *     xhr.send(null);
 * }
 * 
 * function showMessage(message)
 * {
 *     console.log(`MDN example 2: ${message + this.responseText}`);
 * }
 */
//#endregion
