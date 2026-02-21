var LamboScript = {
    version: 1.1,
    serializeElement: function(el) {
        if (!(el instanceof Element)) return null;
        
        const path = [];
        while (el.nodeType === Node.ELEMENT_NODE) {
            let selector = el.nodeName.toLowerCase();
            
            let sibling = el;
            let nth = 1;
            while (sibling = sibling.previousElementSibling) {
                if (sibling.nodeName.toLowerCase() === selector) {
                    nth++;
                }
            }
            selector += `:nth-of-type(${nth})`;
            path.unshift(selector);
            el = el.parentNode;
        }
        return path.join(' > ');
    },
    clickEventListener: function(e) {
        let clickedEl = this.serializeElement(e.target);
        console.log("Clicked element path:", clickedEl);
        window.flutter_inappwebview.callHandler('clicked', clickedEl);
    }
}

console.log("LamboScript version", LamboScript.version);
document.addEventListener('click', LamboScript.clickEventListener);