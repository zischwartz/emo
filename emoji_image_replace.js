/**
 *
 * Here's a thing that will look through all the text nodes of a document, and
 * upon encountering an emoji codepoint, will replace it with an image.
 * For now, those images are pulled from GitHub, which isn't very nice, so I
 * need to find a more suitable host.
 *
 * Much of this code was gleaned from staring at the minified GitHub JS.
 *
 * Copyright (c) 2013 Mark Wunsch. Licensed under the MIT License.
 * @markwunsch
 *
 */
(function replaceEmojiWithImages(root) {

  var REGIONAL_INDICATOR_A = parseInt("1f1e6", 16),
      REGIONAL_INDICATOR_Z = parseInt("1f1ff", 16),
      IMAGE_HOST = "assets.github.com",
      IMAGE_PATH = "/images/icons/emoji/unicode/",
      IMAGE_EXT = ".png";

  // String.fromCodePoint is super helpful
  if (!String.fromCodePoint) {
    /*!
     * ES6 Unicode Shims 0.1
     * (c) 2012 Steven Levithan <http://slevithan.com/>
     * MIT License
     **/
    String.fromCodePoint = function fromCodePoint () {
      var chars = [], point, offset, units, i;
      for (i = 0; i < arguments.length; ++i) {
        point = arguments[i];
        offset = point - 0x10000;
        units = point > 0xFFFF ? [0xD800 + (offset >> 10), 0xDC00 + (offset & 0x3FF)] : [point];
        chars.push(String.fromCharCode.apply(null, units));
      }
      return chars.join("");
    }
  }

  /**
   * Create a treewalker to walk an element and return an Array of Text Nodes.
   * This function is (hopefully) smart enough to exclude unwanted text nodes
   * like whitespace and script tags.
   * https://gist.github.com/mwunsch/4693383
   */
  function getLegitTextNodes(element) {
    if (!document.createTreeWalker) return [];

    var blacklist = ['SCRIPT', 'OPTION', 'TEXTAREA'],
        textNodes = [],
        walker = document.createTreeWalker(
            element,
            NodeFilter.SHOW_TEXT,
            function excludeBlacklistedNodes(node) {
              if (blacklist.indexOf(node.parentElement.nodeName.toUpperCase()) >= 0) return NodeFilter.FILTER_REJECT;
              if (String.prototype.trim && !node.nodeValue.trim().length) return NodeFilter.FILTER_SKIP;
              return NodeFilter.FILTER_ACCEPT;
            },
            false
        );

    while(walker.nextNode()) textNodes.push(walker.currentNode);

    return textNodes;
  }

  /**
   * Determine if this browser supports emoji.
   */
  function doesSupportEmoji() {
    var context, smiley;
    if (!document.createElement('canvas').getContext) return;
    context = document.createElement('canvas').getContext('2d');
    if (typeof context.fillText != 'function') return;
    smile = String.fromCodePoint(0x1F604); // :smile: String.fromCharCode(55357) + String.fromCharCode(56835)

    context.textBaseline = "top";
    context.font = "32px Arial";
    context.fillText(smile, 0, 0);
    return context.getImageData(16, 16, 1, 1).data[0] !== 0;
  }

  /**
   * For a UTF-16 (JavaScript's preferred encoding...kinda) surrogate pair,
   * return a Unicode codepoint.
   */
  function surrogatePairToCodepoint(lead, trail) {
    return (lead - 0xD800) * 0x400 + (trail - 0xDC00) + 0x10000;
  }

  /**
   * Get an Image element for an emoji codepoint (in hex).
   */
  function getImageForCodepoint(hex) {
    var img = document.createElement('IMG');

    img.style.width = "1.4em";
    img.style.verticalAlign = "top";
    img.src = "//" + IMAGE_HOST + IMAGE_PATH + hex + IMAGE_EXT;

    return img;
  }

  /**
   * Convert an HTML string into a DocumentFragment, for insertion into the dom.
   */
  function fragmentForString(htmlString) {
    var tmpDoc = document.createElement('DIV'),
        fragment = document.createDocumentFragment(),
        childNode;

    tmpDoc.innerHTML = htmlString;

    while(childNode = tmpDoc.firstChild) {
      fragment.appendChild(childNode);
    }
    return fragment;
  }

  /**
   * Iterate through a list of nodes, find emoji, replace with images.
   */
  function emojiReplace(nodes) {
    var PATTERN = /([\ud800-\udbff])([\udc00-\udfff])/g;

    nodes.forEach(function (node) {
      var replacement,
          value = node.nodeValue,
          matches = value.match(PATTERN);

      if (matches) {
        replacement = value.replace(PATTERN, function (match, p1, p2) {
          var codepoint = surrogatePairToCodepoint(p1.charCodeAt(0), p2.charCodeAt(0)),
              img = getImageForCodepoint(codepoint.toString(16));
          return img.outerHTML;
        });

        node.parentNode.replaceChild(fragmentForString(replacement), node);
      }
    });
  }

  // Call everything we've defined
  if (!doesSupportEmoji()) {
    emojiReplace(getLegitTextNodes(document.body));
  }

}(this));