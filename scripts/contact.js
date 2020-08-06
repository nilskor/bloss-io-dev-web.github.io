
'use strict';

const ro = new ResizeObserver( ( entries, observer ) => 
    {
        for (let entry of entries)
        {
            if (entry)
                if (entry.target)
                    if (entry.target.id === "contactImg")
                    {
                        if ( entry.target.clientHeight > 0 )
                        {
                            document.body.style.setProperty( "--contactCardTop" , `${entry.target.clientHeight/-2}px` )
                            if ( document.getElementById('contactCard') )
                            {
                                let theContactCard = document.getElementById('contactCard')
                                let theNavbar = document.getElementsByClassName('aNavBar')
                                let theWidth = (theNavbar[0].clientWidth - theContactCard.clientWidth)/2
                                document.body.style.setProperty( "--contactCardLeft" , `${theWidth}px` )
                            }
                        }
                    }
        }
    })

// Helpers
let UID = { _current: 0, getNew: function() { this._current++; return this._current } }

function arrayIncludes( theArray, theElement )
{
    for ( var i = 0; i < theArray.length; i++ )
    {
        if ( theArray.item(i).includes(theElement) ) { return true }
    }
    return false
}

HTMLElement.prototype.pseudoStyle = function( element, prop, value )
{
    /** Original:
	var _this = this;
	var _sheetId = "pseudoStyles";
	var _head = document.head || document.getElementsByTagName('head')[0];
	var _sheet = document.getElementById(_sheetId) || document.createElement('style');
	_sheet.id = _sheetId;
	var className = "pseudoStyle" + UID.getNew();
	
	_this.className +=  " "+className; 
	
	_sheet.innerHTML += "\n."+className+":"+element+"{"+prop+":"+value+"}";
	_head.appendChild(_sheet);
    return this;
    */

    // variables
	let el        = this
	let id        = "pseudo-styles"
	let changed   = false
    let className = ""
	let sheet     = document.getElementById(id) || document.createElement('style')
    let head      = document.head || document.getElementsByTagName('head')[0]
    let styles
    
	sheet.id = id

    let attributes   = {}
    attributes[prop] = value    

    let has_pseudo_class = ( this.getAttribute('class') && arrayIncludes( this.classList, 'pseudo-style') )
    
    if ( has_pseudo_class )
    {
        let classes = this.getAttribute('class')
        
		className = classes.substr( classes.indexOf('pseudo-style') )   // remove classes before
		className = classes.substr( classes.indexOf(' ')+1 )            // remove classes after

    }
    else
    {
		// generate a new class name
        className     = "pseudo-style" + UID.getNew()
		el.className += ( ( el.className == "" ) ? "" : " ")+ className
		changed = true
	}

    let selector = className +":"+ element

    if ( !styles && selector )
    {
        styles = {}
        styles[ selector ] = {}
    }
    
    // check if the styles have changed
    if ( styles[ selector ] != attributes )
    {
        styles[ selector ] = Object.assign( styles[ selector ], attributes )
        changed = true
    }

    if ( !changed ) return this
    
	let output = ""
    
    for ( let target in styles )
    {
        let css = ""
        
        for ( let key in styles[target] )
        {
			css += key +":"+ styles[target][key] +";"
		}
		output += " ."+ target +" {"+ css +" }"
    }
    
	sheet.innerHTML = output
	head.appendChild(sheet)

	return this
}

function xhrContactEmailData_Load( event )
{
    //if (_DEBUG) console.log( oDebug.xhrOnLoad, `Args: event: `, event, `, pageObject: `, pageObject )

    let xhr = event.target
    let status = xhr.status

    if( xhr.readyState === XMLHttpRequest.DONE )
    {
        if ( status === 0 || ( status >= 200 && status < 400 ) )
        {
            if ( event.target.response )
            {
                let responseJSON = JSON.parse(event.target.response)

                if ( responseJSON )
                    if ( responseJSON.result )
                        if ( responseJSON.result === "success")
                        {
                            //console.log(`contact email success`)
                            document.getElementById('contactCard').style.setProperty('display', 'none')
                            document.getElementById('contactThankYou').style.setProperty('display', 'block')
                        }
                        else
                        if ( responseJSON.result === "error" )
                        {
                            //console.log(`contact email error`, `fallback is: ${responseJSON.fallback}`)
                            let contactErrorMsg = document.getElementById('contactErrorMsg')

                            if ( contactErrorMsg && responseJSON.fallback )
                            {
                                //console.log(responseJSON)
                                let errSubject = responseJSON.incomingData.parameter.msgSubject
                                let errMsgBody = responseJSON.incomingData.parameter.msgBody

                                if ( errSubject !== "null" )
                                {
                                    let regex = /\s/gi
                                    errSubject = errSubject.replace( regex, '%20')
                                    errSubject = `?subject=${errSubject}`
                                }
                                else
                                {
                                    errSubject = `?subject=[Contact form message]`
                                }

                                if ( errMsgBody !== "null" )
                                {
                                    let regex = /\s/gi
                                    errMsgBody = errMsgBody.replace( regex, '%20')
                                    errMsgBody = `&body=${errMsgBody}`
                                }
                                else
                                {
                                    errSubject = `&body=Error:%20empty%20message.`
                                }
                                
                                contactErrorMsg.innerHTML = `<a href="${responseJSON.fallback+errSubject+errMsgBody}" style="color:red;">We apologise, an error occurred. Please try this fallback link instead.</a>`

                            }
                        }
            }
        }
    }
}

function xhrContactEmailData_OnError( event )
{
    console.log(`contact email server failure`, event)
}

function aQ8i4VGH3ws25( xName, xEmail, xCompany, xSubject, xMsg )
{
    let formData = new FormData()

    formData.append("personName",    xName    )
    formData.append("personEmail",   xEmail   )
    formData.append("personCompany", xCompany )
    formData.append("msgSubject",    xSubject )
    formData.append("msgBody",       xMsg     )
    
    const xhrContactEmailData = new XMLHttpRequest()
    
    xhrContactEmailData.addEventListener( 'load' , (event) => { xhrContactEmailData_Load    ( event ) } )
    xhrContactEmailData.addEventListener( 'error', (event) => { xhrContactEmailData_OnError ( event ) } )
    
    xhrContactEmailData.open( 'POST', 'https://script.google.com/macros/s/AKfycbyXd86iJlaOp9-cAx_dO1XBm9kbVrStcKecU2D_C__fo_HzTHk/exec' )
    
    xhrContactEmailData.send(formData)

}

function contactOnKeydown( event )
{
    if( event.keyCode !== 13 ) return
    validateForm( event )
}

function setInvalid(elem)
{
    elem.classList.add('invalid')
    elem.classList.remove('valid')
}
function setValid(elem)
{
    elem.classList.add('valid')
    elem.classList.remove('invalid')
}

function validateForm( event )
{
    event.preventDefault()

    let valid = true

    //--------------------------------------------------------------------

    let xName = document.forms["contactForm"]["fName"]

    if ( xName.value.trim() === "" )
    {
        valid = false
        setInvalid(xName)
    }
    else
    {
        setValid(xName)
        xName = xName.value.trim()
    }

    //--------------------------------------------------------------------

    let xEmail = document.forms["contactForm"]["fEmail"]

    if ( xEmail.value.trim().match(/^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{1,5}|[0-9]{1,3})(\]?)$/) == null )
    {
        valid = false
        setInvalid(xEmail)
    }
    else
    {
        setValid(xEmail)
        xEmail = xEmail.value.trim()
    }

    //--------------------------------------------------------------------

    let xMsg = document.forms["contactForm"]["fMessage"]

    if ( xMsg.value.trim() === "" )
    {
        valid = false
        setInvalid(xMsg)
    }
    else
    {
        setValid(xMsg)
        xMsg = xMsg.value.trim()
    }

    //--------------------------------------------------------------------

    let xCompany = document.forms["contactForm"]["fCompany"]

    if ( xCompany.value.trim() === "" ) xCompany = null
    else xCompany = xCompany.value.trim()

    //--------------------------------------------------------------------

    let xSubject = document.forms["contactForm"]["fSubject"]

    if ( xSubject.value.trim() === "" ) xSubject = null
    else xSubject = xSubject.value.trim()

    //--------------------------------------------------------------------


    let invalidAlert = function(){ alert(`Please fix the highlighted areas`) }
    if ( !valid ) call_after_DOM_updated( invalidAlert )

    if ( valid ) aQ8i4VGH3ws25( xName, xEmail, xCompany, xSubject, xMsg )

}
