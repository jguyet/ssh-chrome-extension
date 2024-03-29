# ssh-chrome-extension

![icon](./extension/icon-64x64.png)

## Shellac - extend Chrome with unix shell commands ##

Shellac is an extension for the [Google Chrome web browser](http://www.google.com/chrome).

With Shellac you can add actions to the browser context menu that invoke shell commands you define. The commands are passed information about the current page, like its url, its title, the currently selected block of text, etc.

Shellac comes with some built-in commands:

* Open the source to the current page in your `$EDITOR`.
* Mail a link to the current page, a la Safari for iPhone.
* Mail an image as an attachment.
* Copy the current url + selected text to the X clipboard.

It's easy to [add your own commands](#hacking). Some other ideas:

* Bookmark the current page with a command line bookmarking program.
* Highlight snippets of text and send them to a note-taking program.

Shellac is alpha and targeted at developers.

## Screenshots ##

### The popup shows status and registered commands ###

![Shellac extension page](./screenshots/extension-popup.png)

### The link context menu ###

![Shellac link context menu](./screenshots/mail-link.png)

### The page context menu ###

![Shellac page context menu](./screenshots/page-menu.png)

## Installation and Usage ##

Requirements:

* [Python](http://python.org/) (&gt;= 2.5)

To install the service:

* create directory at your home ```mkdir ~/bin```
* clone this project in ```~/bin/ssh-chrome-extension```
* go to ```~/bin/ssh-chrome-extension```
* set your username to shellac.service file

```
User=jguyet
Group=jguyet
```

* execute bash script install ```./install.sh```
* after service has installed and executed after next reboot

To install the Chrome extension:

* Bring up the extensions management page by clicking the wrench icon and choosing Tools &gt; Extensions. On a Mac, it's under "Window | Extensions".
* If Developer mode has a + by it, click the + to add developer information to the page. The + changes to a -, and more buttons and information appear.
* Click the Load unpacked extension button. A file dialog appears.
* In the file dialog, navigate to the `shellac/extension` folder and click OK.

You should see a new icon appear to the right of the address bar. Click it to get some general info.

If you right click anywhere on a web page, on a link, or on selected text, you should see "Shellac" in the context menu. (Note that for security reasons, extensions can't modify the context menu on `chrome://*` or `file://*` pages.)

<a name="hacking"></a>
## Writing Your Own Shell Command Actions ##

Edit `etc/shellac.json` and add your custom action. The commands are executed under `/bin/sh -c`. Here's an example:

    {
      "actions": [
        {
          "name": "mail_page_thunderbird",
          "title": "Mail this Page with thunderbird",
          "command": "scripts/mail_thunderbird \"$SHELLAC_TAB_URL\" \"$SHELLAC_TAB_TITLE\"",
          "contexts": ["page"]
        },
        {
          "name": "mail_link_thunderbird",
          "title": "Mail this Link with thunderbird",
          "command": "scripts/mail_thunderbird \"$SHELLAC_INFO_LINKURL\" \"$SHELLAC_TAB_TITLE\"",
          "contexts": ["link"]
        },
      ]
    }

The `contexts` key determines whether or not the menu item should appear when you right click certain types of elements. Legal values are: 'all', 'page', 'selection', 'link', 'editable', 'image', 'video', and 'audio'.

The `mail_thunderbird` script looks like this:

    #!/bin/sh

    link="$1"
    title="$2"

    exec thunderbird -compose subject="$title",body="$link"

If you modify `etc/shellac.json`, choose the `Refresh This List of Commands` item from the context menu, and you'll see your changes the next time you bring up the context menu. I hope the Chrome extension APIs will have better support for dynamic context menus in the future.

Commands are passed information about the browser context via `SHELLAC_*` environmental variables. The `$SHELLAC_ACTION` variable always specifies the name of the action that was selected. Other variables come from the Chrome browser context. In particular, take a look at:

* [Tab Properties](http://code.google.com/chrome/extensions/tabs.html#type-Tab)
* [Click Info Properties](http://code.google.com/chrome/extensions/contextMenus.html#type-OnClickData)

Shellac comes with a "Debugging: dump environment" action. You should see some output like this in the terminal:

    SHELLAC_ACTION=env
    SHELLAC_INFO_EDITABLE=false
    SHELLAC_INFO_LINKURL=http://creativecommons.org/licenses/by/3.0/
    SHELLAC_INFO_MENUITEMID=4
    SHELLAC_INFO_PAGEURL=http://code.google.com/chrome/extensions/tabs.html#type-Tab
    SHELLAC_INFO_PARENTMENUITEMID=1
    SHELLAC_TAB_FAVICONURL=http://code.google.com/favicon.ico
    SHELLAC_TAB_ID=8
    SHELLAC_TAB_INCOGNITO=false
    SHELLAC_TAB_INDEX=1
    SHELLAC_TAB_PINNED=false
    SHELLAC_TAB_SELECTED=true
    SHELLAC_TAB_STATUS=complete
    SHELLAC_TAB_TITLE=Tabs - Google Chrome Extensions - Google Code
    SHELLAC_TAB_URL=http://code.google.com/chrome/extensions/tabs.html#type-Tab
    SHELLAC_TAB_WINDOWID=5

## Binding Actions to Keyboard Shortcuts ##

You can set up keyboard shortcuts in the `extension/manifest.json` file as per the [Chrome Commands API](https://developer.chrome.com/extensions/commands). If triggered command name matches the name of a configured action, the action will be triggered as well.

For example, if you wanted to bind the "Edit the Source to this Page" action to the key combination `ctrl+shift+e`, you could first add this command to `extension/manifest.json`:

```.json
{  
  "name": "Shellac",
  "version": "0.3",
  "manifest_version": 2,
  ...
  "commands": {
    "edit_page": {
    "description": "Edit the Source to this Page"
    }
  }
}
```

Then, after visiting `chrome://extensions` and reloading Shellac, scroll to the bottom of the extensions page and click on "Keyboard shortcuts". Click on the text box in the Shellac section next to "Edit the Source to this Page", press your desired key combination (e.g., `ctrl+shift+e`), and click "OK". Since your new command shares the same name as the action (i.e., `edit_page`), the action will be triggered when you press `ctrl+shift+e`.

*Caveat: due to limitations of the Chrome extension API, only the `["page"]` context is available to actions triggered by keyboard shortcuts.*

## Security ##

The Shellac web app listens on a localhost port, by default 8783. The set of available shell command actions are defined on the server side; no extra positional arguments are appended to the shell commands. Data is passed via `SHELLAC_*` environmental variables. If you pass variables as positional arguments to a shell command, be sure to use shell argument quoting.

The current Chrome extension permissions model allows cross-**port** scripting requests: the Shellac javascript can send requests to any port on `127.0.0.1`. I didn't see any way to restrict this or I would have. If you need to convince yourself Shellac is well-behaved in this respect (it is!), the code is opensource and small...you know what to do...

## Bugs ##

* If the shell command doesn't exit cleanly, the web app doesn't process further commands?
